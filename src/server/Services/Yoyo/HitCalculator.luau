local ReplicatedStorage = game:GetService("ReplicatedStorage")

local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local HitCalculator = {}
local CREW_ASSIST_MULTIPLIER = 0.35

local function getStatsScore(stats, trickMultiplier, critMultiplier)
	local score = if type(stats.damage) == "number" then stats.damage else 0

	score *= YoyoMath.getMultiplier(trickMultiplier)
	score *= YoyoMath.getMultiplier(critMultiplier)

	return score
end

function HitCalculator.getScore(hit)
	local stats = hit.stats or {}
	local score = getStatsScore(stats, hit.trickMultiplier, hit.critMultiplier)
	local crew = if type(hit.data) == "table" then hit.data.crew else nil

	if type(crew) == "table" and type(crew.members) == "table" then
		for _, member in ipairs(crew.members) do
			if type(member) == "table" and member.stats then
				score += getStatsScore(member.stats, nil, nil) * CREW_ASSIST_MULTIPLIER
			end
		end
	end

	return score
end

return HitCalculator
