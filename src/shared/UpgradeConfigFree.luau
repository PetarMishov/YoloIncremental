local UpgradeConfig = {}

UpgradeConfig.Stats = {
	{
		id = "hitSpeed",
		label = "Hit Speed",
	},
	{
		id = "successRate",
		label = "Success Rate",
	},
	{
		id = "critChance",
		label = "Crit Chance",
	},
	{
		id = "critMultiplier",
		label = "Crit Multiplier",
	},
	{
		id = "damage",
		label = "Damage",
	},
}

UpgradeConfig.Tricks = {
	{
		id = "loop",
		label = "Loop",
	},
	{
		id = "walkTheDog",
		label = "Walk the Dog",
	},
	{
		id = "aroundTheWorld",
		label = "Around the World",
	},
	{
		id = "rockTheBaby",
		label = "Rock the Baby",
	},
	{
		id = "boomerang",
		label = "Boomerang",
	},
}

UpgradeConfig.CrewSlots = {
	{
		memberId = "rookie",
		memberName = "Rookie Spinner",
		title = "Rookie",
	},
	{
		memberId = "strategist",
		memberName = "String Strategist",
		title = "Strategist",
	},
	{
		memberId = "technician",
		memberName = "Yoyo Technician",
		title = "Technician",
	},
	{
		memberId = "champion",
		memberName = "Street Champion",
		title = "Champion",
	},
}

local SelfUpgrades = {
	{
		id = "player_foundation",
		title = "Player Foundation",
		description = "A basic personal stat package.",
		cost = 0,
		costGrowth = 1.55,
		x = 0,
		y = 0,
		effects = {
			{
				target = "player",
				stat = "damage",
				amount = 0.8,
			},
			{
				target = "player",
				stat = "hitSpeed",
				amount = 0.05,
			},
		},
	},
	{
		id = "quick_wrists",
		title = "Quick Wrists",
		description = "Increase your hit speed.",
		cost = 0,
		costGrowth = 1.65,
		x = -260,
		y = 150,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "hitSpeed",
				amount = 0.08,
			},
		},
	},
	{
		id = "steady_form",
		title = "Steady Form",
		description = "Increase your success rate.",
		cost = 0,
		costGrowth = 1.7,
		x = 0,
		y = 160,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "successRate",
				amount = 0.03,
			},
		},
	},
	{
		id = "sharp_snap",
		title = "Sharp Snap",
		description = "Increase your critical chance.",
		cost = 0,
		costGrowth = 1.75,
		x = 260,
		y = 150,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "critChance",
				amount = 0.018,
			},
		},
	},
	{
		id = "heavy_yoyo",
		title = "Heavy Yoyo",
		description = "Increase your base damage.",
		cost = 0,
		costGrowth = 1.85,
		x = -180,
		y = 320,
		prerequisites = {
			"quick_wrists",
			"steady_form",
		},
		effects = {
			{
				target = "player",
				stat = "damage",
				amount = 1.6,
			},
		},
	},
	{
		id = "combo_focus",
		title = "Combo Focus",
		description = "Better speed and critical chance together.",
		cost = 0,
		costGrowth = 1.9,
		x = 120,
		y = 330,
		prerequisites = {
			"steady_form",
			"sharp_snap",
		},
		effects = {
			{
				target = "player",
				stat = "hitSpeed",
				amount = 0.06,
			},
			{
				target = "player",
				stat = "critChance",
				amount = 0.015,
			},
		},
	},
	{
		id = "crew_leadership",
		title = "Crew Leadership",
		description = "Unlock crew upgrade trees at level 1.",
		cost = 0,
		costGrowth = 2,
		x = -440,
		y = 500,
		prerequisites = {
			"heavy_yoyo",
		},
		maxLevel = 5,
		effects = {
			{
				target = "player",
				stat = "successRate",
				amount = 0.012,
			},
		},
	},
	{
		id = "loop_trick",
		title = "Loop Trick",
		description = "Unlock a chance to perform Loop.",
		cost = 0,
		costGrowth = 1.85,
		x = 380,
		y = 510,
		prerequisites = {
			"sharp_snap",
		},
		effects = {
			{
				target = "player",
				trick = "loop",
				amount = 0.045,
			},
		},
	},
	{
		id = "walk_dog_trick",
		title = "Walk the Dog",
		description = "Unlock a chance to perform Walk the Dog.",
		cost = 0,
		costGrowth = 1.95,
		x = 590,
		y = 680,
		prerequisites = {
			"loop_trick",
		},
		effects = {
			{
				target = "player",
				trick = "walkTheDog",
				amount = 0.035,
			},
		},
	},
	{
		id = "world_trick",
		title = "Around the World",
		description = "Unlock a chance to perform Around the World.",
		cost = 0,
		costGrowth = 2,
		x = 320,
		y = 700,
		prerequisites = {
			"loop_trick",
		},
		effects = {
			{
				target = "player",
				trick = "aroundTheWorld",
				amount = 0.03,
			},
		},
	},
	{
		id = "advanced_tricks",
		title = "Advanced Tricks",
		description = "Unlock Rock the Baby and Boomerang chances.",
		cost = 0,
		costGrowth = 2.1,
		x = 460,
		y = 890,
		prerequisites = {
			"walk_dog_trick",
			"world_trick",
		},
		effects = {
			{
				target = "player",
				trick = "rockTheBaby",
				amount = 0.022,
			},
			{
				target = "player",
				trick = "boomerang",
				amount = 0.014,
			},
		},
	},
	{
		id = "mastery",
		title = "Personal Mastery",
		description = "A large late-tree boost for your own stats.",
		cost = 0,
		costGrowth = 2.25,
		x = 0,
		y = 1080,
		prerequisites = {
			"heavy_yoyo",
			"combo_focus",
			"advanced_tricks",
		},
		effects = {
			{
				target = "player",
				stat = "damage",
				amount = 3.5,
			},
			{
				target = "player",
				stat = "successRate",
				amount = 0.018,
			},
		},
	},
}

local CrewUpgrades = {
	{
		id = "crew_recruit",
		title = "Recruit",
		description = "Add this crew member to your team.",
		cost = 0,
		x = 0,
		y = 0,
		maxLevel = 1,
		effects = {
			{
				target = "crewMember",
				action = "addMember",
			},
		},
	},
	{
		id = "crew_training",
		title = "Training",
		description = "Increase this member's damage and success rate.",
		cost = 0,
		costGrowth = 1.9,
		x = -170,
		y = 170,
		prerequisites = {
			"crew_recruit",
		},
		effects = {
			{
				target = "crewMember",
				stat = "damage",
				amount = 1.2,
			},
			{
				target = "crewMember",
				stat = "successRate",
				amount = 0.025,
			},
		},
	},
	{
		id = "crew_speed",
		title = "Assist Work",
		description = "Increase this member's assist damage.",
		cost = 0,
		costGrowth = 1.85,
		x = 170,
		y = 170,
		prerequisites = {
			"crew_recruit",
		},
		effects = {
			{
				target = "crewMember",
				stat = "damage",
				amount = 0.9,
			},
		},
	},
	{
		id = "crew_loop",
		title = "Loop Practice",
		description = "Unlock this member's chance to perform Loop.",
		cost = 0,
		costGrowth = 2,
		x = 0,
		y = 350,
		prerequisites = {
			"crew_training",
			"crew_speed",
		},
		effects = {
			{
				target = "crewMember",
				trick = "loop",
				amount = 0.025,
			},
		},
	},
	{
		id = "crew_world",
		title = "World Practice",
		description = "Unlock this member's chance to perform Around the World.",
		cost = 0,
		costGrowth = 2.1,
		x = -150,
		y = 530,
		prerequisites = {
			"crew_loop",
		},
		effects = {
			{
				target = "crewMember",
				trick = "aroundTheWorld",
				amount = 0.018,
			},
		},
	},
	{
		id = "crew_advanced",
		title = "Advanced Practice",
		description = "Boost this member's advanced trick chances.",
		cost = 0,
		costGrowth = 2.15,
		x = 160,
		y = 530,
		prerequisites = {
			"crew_loop",
		},
		effects = {
			{
				target = "crewMember",
				trick = "rockTheBaby",
				amount = 0.014,
			},
			{
				target = "crewMember",
				stat = "critChance",
				amount = 0.012,
			},
		},
	},
}

UpgradeConfig.Tabs = {
	{
		id = "self",
		title = "Self",
		subtitle = "Personal upgrades.",
		trees = {
			{
				id = "self",
				title = "Self",
				upgrades = SelfUpgrades,
				context = {
					scope = "self",
				},
			},
		},
	},
	{
		id = "crew",
		title = "Crew",
		subtitle = "Per-member crew upgrades.",
		unlock = {
			upgradeId = "crew_leadership",
			level = 1,
			text = "Requires Crew Leadership Lv 1.",
		},
		crewTab = true,
	},
}

UpgradeConfig.Upgrades = SelfUpgrades

local upgradeById = {}

local function registerUpgrades(upgrades)
	for _, upgrade in ipairs(upgrades) do
		upgradeById[upgrade.id] = upgrade
	end
end

registerUpgrades(SelfUpgrades)
registerUpgrades(CrewUpgrades)

local function getCrewMember(data, memberId)
	if type(data) ~= "table" or type(data.crew) ~= "table" or type(data.crew.members) ~= "table" then
		return nil
	end

	for _, member in ipairs(data.crew.members) do
		if member.id == memberId then
			return member
		end
	end

	return nil
end

local function isCrewSlot(memberId)
	for _, slot in ipairs(UpgradeConfig.CrewSlots) do
		if slot.memberId == memberId then
			return true
		end
	end

	return false
end

local function isCrewUpgrade(upgrade)
	for _, effect in ipairs(upgrade.effects or {}) do
		if effect.target == "crewMember" then
			return true
		end
	end

	return false
end

function UpgradeConfig.getUpgrade(upgradeId)
	return upgradeById[upgradeId]
end

function UpgradeConfig.getPrerequisites(upgrade)
	return upgrade.prerequisites or {}
end

function UpgradeConfig.getUpgradeKey(upgradeId, context)
	if type(context) == "table" and context.scope == "crew" and type(context.memberId) == "string" then
		return "crew:" .. context.memberId .. ":" .. upgradeId
	end

	return upgradeId
end

function UpgradeConfig.getLevel(data, upgradeId, context)
	local upgrade = UpgradeConfig.getUpgrade(upgradeId)

	if upgrade and type(context) == "table" and context.scope == "crew" and upgrade.id == "crew_recruit" then
		return if getCrewMember(data, context.memberId) then 1 else 0
	end

	local key = UpgradeConfig.getUpgradeKey(upgradeId, context)

	if type(data.upgradeLevels) == "table" and type(data.upgradeLevels[key]) == "number" then
		return data.upgradeLevels[key]
	end

	if type(data.unlockedUpgrades) == "table" and data.unlockedUpgrades[key] == true then
		return 1
	end

	return 0
end

function UpgradeConfig.getMaxLevel(upgrade)
	if upgrade.maxLevel then
		return upgrade.maxLevel
	end

	return 5
end

function UpgradeConfig.isUnlocked(data, upgradeId, context)
	return UpgradeConfig.getLevel(data, upgradeId, context) > 0
end

function UpgradeConfig.isMaxed(data, upgradeId, context)
	local upgrade = UpgradeConfig.getUpgrade(upgradeId)

	if not upgrade then
		return false
	end

	return UpgradeConfig.getLevel(data, upgradeId, context) >= UpgradeConfig.getMaxLevel(upgrade)
end

function UpgradeConfig.getCost(upgrade, level)
	if not upgrade then
		return 0
	end

	local baseCost = upgrade.cost or 0
	if baseCost <= 0 then
		return 0
	end

	local growth = upgrade.costGrowth or 1.8
	local currentLevel = math.max(level or 0, 0)

	return math.floor(baseCost * (growth ^ currentLevel) + 0.5)
end

function UpgradeConfig.isTabUnlocked(data, tab)
	if not tab.unlock then
		return true
	end

	return UpgradeConfig.getLevel(data, tab.unlock.upgradeId) >= (tab.unlock.level or 1)
end

function UpgradeConfig.getTabLockedText(tab)
	if not tab.unlock then
		return ""
	end

	return tab.unlock.text or "This tab is locked."
end

function UpgradeConfig.hasPrerequisites(data, upgradeId, context)
	local upgrade = UpgradeConfig.getUpgrade(upgradeId)

	if not upgrade then
		return false
	end

	for _, prerequisiteId in ipairs(UpgradeConfig.getPrerequisites(upgrade)) do
		if not UpgradeConfig.isUnlocked(data, prerequisiteId, context) then
			return false
		end
	end

	return true
end

function UpgradeConfig.canAfford(data, upgradeId, context)
	local upgrade = UpgradeConfig.getUpgrade(upgradeId)
	local cost = UpgradeConfig.getCost(upgrade, UpgradeConfig.getLevel(data, upgradeId, context))

	return (data.money or 0) >= cost
end

function UpgradeConfig.canBuy(data, upgradeId, context)
	local upgrade = UpgradeConfig.getUpgrade(upgradeId)

	if not upgrade or UpgradeConfig.isMaxed(data, upgradeId, context) then
		return false
	end

	if isCrewUpgrade(upgrade) then
		if type(context) ~= "table" or context.scope ~= "crew" or not isCrewSlot(context.memberId) then
			return false
		end

		if not UpgradeConfig.isTabUnlocked(data, UpgradeConfig.Tabs[2]) then
			return false
		end
	end

	if type(context) == "table" and context.scope == "crew" and not UpgradeConfig.isTabUnlocked(data, UpgradeConfig.Tabs[2]) then
		return false
	end

	if not UpgradeConfig.hasPrerequisites(data, upgradeId, context) then
		return false
	end

	if not UpgradeConfig.canAfford(data, upgradeId, context) then
		return false
	end

	return true
end

function UpgradeConfig.getCrewTrees()
	local trees = {}
	local positions = {
		{
			x = -220,
			y = 40,
		},
		{
			x = 420,
			y = 40,
		},
		{
			x = -220,
			y = 760,
		},
		{
			x = 420,
			y = 760,
		},
	}

	for index, slot in ipairs(UpgradeConfig.CrewSlots) do
		local position = positions[index] or {
			x = 0,
			y = 0,
		}

		table.insert(trees, {
			id = slot.memberId,
			title = slot.title,
			x = position.x,
			y = position.y,
			upgrades = CrewUpgrades,
			context = {
				scope = "crew",
				memberId = slot.memberId,
				memberName = slot.memberName,
			},
		})
	end

	return trees
end

function UpgradeConfig.getTreesForTab(tab)
	if tab.crewTab then
		return UpgradeConfig.getCrewTrees()
	end

	return tab.trees or {}
end

return UpgradeConfig
