local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Format = require(script.Parent.Parent.Format)

local e = React.createElement

local function Hud(props)
	local data = props.data
	local moneyText = "Loading..."

	if data then
		moneyText = Format.money(data.money or 0)
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(16, 20, 33),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 24, 1, -24),
		Size = UDim2.fromOffset(280, 130),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(84, 104, 160),
			Transparency = 0.25,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(18, 14),
			Size = UDim2.new(1, -36, 0, 28),
			Text = moneyText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		UpgradeButton = e("TextButton", {
			BackgroundColor3 = Color3.fromRGB(91, 126, 255),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(18, 50),
			Size = UDim2.new(1, -36, 0, 30),
			Text = "Upgrades",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			[ReactRoblox.Event.Activated] = props.onOpenUpgrades,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
		YoyoButton = e("TextButton", {
			BackgroundColor3 = Color3.fromRGB(55, 68, 104),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(18, 88),
			Size = UDim2.new(1, -36, 0, 30),
			Text = "Yoyo",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			[ReactRoblox.Event.Activated] = props.onOpenYoyo,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return Hud
