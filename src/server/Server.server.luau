local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local YoyoService = require(ServerScriptService.Services.YoyoService)


PlayerDataService.start()
YoyoService.start({
    playerDataService = PlayerDataService,
})