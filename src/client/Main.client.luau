local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("YoyoExampleHud")
if existingGui then
	existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YoyoExampleHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local e = React.createElement

local function StatPill(props)
	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(31, 39, 61),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(118, 44),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(74, 91, 135),
			Thickness = 1,
			Transparency = 0.45,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(12, 6),
			Size = UDim2.new(1, -24, 0, 14),
			Text = props.label,
			TextColor3 = Color3.fromRGB(159, 173, 207),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Value = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(12, 20),
			Size = UDim2.new(1, -24, 0, 18),
			Text = props.value,
			TextColor3 = Color3.fromRGB(244, 248, 255),
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

local function App()
	local coins, setCoins = React.useState(1250)
	local level, setLevel = React.useState(7)

	local progress = math.clamp((coins % 1000) / 1000, 0, 1)
	local perClick = level * 25

	local function collect()
		setCoins(function(currentCoins)
			local nextCoins = currentCoins + perClick

			if math.floor(nextCoins / 1000) > math.floor(currentCoins / 1000) then
				setLevel(function(currentLevel)
					return currentLevel + 1
				end)
			end

			return nextCoins
		end)
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(16, 20, 33),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(430, 320),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 18),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(91, 116, 181),
			Thickness = 2,
			Transparency = 0.25,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(24, 22),
			Size = UDim2.new(1, -48, 0, 32),
			Text = "YOYO WORKSHOP",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 26,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Subtitle = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(24, 60),
			Size = UDim2.new(1, -48, 0, 22),
			Text = "Collect coins, level up, and unlock faster throws.",
			TextColor3 = Color3.fromRGB(169, 181, 211),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Coins = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(24, 104),
			Size = UDim2.new(1, -48, 0, 46),
			Text = tostring(coins) .. " coins",
			TextColor3 = Color3.fromRGB(255, 213, 99),
			TextSize = 38,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		ProgressBack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(36, 45, 70),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 164),
			Size = UDim2.new(1, -48, 0, 14),
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			ProgressFill = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(85, 220, 170),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progress, 1),
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
		}),
		Stats = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(24, 198),
			Size = UDim2.new(1, -48, 0, 44),
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Level = e(StatPill, {
				layoutOrder = 1,
				label = "LEVEL",
				value = tostring(level),
			}),
			Power = e(StatPill, {
				layoutOrder = 2,
				label = "PER THROW",
				value = "+" .. tostring(perClick),
			}),
			Rank = e(StatPill, {
				layoutOrder = 3,
				label = "RANK",
				value = if level >= 10 then "Pro" else "Rookie",
			}),
		}),
		Button = e("TextButton", {
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(91, 126, 255),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(24, 264),
			Size = UDim2.new(1, -48, 0, 42),
			Text = "Throw yoyo",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 17,
			[ReactRoblox.Event.Activated] = collect,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),
	})
end

local root = ReactRoblox.createRoot(screenGui)
root:render(e(App))

script.Destroying:Connect(function()
	root:unmount()
	screenGui:Destroy()
end)
