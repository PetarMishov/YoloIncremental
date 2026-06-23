local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent :: Tool
local currentData = nil
local nextActivationTime = 0
local requestInFlight = false
local handleAsset = ReplicatedStorage
	:WaitForChild("Assets")
	:WaitForChild("Part") :: Part

local handle = handleAsset:Clone()
handle.Name = "Handle"
handle.Parent = tool

local yoyoHit = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("Yoyo")
	:WaitForChild("YoyoHit") :: RemoteFunction
local skillTreeRemotes = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("SkillTree")
local getData = skillTreeRemotes:WaitForChild("GetData") :: RemoteFunction
local dataUpdated = skillTreeRemotes:WaitForChild("DataUpdated") :: RemoteEvent

local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local function getHitSpeed()
	if currentData and currentData.player and currentData.player.stats then
		return currentData.player.stats.hitSpeed
	end

	return 1
end

local function updateToolCooldown()
	local cooldown = YoyoMath.getHitCooldown(getHitSpeed())
	nextActivationTime = os.clock() + cooldown
	tool.Enabled = false

	task.delay(cooldown, function()
		if os.clock() >= nextActivationTime then
			tool.Enabled = true
		end
	end)
end

local function setToolCooldown(cooldown)
	local duration = math.max(cooldown, 0)
	nextActivationTime = os.clock() + duration
	tool.Enabled = false

	task.delay(duration, function()
		if os.clock() >= nextActivationTime then
			tool.Enabled = true
		end
	end)
end

task.spawn(function()
	local success, data = pcall(function()
		return getData:InvokeServer()
	end)

	if success then
		currentData = data
	end
end)

dataUpdated.OnClientEvent:Connect(function(data)
	currentData = data
end)

tool.Activated:Connect(function()
	if requestInFlight or os.clock() < nextActivationTime then
		return
	end

	requestInFlight = true
	updateToolCooldown()

	local invokeSuccess, result = pcall(function()
		return yoyoHit:InvokeServer()
	end)
	requestInFlight = false

	if not invokeSuccess then
		nextActivationTime = 0
		tool.Enabled = true
		warn("[YoyoTool] Failed to hit yoyo: " .. tostring(result))
		return
	end

	if result and result.data then
		currentData = result.data
	end

	if result and not result.success then
		if type(result.cooldown) == "number" and result.cooldown > 0 then
			setToolCooldown(result.cooldown)
		else
			nextActivationTime = 0
			tool.Enabled = true
		end
	end

	-- TODO: Play animations and shit
	print(result)
end)
