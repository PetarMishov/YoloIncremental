local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

local Hud = require(script.Parent.Components.Hud)
local Leaderboard = require(script.Parent.Components.Leaderboard)
local SkillTreeWindow = require(script.Parent.Windows.SkillTreeWindow)
local YoyoWindow = require(script.Parent.Windows.YoyoWindow)

local skillTreeRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillTree")
local getDataFunction = skillTreeRemotes:WaitForChild("GetData")
local buyUpgradeFunction = skillTreeRemotes:WaitForChild("BuyUpgrade")
local buyYoyoPartFunction = skillTreeRemotes:WaitForChild("BuyYoyoPart")
local getLeaderboardFunction = skillTreeRemotes:WaitForChild("GetLeaderboard")
local dataUpdatedEvent = skillTreeRemotes:WaitForChild("DataUpdated")

local e = React.createElement
local CLOSE_WINDOW_ACTION = "CloseYoyoIncrementalWindow"
local TOGGLE_UPGRADES_ACTION = "ToggleYoyoIncrementalUpgrades"
local TOGGLE_YOYO_ACTION = "ToggleYoyoIncrementalYoyo"
local CLOSE_WINDOW_PRIORITY = 100000
local WINDOW_TOGGLE_PRIORITY = 2000

local function App()
	local data, setData = React.useState(nil)
	local leaderboard, setLeaderboard = React.useState({})
	local leaderboardLoading, setLeaderboardLoading = React.useState(true)
	local activeWindow, setActiveWindow = React.useState(nil)

	React.useEffect(function()
		local alive = true

		local function refreshLeaderboard()
			local success, result = pcall(function()
				return getLeaderboardFunction:InvokeServer()
			end)

			if alive then
				setLeaderboardLoading(false)

				if success and type(result) == "table" then
					setLeaderboard(result)
				end
			end
		end

		task.spawn(function()
			local success, result = pcall(function()
				return getDataFunction:InvokeServer()
			end)

			if alive and success and result then
				setData(result)
			end
		end)

		task.spawn(function()
			while alive do
				refreshLeaderboard()
				task.wait(30)
			end
		end)

		local connection = dataUpdatedEvent.OnClientEvent:Connect(function(newData)
			setData(newData)
			task.spawn(refreshLeaderboard)
		end)

		return function()
			alive = false
			connection:Disconnect()
		end
	end, {})

	React.useEffect(function()
		if not activeWindow then
			ContextActionService:UnbindAction(CLOSE_WINDOW_ACTION)
			return nil
		end

		local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
				setActiveWindow(nil)
			end
		end)

		ContextActionService:BindActionAtPriority(CLOSE_WINDOW_ACTION, function(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				setActiveWindow(nil)
			end

			return Enum.ContextActionResult.Sink
		end, false, CLOSE_WINDOW_PRIORITY, Enum.KeyCode.Escape)

		return function()
			inputConnection:Disconnect()
			ContextActionService:UnbindAction(CLOSE_WINDOW_ACTION)
		end
	end, { activeWindow })

	React.useEffect(function()
		ContextActionService:BindActionAtPriority(TOGGLE_UPGRADES_ACTION, function(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				setActiveWindow(function(currentWindow)
					return if currentWindow == "upgrades" then nil else "upgrades"
				end)
			end

			return Enum.ContextActionResult.Sink
		end, false, WINDOW_TOGGLE_PRIORITY, Enum.KeyCode.E)

		ContextActionService:BindActionAtPriority(TOGGLE_YOYO_ACTION, function(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				setActiveWindow(function(currentWindow)
					return if currentWindow == "yoyo" then nil else "yoyo"
				end)
			end

			return Enum.ContextActionResult.Sink
		end, false, WINDOW_TOGGLE_PRIORITY, Enum.KeyCode.Q)

		return function()
			ContextActionService:UnbindAction(TOGGLE_UPGRADES_ACTION)
			ContextActionService:UnbindAction(TOGGLE_YOYO_ACTION)
		end
	end, {})

	local function buyUpgrade(upgradeId, context)
		local success, serverSuccess, serverResult = pcall(function()
			return buyUpgradeFunction:InvokeServer(upgradeId, context)
		end)

		if not success then
			return false, "Purchase failed: " .. tostring(serverSuccess)
		end

		if serverSuccess ~= true then
			return false, tostring(serverResult)
		end

		if type(serverResult) == "table" then
			setData(serverResult)
		end

		return true, nil
	end

	local function buyYoyoPart(part, context)
		local success, serverSuccess, serverResult = pcall(function()
			return buyYoyoPartFunction:InvokeServer(part, context)
		end)

		if not success then
			return false, "Purchase failed: " .. tostring(serverSuccess)
		end

		if serverSuccess ~= true then
			return false, tostring(serverResult)
		end

		if type(serverResult) == "table" then
			setData(serverResult)
		end

		return true, nil
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Hud = e(Hud, {
			data = data,
			onOpenUpgrades = function()
				setActiveWindow("upgrades")
			end,
			onOpenYoyo = function()
				setActiveWindow("yoyo")
			end,
		}),
		Leaderboard = e(Leaderboard, {
			entries = leaderboard,
			loading = leaderboardLoading,
		}),
		SkillTree = if activeWindow == "upgrades"
			then e(SkillTreeWindow, {
				data = data,
				onClose = function()
					setActiveWindow(nil)
				end,
				onBuyUpgrade = buyUpgrade,
			})
			else nil,
		Yoyo = if activeWindow == "yoyo"
			then e(YoyoWindow, {
				data = data,
				onClose = function()
					setActiveWindow(nil)
				end,
				onBuyYoyoPart = buyYoyoPart,
			})
			else nil,
	})
end

return App
