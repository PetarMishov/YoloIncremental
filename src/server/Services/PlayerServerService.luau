local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local PlayerServerService = {}

local MAX_TELEPORT_ATTEMPTS = 3
local RETRY_DELAY = 2

local teleportAttemptsByUserId = {}

local function isReservedServer()
	return game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
end

local function shouldRunGameplayServices()
	return RunService:IsStudio() or isReservedServer()
end

local function teleportPlayerToReservedServer(player)
	if shouldRunGameplayServices() or teleportAttemptsByUserId[player.UserId] then
		return
	end

	teleportAttemptsByUserId[player.UserId] = 0

	task.spawn(function()
		while player.Parent == Players and teleportAttemptsByUserId[player.UserId] < MAX_TELEPORT_ATTEMPTS do
			teleportAttemptsByUserId[player.UserId] += 1

			local success, err = pcall(function()
				local accessCode = TeleportService:ReserveServer(game.PlaceId)
				TeleportService:TeleportToPrivateServer(game.PlaceId, accessCode, { player })
			end)

			if success then
				return
			end

			warn(
				"[PlayerServerService] Failed to move "
					.. player.Name
					.. " to a reserved server: "
					.. tostring(err)
			)

			task.wait(RETRY_DELAY)
		end

		teleportAttemptsByUserId[player.UserId] = nil

		if player.Parent == Players then
			player:Kick("Could not move you to a private server. Please rejoin.")
		end
	end)
end

function PlayerServerService.start()
	if shouldRunGameplayServices() then
		return true
	end

	Players.PlayerAdded:Connect(teleportPlayerToReservedServer)
	Players.PlayerRemoving:Connect(function(player)
		teleportAttemptsByUserId[player.UserId] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		teleportPlayerToReservedServer(player)
	end

	return false
end

return PlayerServerService
