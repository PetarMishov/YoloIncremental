local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local Hud = require(script.Parent.Components.Hud)
local SkillTreeWindow = require(script.Parent.Windows.SkillTreeWindow)

local skillTreeRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillTree")
local getDataFunction = skillTreeRemotes:WaitForChild("GetData")
local buyUpgradeFunction = skillTreeRemotes:WaitForChild("BuyUpgrade")
local dataUpdatedEvent = skillTreeRemotes:WaitForChild("DataUpdated")

local e = React.createElement

local function App()
	local data, setData = React.useState(nil)
	local activeWindow, setActiveWindow = React.useState(nil)

	React.useEffect(function()
		local alive = true

		task.spawn(function()
			local success, result = pcall(function()
				return getDataFunction:InvokeServer()
			end)

			if alive and success and result then
				setData(result)
			end
		end)

		local connection = dataUpdatedEvent.OnClientEvent:Connect(function(newData)
			setData(newData)
		end)

		return function()
			alive = false
			connection:Disconnect()
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

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Hud = e(Hud, {
			data = data,
			onOpenUpgrades = function()
				setActiveWindow("upgrades")
			end,
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
	})
end

return App
