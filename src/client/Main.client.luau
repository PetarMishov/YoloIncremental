local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local App = require(script.Parent.UI.App)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("YoyoSkillTreeHud")
if existingGui then
	existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YoyoSkillTreeHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local root = ReactRoblox.createRoot(screenGui)
root:render(React.createElement(App))

script.Destroying:Connect(function()
	root:unmount()
	screenGui:Destroy()
end)
