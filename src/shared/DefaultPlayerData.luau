local DefaultPlayerData = {}

local clone = require(script.Parent:WaitForChild("Utils"):WaitForChild("Clone"))

DefaultPlayerData.VERSION = 2

local BASE_COMBAT_STATS = {
	hitSpeed = 1,
	successRate = 0.6,
	critChance = 0.05,
	damage = 10,
}

local BASE_TRICKS = {
	loop = 0,
	walkTheDog = 0,
	aroundTheWorld = 0,
	rockTheBaby = 0,
	boomerang = 0,
}

function DefaultPlayerData.createCombatStats()
	local stats = clone(BASE_COMBAT_STATS)
	stats.tricks = clone(BASE_TRICKS)

	return stats
end

function DefaultPlayerData.createCrewMember(id, name)
	return {
		id = id,
		name = name,
		stats = DefaultPlayerData.createCombatStats(),
	}
end

function DefaultPlayerData.create()
	return {
		version = DefaultPlayerData.VERSION,
		money = 1000,
		player = {
			stats = DefaultPlayerData.createCombatStats(),
		},
		crew = {
			maxSize = 4,
			members = {
				DefaultPlayerData.createCrewMember("rookie", "Rookie Spinner"),
			},
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

	if type(data.money) ~= "number" then
		data.money = 0
	end

	for upgradeId, isUnlocked in pairs(data.unlockedUpgrades) do
		if isUnlocked == true and type(data.upgradeLevels[upgradeId]) ~= "number" then
			data.upgradeLevels[upgradeId] = 1
		end
	end

	return data
end

return DefaultPlayerData
