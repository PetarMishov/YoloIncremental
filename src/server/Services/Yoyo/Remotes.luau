local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceUtils = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("Instance"))

local Remotes = {}

function Remotes.create()
	local remotesFolder = InstanceUtils.getOrCreate(ReplicatedStorage, "Folder", "Remotes")
	local yoyoFolder = InstanceUtils.getOrCreate(remotesFolder, "Folder", "Yoyo")

	return {
		YoyoHit = InstanceUtils.getOrCreate(yoyoFolder, "RemoteFunction", "YoyoHit"),
	}
end

return Remotes
