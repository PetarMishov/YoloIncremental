local InstanceUtils = {}

function InstanceUtils.getOrCreate(parent, className, name)
	local instance = parent:FindFirstChild(name)

	if not instance then
		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
	end

	return instance
end

return InstanceUtils
