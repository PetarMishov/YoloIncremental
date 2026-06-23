local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(script.Parent.Yoyo.Remotes)
local HitCalculator = require(script.Parent.Yoyo.HitCalculator)
local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local YoyoService = {}


local remotes
local playerDataService

local function getTrick(trickThresholds)
	if type(trickThresholds) ~= "table" then
		return nil
	end

	local trickIds = {}
	for trickId, threshold in pairs(trickThresholds) do
		if type(trickId) == "string" and YoyoMath.clampChance(threshold) > 0 then
			table.insert(trickIds, trickId)
		end
	end

	table.sort(trickIds)

	local roll = math.random()
	local cumulativeThreshold = 0

	for _, trickId in ipairs(trickIds) do
		cumulativeThreshold += YoyoMath.clampChance(trickThresholds[trickId])

		if roll <= cumulativeThreshold then
			return trickId
		end
	end

	return nil
end

function YoyoService.start(dependencies)
	playerDataService = dependencies.playerDataService or dependencies.PlayerDataService
	assert(playerDataService, "YoyoService requires PlayerDataService")
	assert(playerDataService.getData, "PlayerDataService.getData is required")
	assert(playerDataService.addMoney, "PlayerDataService.addMoney is required")

	remotes = Remotes.create()

	remotes.YoyoHit.OnServerInvoke = function(player)
		local data = playerDataService.getData(player)

		if not data then
			return {
				success = false,
				message = "Data is still loading.",
			}
		end

		local stats = data.player.stats
		local successful = math.random() <= YoyoMath.clampChance(stats.successRate)
		local trick = if successful then getTrick(stats.tricks) else nil
		local critical = successful and math.random() <= YoyoMath.clampChance(stats.critChance)
		local trickMultiplier = if trick then YoyoMath.getTrickMultiplier(stats, trick) else nil
		local critMultiplier = if critical then YoyoMath.getMultiplier(stats.critMultiplier) else nil
		local score = if successful
			then HitCalculator.getScore({
				player = player,
				data = data,
				stats = stats,
				trickMultiplier = trickMultiplier,
				critMultiplier = critMultiplier,
			})
			else 0

		local addMoneySuccess, result = playerDataService.addMoney(player, score)

		if not addMoneySuccess then
			return {
				success = false,
				message = result,
			}
		end

		return {
			success = true,
			score = score,
			trick = trick,
			trickMultiplier = trickMultiplier,
			critical = critical,
			critMultiplier = critMultiplier,
			data = result,
		}
	end

end

return YoyoService
