local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DefaultPlayerData = require(ReplicatedStorage.Shared:WaitForChild("DefaultPlayerData"))
local clone = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("Clone"))
local UpgradeConfig = require(ReplicatedStorage.Shared:WaitForChild("UpgradeConfig"))

local PlayerDataService = {}

local DATASTORE_NAME = "YoyoIncrementalPlayerData_v1"
local AUTOSAVE_INTERVAL = 60

local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local playerDataByUserId = {}
local dirtyByUserId = {}

local remotesFolder
local dataUpdatedEvent
local buyUpgradeFunction
local getDataFunction

local function getDataKey(player)
	return "Player_" .. tostring(player.UserId)
end

local function getCrewMember(data, memberId)
	for _, member in ipairs(data.crew.members) do
		if member.id == memberId then
			return member
		end
	end

	return nil
end

local function getCrewSlot(memberId)
	for _, slot in ipairs(UpgradeConfig.CrewSlots) do
		if slot.memberId == memberId then
			return slot
		end
	end

	return nil
end

local function addStat(stats, stat, amount)
	stats[stat] = (stats[stat] or 0) + amount
end

local function addTrick(stats, trick, amount)
	stats.tricks[trick] = math.clamp((stats.tricks[trick] or 0) + amount, 0, 1)
end

local function applyToCrewMember(data, effect, context)
	if type(context) ~= "table" or context.scope ~= "crew" then
		return
	end

	local slot = getCrewSlot(context.memberId)
	if not slot then
		return
	end

	if effect.action == "addMember" then
		if #data.crew.members >= data.crew.maxSize or getCrewMember(data, slot.memberId) then
			return
		end

		table.insert(data.crew.members, DefaultPlayerData.createCrewMember(slot.memberId, slot.memberName))
		return
	end

	local member = getCrewMember(data, slot.memberId)
	if not member then
		return
	end

	if effect.trick then
		addTrick(member.stats, effect.trick, effect.amount)
	else
		addStat(member.stats, effect.stat, effect.amount)
	end
end

local function applyUpgrade(data, upgrade, context)
	for _, effect in ipairs(upgrade.effects or {}) do
		if effect.target == "player" then
			if effect.trick then
				addTrick(data.player.stats, effect.trick, effect.amount)
			else
				addStat(data.player.stats, effect.stat, effect.amount)
			end
		elseif effect.target == "crewMember" then
			applyToCrewMember(data, effect, context)
		end
	end
end

local function fireDataUpdated(player)
	dataUpdatedEvent:FireClient(player, clone(playerDataByUserId[player.UserId]))
end

local function savePlayer(player)
	local userId = player.UserId
	local data = playerDataByUserId[userId]

	if not data then
		return
	end

	local success, err = pcall(function()
		dataStore:SetAsync(getDataKey(player), data)
	end)

	if success then
		dirtyByUserId[userId] = nil
	else
		warn("[PlayerDataService] Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

local function loadPlayer(player)
	local savedData

	local success, err = pcall(function()
		savedData = dataStore:GetAsync(getDataKey(player))
	end)

	if not success then
		warn("[PlayerDataService] Failed to load data for " .. player.Name .. ": " .. tostring(err))
	end

	playerDataByUserId[player.UserId] = DefaultPlayerData.merge(savedData)
	dirtyByUserId[player.UserId] = nil
	fireDataUpdated(player)
end

local function buyUpgrade(player, upgradeId, context)
	local data = playerDataByUserId[player.UserId]

	if not data then
		return false, "Data is still loading."
	end

	if type(upgradeId) ~= "string" then
		return false, "Invalid upgrade id."
	end

	if type(context) ~= "table" then
		context = nil
	end

	if not UpgradeConfig.canBuy(data, upgradeId, context) then
		return false, "Upgrade is locked or already maxed."
	end

	local upgrade = UpgradeConfig.getUpgrade(upgradeId)
	local cost = UpgradeConfig.getCost(upgrade, UpgradeConfig.getLevel(data, upgradeId, context))

	if (data.money or 0) < cost then
		return false, "Not enough money."
	end

	local upgradeKey = UpgradeConfig.getUpgradeKey(upgradeId, context)

	data.money = (data.money or 0) - cost
	data.upgradeLevels[upgradeKey] = UpgradeConfig.getLevel(data, upgradeId, context) + 1
	data.unlockedUpgrades[upgradeKey] = true
	applyUpgrade(data, upgrade, context)
	dirtyByUserId[player.UserId] = true
	fireDataUpdated(player)

	return true, clone(data)
end

local function createRemotes()
	remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = ReplicatedStorage
	end

	local skillTreeFolder = remotesFolder:FindFirstChild("SkillTree")

	if not skillTreeFolder then
		skillTreeFolder = Instance.new("Folder")
		skillTreeFolder.Name = "SkillTree"
		skillTreeFolder.Parent = remotesFolder
	end

	dataUpdatedEvent = skillTreeFolder:FindFirstChild("DataUpdated")
	if not dataUpdatedEvent then
		dataUpdatedEvent = Instance.new("RemoteEvent")
		dataUpdatedEvent.Name = "DataUpdated"
		dataUpdatedEvent.Parent = skillTreeFolder
	end

	buyUpgradeFunction = skillTreeFolder:FindFirstChild("BuyUpgrade")
	if not buyUpgradeFunction then
		buyUpgradeFunction = Instance.new("RemoteFunction")
		buyUpgradeFunction.Name = "BuyUpgrade"
		buyUpgradeFunction.Parent = skillTreeFolder
	end

	getDataFunction = skillTreeFolder:FindFirstChild("GetData")
	if not getDataFunction then
		getDataFunction = Instance.new("RemoteFunction")
		getDataFunction.Name = "GetData"
		getDataFunction.Parent = skillTreeFolder
	end
end

function PlayerDataService.start()
	createRemotes()

	getDataFunction.OnServerInvoke = function(player)
		local data = playerDataByUserId[player.UserId]

		if not data then
			return nil
		end

		return clone(data)
	end

	buyUpgradeFunction.OnServerInvoke = buyUpgrade

	Players.PlayerAdded:Connect(loadPlayer)
	Players.PlayerRemoving:Connect(function(player)
		savePlayer(player)
		playerDataByUserId[player.UserId] = nil
		dirtyByUserId[player.UserId] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(loadPlayer, player)
	end

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)

			for _, player in ipairs(Players:GetPlayers()) do
				if dirtyByUserId[player.UserId] then
					savePlayer(player)
				end
			end
		end
	end)

	game:BindToClose(function()
		if RunService:IsStudio() then
			task.wait(1)
		end

		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end)
end

return PlayerDataService
