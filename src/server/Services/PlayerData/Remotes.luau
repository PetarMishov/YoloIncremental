local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceUtils = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("Instance"))

local Remotes = {}

function Remotes.create()
	local remotesFolder = InstanceUtils.getOrCreate(ReplicatedStorage, "Folder", "Remotes")
	local skillTreeFolder = InstanceUtils.getOrCreate(remotesFolder, "Folder", "SkillTree")

	return {
		dataUpdated = InstanceUtils.getOrCreate(skillTreeFolder, "RemoteEvent", "DataUpdated"),
		buyUpgrade = InstanceUtils.getOrCreate(skillTreeFolder, "RemoteFunction", "BuyUpgrade"),
		buyYoyoPart = InstanceUtils.getOrCreate(skillTreeFolder, "RemoteFunction", "BuyYoyoPart"),
		getData = InstanceUtils.getOrCreate(skillTreeFolder, "RemoteFunction", "GetData"),
		getLeaderboard = InstanceUtils.getOrCreate(skillTreeFolder, "RemoteFunction", "GetLeaderboard"),
	}
end

return Remotes
