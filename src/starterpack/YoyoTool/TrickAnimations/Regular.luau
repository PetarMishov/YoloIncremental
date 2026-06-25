local RunService = game:GetService("RunService")

local Regular = {}

type RegularOptions = {
	duration: number?,
	radius: number?,
	rightOffset: number?,
	heightOffset: number?,
}

local DEFAULT_DURATION = 0.65
local DEFAULT_RADIUS = 1.75
local DEFAULT_RIGHT_OFFSET = 3.25
local DEFAULT_HEIGHT_OFFSET = 1

local function detachHandleJoints(character: Model, handle: BasePart)
	local detachedJoints = {}

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			local joint = descendant :: any

			if joint.Part0 == handle or joint.Part1 == handle then
				table.insert(detachedJoints, {
					joint = joint,
					part0 = joint.Part0,
					part1 = joint.Part1,
				})

				joint.Part0 = nil
				joint.Part1 = nil
			end
		end
	end

	return detachedJoints
end

local function restoreHandleJoints(detachedJoints)
	for _, detachedJoint in detachedJoints do
		local joint = detachedJoint.joint

		if joint.Parent then
			joint.Part0 = detachedJoint.part0
			joint.Part1 = detachedJoint.part1
		end
	end
end

function Regular.play(character: Model, handle: BasePart, options: RegularOptions?)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return nil
	end

	if handle:GetAttribute("YoyoTrickPlaying") then
		return nil
	end

	local duration = if options and options.duration then options.duration else DEFAULT_DURATION
	local radius = if options and options.radius then options.radius else DEFAULT_RADIUS
	local rightOffset = if options and options.rightOffset then options.rightOffset else DEFAULT_RIGHT_OFFSET
	local heightOffset = if options and options.heightOffset then options.heightOffset else DEFAULT_HEIGHT_OFFSET

	local startRotation = handle.CFrame - handle.Position
	local originalAnchored = handle.Anchored
	local originalCanCollide = handle.CanCollide
	local originalCanTouch = handle.CanTouch
	local originalCanQuery = handle.CanQuery
	local detachedJoints = detachHandleJoints(character, handle)
	local startTime = os.clock()
	local connection: RBXScriptConnection?

	handle:SetAttribute("YoyoTrickPlaying", true)
	handle.Anchored = true
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false

	local function finish()
		if connection then
			connection:Disconnect()
			connection = nil
		end

		if handle.Parent then
			handle.Anchored = originalAnchored
			handle.CanCollide = originalCanCollide
			handle.CanTouch = originalCanTouch
			handle.CanQuery = originalCanQuery
			restoreHandleJoints(detachedJoints)
			handle:SetAttribute("YoyoTrickPlaying", nil)
		end
	end

	connection = RunService.RenderStepped:Connect(function()
		if not handle.Parent or not root.Parent then
			finish()
			return
		end

		local elapsed = os.clock() - startTime
		local progress = math.min(elapsed / duration, 1)
		local angle = progress * math.pi * 2
		local center = root.CFrame * CFrame.new(rightOffset, heightOffset, 0)
		local circularOffset = Vector3.new(0, math.sin(angle) * radius, math.cos(angle) * radius)
		local position = center.Position + center:VectorToWorldSpace(circularOffset)

		handle.CFrame = CFrame.new(position) * startRotation

		if progress >= 1 then
			finish()
		end
	end)

	return handle
end

return Regular
