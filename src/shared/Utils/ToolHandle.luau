local ToolHandle = {}

local DEFAULT_HANDLE_SIZE = Vector3.new(1, 1, 1)

function ToolHandle.createFromModel(model: Model): BasePart
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = DEFAULT_HANDLE_SIZE
	handle.Transparency = 1
	handle.Anchored = false
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.Massless = true
	handle.CFrame = model:GetPivot()

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = descendant
			weld.Parent = handle
		end
	end

	model.Name = "Model"
	model.Parent = handle

	return handle
end

return ToolHandle
