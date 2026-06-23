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
		x = 0,
		y = 0,
		effects = {
			{
				target = "player",
				stat = "damage",
				amount = 5,
			},
			{
				target = "player",
				stat = "hitSpeed",
				amount = 0.1,
			},
		},
	},
	{
		id = "quick_wrists",
		title = "Quick Wrists",
		description = "Increase your hit speed.",
		cost = 0,
		x = -260,
		y = 150,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "hitSpeed",
				amount = 0.2,
			},
		},
	},
	{
		id = "steady_form",
		title = "Steady Form",
		description = "Increase your success rate.",
		cost = 0,
		x = 0,
		y = 160,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "successRate",
				amount = 0.08,
			},
		},
	},
	{
		id = "sharp_snap",
		title = "Sharp Snap",
		description = "Increase your critical chance.",
		cost = 0,
		x = 260,
		y = 150,
		prerequisites = {
			"player_foundation",
		},
		effects = {
			{
				target = "player",
				stat = "critChance",
				amount = 0.05,
			},
		},
	},
	{
		id = "heavy_yoyo",
		title = "Heavy Yoyo",
		description = "Increase your base damage.",
		cost = 0,
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
				amount = 15,
			},
		},
	},
	{
		id = "combo_focus",
		title = "Combo Focus",
		description = "Better speed and critical chance together.",
		cost = 0,
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
				amount = 0.15,
			},
			{
				target = "player",
				stat = "critChance",
				amount = 0.04,
			},
		},
	},
	{
		id = "crew_leadership",
		title = "Crew Leadership",
		description = "Unlock crew upgrade trees at level 1.",
		cost = 150,
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
				amount = 0.02,
			},
		},
	},
	{
		id = "loop_trick",
		title = "Loop Trick",
		description = "Unlock a chance to perform Loop.",
		cost = 0,
		x = 380,
		y = 510,
		prerequisites = {
			"sharp_snap",
		},
		effects = {
			{
				target = "player",
				trick = "loop",
				amount = 0.16,
			},
		},
	},
	{
		id = "walk_dog_trick",
		title = "Walk the Dog",
		description = "Unlock a chance to perform Walk the Dog.",
		cost = 100,
		x = 590,
		y = 680,
		prerequisites = {
			"loop_trick",
		},
		effects = {
			{
				target = "player",
				trick = "walkTheDog",
				amount = 0.12,
			},
		},
	},
	{
		id = "world_trick",
		title = "Around the World",
		description = "Unlock a chance to perform Around the World.",
		cost = 100,
		x = 320,
		y = 700,
		prerequisites = {
			"loop_trick",
		},
		effects = {
			{
				target = "player",
				trick = "aroundTheWorld",
				amount = 0.1,
			},
		},
	},
	{
		id = "advanced_tricks",
		title = "Advanced Tricks",
		description = "Unlock Rock the Baby and Boomerang chances.",
		cost = 250,
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
				amount = 0.08,
			},
			{
				target = "player",
				trick = "boomerang",
				amount = 0.06,
			},
		},
	},
	{
		id = "mastery",
		title = "Personal Mastery",
		description = "A large late-tree boost for your own stats.",
		cost = 500,
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
				amount = 25,
			},
			{
				target = "player",
				stat = "successRate",
				amount = 0.1,
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
		cost = 75,
		x = -170,
		y = 170,
		prerequisites = {
			"crew_recruit",
		},
		effects = {
			{
				target = "crewMember",
				stat = "damage",
				amount = 8,
			},
			{
				target = "crewMember",
				stat = "successRate",
				amount = 0.05,
			},
		},
	},
	{
		id = "crew_speed",
		title = "Speed Work",
		description = "Increase this member's hit speed.",
		cost = 75,
		x = 170,
		y = 170,
		prerequisites = {
			"crew_recruit",
		},
		effects = {
			{
				target = "crewMember",
				stat = "hitSpeed",
				amount = 0.18,
			},
		},
	},
	{
		id = "crew_loop",
		title = "Loop Practice",
		description = "Unlock this member's chance to perform Loop.",
		cost = 100,
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
				amount = 0.08,
			},
		},
	},
	{
		id = "crew_world",
		title = "World Practice",
		description = "Unlock this member's chance to perform Around the World.",
		cost = 150,
		x = -150,
		y = 530,
		prerequisites = {
			"crew_loop",
		},
		effects = {
			{
				target = "crewMember",
				trick = "aroundTheWorld",
				amount = 0.05,
			},
		},
	},
	{
		id = "crew_advanced",
		title = "Advanced Practice",
		description = "Boost this member's advanced trick chances.",
		cost = 250,
		x = 160,
		y = 530,
		prerequisites = {
			"crew_loop",
		},
		effects = {
			{
				target = "crewMember",
				trick = "rockTheBaby",
				amount = 0.04,
			},
			{
				target = "crewMember",
				stat = "critChance",
				amount = 0.03,
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

	return upgrade.cost or 0
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
