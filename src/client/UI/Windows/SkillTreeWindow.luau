local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local UpgradeConfig = require(ReplicatedStorage.Shared.UpgradeConfig)

local SkillNode = require(script.Parent.Parent.Components.SkillNode)
local TreeConnector = require(script.Parent.Parent.Components.TreeConnector)

local e = React.createElement

local function getDescriptionHeight(description)
	local length = string.len(description or "")

	if length > 64 then
		return 44
	elseif length > 38 then
		return 34
	end

	return 28
end

local function getNodeMetrics(upgrade, currentCost)
	local descriptionHeight = getDescriptionHeight(upgrade.description)
	local effectsHeight = math.max(16, #(upgrade.effects or {}) * 16)
	local costHeight = if currentCost > 0 then 18 else 0
	local height = math.max(128, 82 + descriptionHeight + effectsHeight + costHeight)

	return {
		descriptionHeight = descriptionHeight,
		effectsHeight = effectsHeight,
		costHeight = costHeight,
		height = height,
	}
end

local function getNodeState(data, upgrade, context)
	if not data then
		return "loading"
	end

	if UpgradeConfig.isMaxed(data, upgrade.id, context) then
		return "maxed"
	end

	if UpgradeConfig.canBuy(data, upgrade.id, context) then
		if UpgradeConfig.getLevel(data, upgrade.id, context) > 0 then
			return "upgradeable"
		end

		return "available"
	end

	if UpgradeConfig.hasPrerequisites(data, upgrade.id, context) and not UpgradeConfig.canAfford(data, upgrade.id, context) then
		return "unaffordable"
	end

	if UpgradeConfig.isUnlocked(data, upgrade.id, context) then
		return "owned"
	end

	return "locked"
end

local function SkillTreeWindow(props)
	local data = props.data
	local dragStartRef = React.useRef(nil)
	local offsetStartRef = React.useRef(nil)
	local draggingRef = React.useRef(false)
	local dragMovedRef = React.useRef(false)
	local offset, setOffset = React.useState(Vector2.new(400, 60))
	local errorMessage, setErrorMessage = React.useState("")
	local activeTabId, setActiveTabId = React.useState("self")

	React.useEffect(function()
		local connection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingRef.current = false
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingRef.current = true
			dragMovedRef.current = false
			dragStartRef.current = input.Position
			offsetStartRef.current = offset
		end
	end

	local function moveDrag(input)
		if draggingRef.current and input.UserInputType == Enum.UserInputType.MouseMovement then
			local dragStart = dragStartRef.current
			local offsetStart = offsetStartRef.current

			if dragStart and offsetStart then
				local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)

				if delta.Magnitude > 4 then
					dragMovedRef.current = true
				end

				setOffset(offsetStart + delta)
			end
		end
	end

	local activeTab = UpgradeConfig.Tabs[1]
	for _, tab in ipairs(UpgradeConfig.Tabs) do
		if tab.id == activeTabId then
			activeTab = tab
			break
		end
	end

	local tabUnlocked = data ~= nil and UpgradeConfig.isTabUnlocked(data, activeTab)
	local trees = if tabUnlocked then UpgradeConfig.getTreesForTab(activeTab) else {}

	local connectorChildren = {}
	local nodeChildren = {}

	for _, tree in ipairs(trees) do
		local treeOffset = offset + Vector2.new(tree.x or 0, tree.y or 0)
		local treeContext = tree.context
		local byId = {}
		local incomingCounts = {}
		local outgoingCounts = {}
		local nodeMetrics = {}

		nodeChildren["TreeTitle_" .. tree.id] = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Position = UDim2.fromOffset(treeOffset.X, treeOffset.Y - 40),
			Size = UDim2.fromOffset(260, 28),
			Text = tree.title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 35,
		})

		for _, upgrade in ipairs(tree.upgrades or {}) do
			byId[upgrade.id] = upgrade
			local level = if data then UpgradeConfig.getLevel(data, upgrade.id, treeContext) else 0
			nodeMetrics[upgrade.id] = getNodeMetrics(upgrade, UpgradeConfig.getCost(upgrade, level))
		end

		for _, upgrade in ipairs(tree.upgrades or {}) do
			for _, prerequisiteId in ipairs(UpgradeConfig.getPrerequisites(upgrade)) do
				incomingCounts[upgrade.id] = (incomingCounts[upgrade.id] or 0) + 1
				outgoingCounts[prerequisiteId] = (outgoingCounts[prerequisiteId] or 0) + 1
			end
		end

		for _, upgrade in ipairs(tree.upgrades or {}) do
			for _, prerequisiteId in ipairs(UpgradeConfig.getPrerequisites(upgrade)) do
				local prerequisite = byId[prerequisiteId]

				if prerequisite then
					local prerequisiteMetrics = nodeMetrics[prerequisite.id]
					local upgradeMetrics = nodeMetrics[upgrade.id]
					local fromBottom = prerequisite.y + treeOffset.Y + prerequisiteMetrics.height
					local toTop = upgrade.y + treeOffset.Y
					local branchY = fromBottom + (toTop - fromBottom) / 2

					if outgoingCounts[prerequisite.id] and outgoingCounts[prerequisite.id] > 1 then
						branchY = fromBottom + 32
					elseif incomingCounts[upgrade.id] and incomingCounts[upgrade.id] > 1 then
						branchY = toTop - 32
					end

					connectorChildren["Connector_" .. tree.id .. "_" .. prerequisiteId .. "_" .. upgrade.id] =
						e(TreeConnector, {
							fromUpgrade = prerequisite,
							toUpgrade = upgrade,
							offset = treeOffset,
							fromHeight = prerequisiteMetrics.height,
							toHeight = upgradeMetrics.height,
							branchY = branchY,
							active = data
								and UpgradeConfig.isUnlocked(data, prerequisite.id, treeContext)
								and UpgradeConfig.isUnlocked(data, upgrade.id, treeContext),
						})
				end
			end
		end

		for _, upgrade in ipairs(tree.upgrades or {}) do
			local metrics = nodeMetrics[upgrade.id]
			local level = if data then UpgradeConfig.getLevel(data, upgrade.id, treeContext) else 0

			nodeChildren["Node_" .. tree.id .. "_" .. UpgradeConfig.getUpgradeKey(upgrade.id, treeContext)] =
				e(SkillNode, {
					upgrade = upgrade,
					state = getNodeState(data, upgrade, treeContext),
					level = level,
					maxLevel = UpgradeConfig.getMaxLevel(upgrade),
					cost = UpgradeConfig.getCost(upgrade, level),
					height = metrics.height,
					descriptionHeight = metrics.descriptionHeight,
					effectsHeight = metrics.effectsHeight,
					costHeight = metrics.costHeight,
					x = upgrade.x + treeOffset.X,
					y = upgrade.y + treeOffset.Y,
					onDragBegin = beginDrag,
					onDragMove = moveDrag,
					wasDragged = function()
						return dragMovedRef.current
					end,
					onBuy = function(upgradeId)
						setErrorMessage("")

						local success, message = props.onBuyUpgrade(upgradeId, treeContext)
						if not success then
							setErrorMessage(message or "Could not buy upgrade.")
						end
					end,
				})
		end
	end

	local tabButtons = {}

	for index, tab in ipairs(UpgradeConfig.Tabs) do
		local unlocked = data ~= nil and UpgradeConfig.isTabUnlocked(data, tab)
		local selected = tab.id == activeTab.id

		tabButtons["Tab_" .. tab.id] = e("TextButton", {
			BackgroundColor3 = if selected then Color3.fromRGB(91, 126, 255) else Color3.fromRGB(35, 43, 68),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			LayoutOrder = index,
			Size = UDim2.fromOffset(104, 28),
			Text = if unlocked then tab.title else tab.title .. " Locked",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			ZIndex = 23,
			[ReactRoblox.Event.Activated] = function()
				setActiveTabId(tab.id)
				setErrorMessage("")
				setOffset(Vector2.new(400, 60))
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		})
	end

	local tabBarChildren = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	}

	for key, child in pairs(tabButtons) do
		tabBarChildren[key] = child
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
			Size = UDim2.fromScale(0.82, 0.82),
			ZIndex = 21,
		}, {
			SizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(1050, 720),
				MinSize = Vector2.new(720, 460),
			}),
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(85, 104, 158),
				Thickness = 2,
				Transparency = 0.25,
			}),
			Header = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(15, 19, 31),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.new(1, 0, 0, 112),
				ZIndex = 22,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 16),
				}),
				Title = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBlack,
					Position = UDim2.fromOffset(24, 14),
					Size = UDim2.new(1, -150, 0, 28),
					Text = "Upgrade Skill Tree",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 26,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 23,
				}),
				Subtitle = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.fromOffset(25, 43),
					Size = UDim2.new(1, -150, 0, 18),
					Text = if data
						then if tabUnlocked then activeTab.subtitle else UpgradeConfig.getTabLockedText(activeTab)
						else "Loading server data...",
					TextColor3 = Color3.fromRGB(162, 174, 209),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 23,
				}),
				Tabs = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(24, 76),
					Size = UDim2.new(1, -48, 0, 28),
					ZIndex = 23,
				}, tabBarChildren),
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
			}),
			TreeViewport = e("Frame", {
				Active = true,
				BackgroundColor3 = Color3.fromRGB(10, 14, 24),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.fromOffset(18, 130),
				Size = UDim2.new(1, -36, 1, -148),
				ZIndex = 30,
				[ReactRoblox.Event.InputBegan] = function(_, input)
					beginDrag(input)
				end,
				[ReactRoblox.Event.InputChanged] = function(_, input)
					moveDrag(input)
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 14),
				}),
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(54, 68, 106),
					Transparency = 0.25,
				}),
				Background = e("Frame", {
					BackgroundColor3 = Color3.fromRGB(18, 23, 38),
					BackgroundTransparency = 0.35,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 30,
				}),
				Connectors = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 31,
				}, connectorChildren),
				Nodes = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 34,
				}, nodeChildren),
				LockedMessage = if data and not tabUnlocked
					then e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -48, 0, 28),
						Text = UpgradeConfig.getTabLockedText(activeTab),
						TextColor3 = Color3.fromRGB(214, 224, 255),
						TextSize = 18,
						ZIndex = 40,
					})
					else nil,
				ErrorMessage = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamMedium,
					Position = UDim2.new(0.5, 0, 1, -12),
					Size = UDim2.new(1, -30, 0, 20),
					Text = errorMessage,
					TextColor3 = Color3.fromRGB(255, 143, 143),
					TextSize = 13,
					ZIndex = 40,
				}),
			}),
		}),
	})
end

return SkillTreeWindow
