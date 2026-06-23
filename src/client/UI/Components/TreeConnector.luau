local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local NODE_WIDTH = 188
local LINE_THICKNESS = 3

local function lineSegment(x, y, width, height, color)
	if width <= 0 or height <= 0 then
		return nil
	end

	return e("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
		ZIndex = 31,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

local function TreeConnector(props)
	local fromUpgrade = props.fromUpgrade
	local toUpgrade = props.toUpgrade
	local offset = props.offset
	local color = if props.active then Color3.fromRGB(85, 220, 170) else Color3.fromRGB(74, 86, 121)

	local fromX = fromUpgrade.x + offset.X + NODE_WIDTH / 2
	local fromY = fromUpgrade.y + offset.Y + props.fromHeight
	local toX = toUpgrade.x + offset.X + NODE_WIDTH / 2
	local toY = toUpgrade.y + offset.Y
	local branchY = props.branchY or fromY + (toY - fromY) / 2
	local halfThickness = LINE_THICKNESS / 2
	local minX = math.min(fromX, toX)
	local maxX = math.max(fromX, toX)

	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 31,
	}, {
		FromVertical = lineSegment(
			fromX - halfThickness,
			math.min(fromY, branchY),
			LINE_THICKNESS,
			math.abs(branchY - fromY),
			color
		),
		Horizontal = lineSegment(
			minX,
			branchY - halfThickness,
			maxX - minX,
			LINE_THICKNESS,
			color
		),
		ToVertical = lineSegment(
			toX - halfThickness,
			math.min(branchY, toY),
			LINE_THICKNESS,
			math.abs(toY - branchY),
			color
		),
	})
end

return TreeConnector
