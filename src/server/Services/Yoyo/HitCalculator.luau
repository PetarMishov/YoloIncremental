local ReplicatedStorage = game:GetService("ReplicatedStorage")

local YoyoConfig = require(ReplicatedStorage.Shared:WaitForChild("YoyoConfig"))
local YoyoMath = require(ReplicatedStorage.Shared:WaitForChild("Utils"):WaitForChild("YoyoMath"))

local HitCalculator = {}
local CREW_ASSIST_MULTIPLIER = 0.35

local function getStatsScore(character, trickMultiplier, critMultiplier)
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
	local score = getStatsScore(character, hit.trickMultiplier, hit.critMultiplier)
	local crew = if type(hit.data) == "table" then hit.data.crew else nil

	if type(crew) == "table" and type(crew.members) == "table" then
		for _, member in ipairs(crew.members) do
			if type(member) == "table" and member.stats then
				score += getStatsScore(member, nil, nil) * CREW_ASSIST_MULTIPLIER
			end
		end
	end

	return score
end

return HitCalculator
