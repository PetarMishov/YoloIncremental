local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DefaultPlayerData = require(ReplicatedStorage.Shared:WaitForChild("DefaultPlayerData"))
local clone = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("Clone"))
local UpgradeConfig = require(ReplicatedStorage.Shared:WaitForChild("UpgradeConfig"))
local Money = require(script.Parent.PlayerData.Money)
local Remotes = require(script.Parent.PlayerData.Remotes)
local UpgradeEffects = require(script.Parent.PlayerData.UpgradeEffects)

local PlayerDataService = {}

local DATASTORE_NAME = "YoyoIncrementalPlayerData_v1"
local LIFETIME_LEADERBOARD_NAME = "YoyoIncrementalLifetimeMoney_v1"
local AUTOSAVE_INTERVAL = 60

local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local lifetimeLeaderboard = DataStoreService:GetOrderedDataStore(LIFETIME_LEADERBOARD_NAME)
local playerDataByUserId = {}
local dirtyByUserId = {}

local remotes

local function getDataKey(player)
	return "Player_" .. tostring(player.UserId)
end

local function fireDataUpdated(player)
	remotes.dataUpdated:FireClient(player, clone(playerDataByUserId[player.UserId]))
end

local function getPlayerName(userId)
	local player = Players:GetPlayerByUserId(userId)
	if player then
		return player.Name
	end

	local success, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)

	if success then
		return name
	end

	return "Player " .. tostring(userId)
end

local function getLifetimeLeaderboard()
	local byUserId = {}

	local success, pages = pcall(function()
		return lifetimeLeaderboard:GetSortedAsync(false, 10)
	end)

	if success then
		for _, entry in ipairs(pages:GetCurrentPage()) do
			local userId = tonumber(entry.key)

			if userId then
				byUserId[userId] = {
					userId = userId,
					name = getPlayerName(userId),
					totalMoneyEarned = Money.sanitize(entry.value),
				}
			end
		end
	else
		warn("[PlayerDataService] Failed to load lifetime money leaderboard: " .. tostring(pages))
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local data = playerDataByUserId[player.UserId]

		if data then
			local totalMoneyEarned = Money.sanitize(data.totalMoneyEarned)
			local existing = byUserId[player.UserId]

			if not existing or totalMoneyEarned > existing.totalMoneyEarned then
				byUserId[player.UserId] = {
					userId = player.UserId,
					name = player.Name,
					totalMoneyEarned = totalMoneyEarned,
				}
			end
		end
	end

	local entries = {}
	for _, entry in pairs(byUserId) do
		table.insert(entries, entry)
	end

	table.sort(entries, function(left, right)
		return left.totalMoneyEarned > right.totalMoneyEarned
	end)

	local leaderboard = {}
	for rank, entry in ipairs(entries) do
		if rank > 10 then
			break
		end

		entry.rank = rank
		table.insert(leaderboard, entry)
	end

	return leaderboard
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

	local leaderboardSuccess, leaderboardErr = pcall(function()
		lifetimeLeaderboard:SetAsync(tostring(userId), math.floor(Money.sanitize(data.totalMoneyEarned)))
	end)

	if not leaderboardSuccess then
		warn(
			"[PlayerDataService] Failed to update lifetime money leaderboard for "
				.. player.Name
				.. ": "
				.. tostring(leaderboardErr)
		)
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
	Money.sync(player, playerDataByUserId[player.UserId])
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

	if not Money.isValid(cost) then
		return false, "Invalid upgrade cost."
	end

	local currentMoney = Money.sanitize(data.money)
	Money.set(player, data, currentMoney)

	if currentMoney < cost then
		return false, "Not enough money."
	end

	local upgradeKey = UpgradeConfig.getUpgradeKey(upgradeId, context)

	Money.set(player, data, currentMoney - cost)
	data.upgradeLevels[upgradeKey] = UpgradeConfig.getLevel(data, upgradeId, context) + 1
	data.unlockedUpgrades[upgradeKey] = true
	UpgradeEffects.apply(data, upgrade, context)
	dirtyByUserId[player.UserId] = true
	fireDataUpdated(player)

	return true, clone(data)
end

function PlayerDataService.addMoney(player, amount)
	local data = playerDataByUserId[player.UserId]

	if not data then
		return false, "Data is still loading."
	end

	if not Money.isValid(amount) then
		return false, "Invalid money amount."
	end

	Money.add(player, data, amount)
	dirtyByUserId[player.UserId] = true
	fireDataUpdated(player)

	return true, clone(data)
end

function PlayerDataService.start()
	remotes = Remotes.create()

	remotes.getData.OnServerInvoke = function(player)
		local data = playerDataByUserId[player.UserId]

		if not data then
			return nil
		end

		return clone(data)
	end

	remotes.buyUpgrade.OnServerInvoke = buyUpgrade
	remotes.getLeaderboard.OnServerInvoke = function()
		return getLifetimeLeaderboard()
	end

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
