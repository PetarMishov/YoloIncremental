local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Format = require(script.Parent.Parent.Format)

local e = React.createElement
local NODE_WIDTH = 188

local function SkillNode(props)
	local upgrade = props.upgrade
	local state = props.state
	local isUpgradeable = state == "upgradeable"
	local isOwned = state == "owned" or state == "maxed" or isUpgradeable
	local isAvailable = state == "available"
	local isUnaffordable = state == "unaffordable"
	local isMaxed = state == "maxed"
	local canBuy = isAvailable or isUpgradeable
	local glowPulse, setGlowPulse = React.useState(0)
	local color = Color3.fromRGB(43, 51, 77)
	local strokeColor = Color3.fromRGB(82, 99, 145)
	local titleColor = Color3.fromRGB(232, 237, 250)
	local badgeColor = Color3.fromRGB(68, 79, 112)

	React.useEffect(function()
		if not isUpgradeable then
			setGlowPulse(0)
			return nil
		end

		local alive = true

		task.spawn(function()
			while alive do
				setGlowPulse((math.sin(os.clock() * 4) + 1) / 2)
				task.wait(0.05)
			end
		end)

		return function()
			alive = false
		end
	end, { isUpgradeable })

	if isMaxed then
		color = Color3.fromRGB(30, 104, 81)
		strokeColor = Color3.fromRGB(117, 255, 200)
		badgeColor = Color3.fromRGB(70, 199, 151)
	elseif isOwned then
		color = Color3.fromRGB(46, 74, 115)
		strokeColor = Color3.fromRGB(108, 157, 255)
		badgeColor = Color3.fromRGB(88, 130, 231)
	elseif isAvailable then
		color = Color3.fromRGB(86, 61, 24)
		strokeColor = Color3.fromRGB(255, 194, 94)
		badgeColor = Color3.fromRGB(236, 157, 49)
	elseif isUnaffordable then
		color = Color3.fromRGB(61, 49, 34)
		strokeColor = Color3.fromRGB(184, 130, 55)
		badgeColor = Color3.fromRGB(142, 92, 40)
	else
		color = Color3.fromRGB(34, 38, 54)
		strokeColor = Color3.fromRGB(68, 76, 105)
		titleColor = Color3.fromRGB(144, 153, 181)
	end

	if isUpgradeable then
		strokeColor = Color3.fromRGB(
			108 + math.floor(glowPulse * 70),
			157 + math.floor(glowPulse * 60),
			255
		)
	end

	local strokeThickness = if isUpgradeable then 2 + glowPulse * 2 elseif isAvailable then 2 else 1
	local strokeTransparency = if isUpgradeable
		then 0.3 - glowPulse * 0.24
		elseif state == "locked" then 0.55
		else 0.15

	local effectChildren = {}
	effectChildren.Layout = e("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),
	})

	for index, effect in ipairs(upgrade.effects or {}) do
		effectChildren["Effect" .. tostring(index)] = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, 16),
			Text = Format.leveledEffect(effect, props.level, props.maxLevel),
			TextColor3 = Color3.fromRGB(189, 202, 235),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 35,
		})
	end

	return e("TextButton", {
		Active = true,
		AutoButtonColor = canBuy,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(props.x, props.y),
		Size = UDim2.fromOffset(NODE_WIDTH, props.height),
		Text = "",
		ZIndex = 34,
		[ReactRoblox.Event.InputBegan] = function(_, input)
			props.onDragBegin(input)
		end,
		[ReactRoblox.Event.InputChanged] = function(_, input)
			props.onDragMove(input)
		end,
		[ReactRoblox.Event.Activated] = function()
			if canBuy and not props.wasDragged() then
				props.onBuy(upgrade.id)
			end
		end,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Stroke = e("UIStroke", {
			Color = strokeColor,
			Thickness = strokeThickness,
			Transparency = strokeTransparency,
		}),
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, -54, 0, 20),
			Text = upgrade.title,
			TextColor3 = titleColor,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 35,
		}),
		Level = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(1, 0, 0, 1),
			Size = UDim2.fromOffset(52, 18),
			Text = "Lv " .. tostring(props.level) .. "/" .. tostring(props.maxLevel),
			TextColor3 = Color3.fromRGB(214, 224, 255),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 35,
		}),
		Description = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(0, 22),
			Size = UDim2.new(1, 0, 0, props.descriptionHeight),
			Text = upgrade.description,
			TextColor3 = Color3.fromRGB(166, 177, 207),
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 35,
		}),
		Effects = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 30 + props.descriptionHeight),
			Size = UDim2.new(1, 0, 0, props.effectsHeight),
			ZIndex = 35,
		}, effectChildren),
		Cost = if (upgrade.cost or 0) > 0
			then e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(0, 32 + props.descriptionHeight + props.effectsHeight),
				Size = UDim2.new(1, -78, 0, props.costHeight),
				Text = "Cost: " .. Format.money(upgrade.cost),
				TextColor3 = if isUnaffordable then Color3.fromRGB(255, 175, 105) else Color3.fromRGB(255, 220, 143),
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 35,
			})
			else nil,
		Badge = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = badgeColor,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.fromOffset(72, 22),
			Text = if isMaxed
				then "MAX"
				elseif isAvailable then "BUY"
				elseif isUpgradeable then "LEVEL UP"
				elseif isOwned then "OWNED"
				elseif isUnaffordable then "NEED $"
				else "LOCKED",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 10,
			ZIndex = 36,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return SkillNode
