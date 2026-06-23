local YoyoMath = {}

function YoyoMath.clampChance(value)
	if type(value) ~= "number" or value ~= value then
		return 0
	end

	return math.clamp(value, 0, 1)
end

function YoyoMath.getMultiplier(value)
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return 1
	end

	return math.max(value, 0)
end

function YoyoMath.getHitCooldown(hitSpeed)
	local speed = YoyoMath.getMultiplier(hitSpeed)

	if speed <= 0 then
		return 1
	end

	return 1 / speed
end

function YoyoMath.getTrickMultiplier(stats, trick)
	if type(stats) ~= "table" or type(stats.trickMultipliers) ~= "table" then
		return 1
	end

	return YoyoMath.getMultiplier(stats.trickMultipliers[trick])
end

return YoyoMath
