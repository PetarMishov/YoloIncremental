local DefaultPlayerData = {}

local clone = require(script.Parent:WaitForChild("Utils"):WaitForChild("Clone"))
local YoyoConfig = require(script.Parent:WaitForChild("YoyoConfig"))

DefaultPlayerData.VERSION = 6
local MAX_MONEY = 9007199254740991

local BASE_COMBAT_STATS = {
	hitSpeed = 1,
	successRate = 0.7,
	critChance = 0.03,
	critMultiplier = 1.75,
	damage = 0,
}

local BASE_TRICKS = {
	loop = 0,
	walkTheDog = 0,
	aroundTheWorld = 0,
	rockTheBaby = 0,
	boomerang = 0,
}

local BASE_TRICK_MULTIPLIERS = {
	loop = 1.4,
	walkTheDog = 1.7,
	aroundTheWorld = 2.1,
	rockTheBaby = 2.7,
	boomerang = 3.5,
}

local function sanitizeMoney(value)
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge or value < 0 then
		return 0
	end

	return math.min(value, MAX_MONEY)
end

function DefaultPlayerData.createCombatStats()
	local stats = clone(BASE_COMBAT_STATS)
	stats.tricks = clone(BASE_TRICKS)
	stats.trickMultipliers = clone(BASE_TRICK_MULTIPLIERS)

	return stats
end

function DefaultPlayerData.createCrewMember(id, name)
	return {
		id = id,
		name = name,
		yoyo = YoyoConfig.createDefault(),
		stats = DefaultPlayerData.createCombatStats(),
	}
end

function DefaultPlayerData.create()
	return {
		version = DefaultPlayerData.VERSION,
		money = 0,
		totalMoneyEarned = 0,
		player = {
			yoyo = YoyoConfig.createDefault(),
			stats = DefaultPlayerData.createCombatStats(),
		},
		crew = {
			maxSize = 4,
			members = {},
		},
		upgradeLevels = {},
		unlockedUpgrades = {},
	}
end

function DefaultPlayerData.merge(savedData)
	local data = DefaultPlayerData.create()

	if type(savedData) ~= "table" then
		return data
	end

	local function mergeInto(target, source)
		for key, value in pairs(source) do
			if type(value) == "table" and type(target[key]) == "table" then
				mergeInto(target[key], value)
			else
				target[key] = value
			end
		end
	end

	mergeInto(data, savedData)
	data.version = DefaultPlayerData.VERSION

	if type(data.unlockedUpgrades) ~= "table" then
		data.unlockedUpgrades = {}
	end

	if type(data.upgradeLevels) ~= "table" then
		data.upgradeLevels = {}
	end

	if type(data.player) ~= "table" then
		data.player = {
			yoyo = YoyoConfig.createDefault(),
			stats = DefaultPlayerData.createCombatStats(),
		}
	elseif type(data.player.yoyo) ~= "table" then
		data.player.yoyo = YoyoConfig.createDefault()
	end

	if type(data.crew) == "table" and type(data.crew.members) == "table" then
		for _, member in ipairs(data.crew.members) do
			if type(member) == "table" and type(member.yoyo) ~= "table" then
				member.yoyo = YoyoConfig.createDefault()
			end
		end
	end

	data.money = sanitizeMoney(data.money)
	data.totalMoneyEarned = sanitizeMoney(data.totalMoneyEarned)

	if data.totalMoneyEarned < data.money then
		data.totalMoneyEarned = data.money
	end

	for upgradeId, isUnlocked in pairs(data.unlockedUpgrades) do
		if isUnlocked == true and type(data.upgradeLevels[upgradeId]) ~= "number" then
			data.upgradeLevels[upgradeId] = 1
		end
	end

	return data
end

return DefaultPlayerData
