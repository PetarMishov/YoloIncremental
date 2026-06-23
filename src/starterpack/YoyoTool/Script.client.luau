local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent :: Tool
local handleAsset = ReplicatedStorage
    :WaitForChild("Assets")
    :WaitForChild("Part") :: Part

local handle = handleAsset:Clone()
handle.Name = "Handle"
handle.Parent = tool

local yoyoHit = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Yoyo")
    :WaitForChild("YoyoHit") :: RemoteFunction

tool.Activated:Connect(function()
    local result = yoyoHit:InvokeServer()
    print(result)
end)