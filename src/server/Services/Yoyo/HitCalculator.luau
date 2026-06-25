local ReplicatedStorage = game:GetService("ReplicatedStorage")

local YoyoConfig = require(ReplicatedStorage.Shared:WaitForChild("YoyoConfig"))
local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local HitCalculator = {}

function HitCalculator.getCharacterScore(character, trickMultiplier, critMultiplier)
	local stats = character.stats or {}
	local score = if type(stats.damage) == "number" then stats.damage else 0

	score += YoyoConfig.getDamage(character.yoyo)
	score *= YoyoMath.getMultiplier(trickMultiplier)
	score *= YoyoMath.getMultiplier(critMultiplier)

	return score
end

function HitCalculator.getScore(hit)
	local character = {
		stats = hit.stats or {},
		yoyo = if type(hit.data) == "table" and type(hit.data.player) == "table" then hit.data.player.yoyo else nil,
	}

	return HitCalculator.getCharacterScore(character, hit.trickMultiplier, hit.critMultiplier)
end

return HitCalculator
