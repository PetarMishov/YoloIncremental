local ServerScriptService = game:GetService("ServerScriptService")

local PlayerServerService = require(ServerScriptService.Services.PlayerServerService)

if not PlayerServerService.start() then
	return
end

local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local YoyoService = require(ServerScriptService.Services.YoyoService)

PlayerDataService.start()
YoyoService.start({
    playerDataService = PlayerDataService,
})
