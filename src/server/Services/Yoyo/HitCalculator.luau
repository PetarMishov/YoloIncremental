local ReplicatedStorage = game:GetService("ReplicatedStorage")

local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local HitCalculator = {}

function HitCalculator.getScore(hit)
	local stats = hit.stats or {}
	local score = if type(stats.damage) == "number" then stats.damage else 0

	score *= YoyoMath.getMultiplier(hit.trickMultiplier)
	score *= YoyoMath.getMultiplier(hit.critMultiplier)

	return score
end

return HitCalculator
