local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local Format = require(script.Parent.Parent.Format)

local e = React.createElement

local function Leaderboard(props)
	local entries = props.entries or {}
	local children = {
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
			Position = UDim2.fromOffset(16, 12),
			Size = UDim2.new(1, -32, 0, 24),
			Text = "Lifetime Earned",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	}

	if props.loading then
		children.Loading = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(16, 48),
			Size = UDim2.new(1, -32, 0, 20),
			Text = "Loading...",
			TextColor3 = Color3.fromRGB(178, 190, 222),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	elseif #entries <= 0 then
		children.Empty = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(16, 48),
			Size = UDim2.new(1, -32, 0, 36),
			Text = "No earnings yet.",
			TextColor3 = Color3.fromRGB(178, 190, 222),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	else
		for index, entry in ipairs(entries) do
			local y = 44 + (index - 1) * 28

			children["Rank" .. tostring(index)] = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(16, y),
				Size = UDim2.fromOffset(34, 22),
				Text = "#" .. tostring(entry.rank or index),
				TextColor3 = Color3.fromRGB(214, 224, 255),
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			children["Name" .. tostring(index)] = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Position = UDim2.fromOffset(50, y),
				Size = UDim2.new(1, -142, 0, 22),
				Text = tostring(entry.name or "Player"),
				TextColor3 = Color3.fromRGB(232, 237, 250),
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			children["Total" .. tostring(index)] = e("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -16, 0, y),
				Size = UDim2.fromOffset(88, 22),
				Text = Format.money(entry.totalMoneyEarned or 0),
				TextColor3 = Color3.fromRGB(255, 220, 143),
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
			})
		end
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(16, 20, 33),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -24, 0, 24),
		Size = UDim2.fromOffset(300, 342),
	}, children)
end

return Leaderboard
