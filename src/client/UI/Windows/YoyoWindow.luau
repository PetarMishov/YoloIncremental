local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local YoyoConfig = require(ReplicatedStorage.Shared.YoyoConfig)

local Format = require(script.Parent.Parent.Format)

local e = React.createElement

local CARD_WIDTH = 318
local CARD_HEIGHT = 214
local CARD_GAP = 18
local PART_CELL_GAP = 10

local function getCharacters(data)
	local characters = {}

	if not data then
		return characters
	end

	table.insert(characters, {
		id = "player",
		name = "You",
		context = {
			scope = "self",
		},
		yoyo = if data.player then data.player.yoyo else nil,
	})

	if type(data.crew) == "table" and type(data.crew.members) == "table" then
		for _, member in ipairs(data.crew.members) do
			table.insert(characters, {
				id = member.id,
				name = member.name or member.id,
				context = {
					scope = "crew",
					memberId = member.id,
				},
				yoyo = member.yoyo,
			})
		end
	end

	return characters
end

local function getPartState(yoyo, part)
	local currentTierId = if type(yoyo) == "table" then yoyo[part] else nil
	local currentTier = YoyoConfig.getTier(part, currentTierId)
	local nextTier = YoyoConfig.getNextTier(part, currentTierId)

	return currentTier, nextTier
end

local function makePartCell(props)
	local currentTier, nextTier = getPartState(props.yoyo, props.part)
	local canBuy = nextTier ~= nil
	local affordable = canBuy and (props.money or 0) >= (nextTier.cost or 0)
	local cellColor = if canBuy
		then if affordable then Color3.fromRGB(31, 45, 76) else Color3.fromRGB(54, 43, 28)
		else Color3.fromRGB(31, 59, 48)
	local strokeColor = if canBuy
		then if affordable then Color3.fromRGB(108, 157, 255) else Color3.fromRGB(184, 130, 55)
		else Color3.fromRGB(117, 255, 200)

	return e("Frame", {
		BackgroundColor3 = cellColor,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0.5, -PART_CELL_GAP / 2, 1, 0),
		ZIndex = 32,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Stroke = e("UIStroke", {
			Color = strokeColor,
			Transparency = 0.2,
		}),
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 20),
			Text = props.label,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 33,
		}),
		Current = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Current: " .. currentTier.label,
			TextColor3 = Color3.fromRGB(214, 224, 255),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 33,
		}),
		Damage = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(0, 44),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Base damage: " .. Format.number(currentTier.damage or 0),
			TextColor3 = Color3.fromRGB(255, 220, 143),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 33,
		}),
		Next = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(0, 66),
			Size = UDim2.new(1, 0, 0, 34),
			Text = if nextTier
				then "Next: " .. nextTier.label .. "\nDamage: " .. Format.number(nextTier.damage or 0)
				else "Max tier reached",
			TextColor3 = Color3.fromRGB(178, 190, 222),
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 33,
		}),
		Price = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 104),
			Size = UDim2.new(1, 0, 0, 18),
			Text = if nextTier then "Price: " .. Format.money(nextTier.cost or 0) else "Price: -",
			TextColor3 = if not canBuy or affordable then Color3.fromRGB(255, 220, 143) else Color3.fromRGB(255, 175, 105),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 33,
		}),
		Button = e("TextButton", {
			AutoButtonColor = canBuy,
			BackgroundColor3 = if canBuy then Color3.fromRGB(91, 126, 255) else Color3.fromRGB(70, 199, 151),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, 0, 1, -30),
			Size = UDim2.new(1, 0, 0, 30),
			Text = if nextTier then "Upgrade to " .. nextTier.label else "MAX",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 11,
			ZIndex = 34,
			[ReactRoblox.Event.Activated] = function()
				if canBuy then
					props.onBuy(props.part, props.context)
				end
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

local function makeCharacterCard(character, index, money, onBuy)
	local column = (index - 1) % 2
	local row = math.floor((index - 1) / 2)
	local yoyo = character.yoyo or YoyoConfig.createDefault()

	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(20, 26, 42),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(column * (CARD_WIDTH + CARD_GAP), row * (CARD_HEIGHT + CARD_GAP)),
		Size = UDim2.fromOffset(CARD_WIDTH, CARD_HEIGHT),
		ZIndex = 31,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(77, 95, 143),
			Transparency = 0.25,
		}),
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 22),
			Text = character.name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 32,
		}),
		Current = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(0, 26),
			Size = UDim2.new(1, 0, 0, 20),
			Text = "Body + string damage are added together.",
			TextColor3 = Color3.fromRGB(178, 190, 222),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 32,
		}),
		Damage = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 48),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Total yoyo base damage: " .. Format.number(YoyoConfig.getDamage(yoyo)),
			TextColor3 = Color3.fromRGB(255, 220, 143),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 32,
		}),
		Parts = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 76),
			Size = UDim2.new(1, 0, 1, -76),
			ZIndex = 32,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, PART_CELL_GAP),
			}),
			Body = makePartCell({
				label = "Body",
				part = YoyoConfig.Part.Body,
				yoyo = yoyo,
				money = money,
				context = character.context,
				layoutOrder = 1,
				onBuy = onBuy,
			}),
			String = makePartCell({
				label = "String",
				part = YoyoConfig.Part.String,
				yoyo = yoyo,
				money = money,
				context = character.context,
				layoutOrder = 2,
				onBuy = onBuy,
			}),
		}),
	})
end

local function YoyoWindow(props)
	local data = props.data
	local errorMessage, setErrorMessage = React.useState("")
	local characters = getCharacters(data)
	local rowCount = math.ceil(#characters / 2)
	local contentHeight = math.max(rowCount * CARD_HEIGHT + math.max(rowCount - 1, 0) * CARD_GAP, 1)
	local cardChildren = {}
	local money = if data then data.money or 0 else 0

	for index, character in ipairs(characters) do
		cardChildren["Character_" .. tostring(character.id)] = makeCharacterCard(character, index, money, function(part, context)
			setErrorMessage("")

			local success, message = props.onBuyYoyoPart(part, context)
			if not success then
				setErrorMessage(message or "Could not upgrade yoyo.")
			end
		end)
	end

	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(6, 8, 14),
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 20,
	}, {
		Panel = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(12, 16, 27),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.72, 0.72),
			ZIndex = 21,
		}, {
			SizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(760, 620),
				MinSize = Vector2.new(680, 430),
			}),
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(85, 104, 158),
				Thickness = 2,
				Transparency = 0.25,
			}),
			Title = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Position = UDim2.fromOffset(24, 18),
				Size = UDim2.new(1, -140, 0, 32),
				Text = "Yoyo",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 28,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 23,
			}),
			Close = e("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(45, 55, 84),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -24, 0, 19),
				Size = UDim2.fromOffset(86, 34),
				Text = "Close",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				ZIndex = 23,
				[ReactRoblox.Event.Activated] = props.onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
			Scroll = e("ScrollingFrame", {
				Active = true,
				BackgroundColor3 = Color3.fromRGB(10, 14, 24),
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, contentHeight),
				Position = UDim2.fromOffset(24, 68),
				ScrollBarThickness = 8,
				Size = UDim2.new(1, -48, 1, -112),
				ZIndex = 30,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 14),
				}),
				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 14),
					PaddingLeft = UDim.new(0, 14),
				}),
				Cards = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(CARD_WIDTH * 2 + CARD_GAP, contentHeight),
					ZIndex = 31,
				}, cardChildren),
			}),
			ErrorMessage = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Position = UDim2.new(0.5, 0, 1, -12),
				Size = UDim2.new(1, -48, 0, 20),
				Text = errorMessage,
				TextColor3 = Color3.fromRGB(255, 143, 143),
				TextSize = 13,
				ZIndex = 40,
			}),
		}),
	})
end

return YoyoWindow
