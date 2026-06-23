local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function getOrCreate(parent, className, name)
	local instance = parent:FindFirstChild(name)

	if not instance then
		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
	end

	return instance
end

function Remotes.create()
	local remotesFolder = getOrCreate(ReplicatedStorage, "Folder", "Remotes")
	local skillTreeFolder = getOrCreate(remotesFolder, "Folder", "SkillTree")

	return {
		dataUpdated = getOrCreate(skillTreeFolder, "RemoteEvent", "DataUpdated"),
		buyUpgrade = getOrCreate(skillTreeFolder, "RemoteFunction", "BuyUpgrade"),
		getData = getOrCreate(skillTreeFolder, "RemoteFunction", "GetData"),
	}
end

return Remotes
