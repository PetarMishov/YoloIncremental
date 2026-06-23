local YoyoConfig = {}

YoyoConfig.Part = {
	Body = "body",
	String = "string",
}

YoyoConfig.Tier = {
	Bronze = "bronze",
	Silver = "silver",
	Gold = "gold",
	Platinum = "platinum",
	Diamond = "diamond",
}

YoyoConfig.BodyTiers = {
	{
		id = YoyoConfig.Tier.Bronze,
		label = "Bronze",
		damage = 0.7,
		cost = 0,
	},
	{
		id = YoyoConfig.Tier.Silver,
		label = "Silver",
		damage = 2.5,
		cost = 250,
	},
	{
		id = YoyoConfig.Tier.Gold,
		label = "Gold",
		damage = 8,
		cost = 2500,
	},
	{
		id = YoyoConfig.Tier.Platinum,
		label = "Platinum",
		damage = 24,
		cost = 25000,
	},
	{
		id = YoyoConfig.Tier.Diamond,
		label = "Diamond",
		damage = 75,
		cost = 250000,
	},
}

YoyoConfig.StringTiers = {
	{
		id = YoyoConfig.Tier.Bronze,
		label = "Bronze",
		damage = 0.3,
		cost = 0,
	},
	{
		id = YoyoConfig.Tier.Silver,
		label = "Silver",
		damage = 1.5,
		cost = 180,
	},
	{
		id = YoyoConfig.Tier.Gold,
		label = "Gold",
		damage = 5,
		cost = 1800,
	},
	{
		id = YoyoConfig.Tier.Platinum,
		label = "Platinum",
		damage = 16,
		cost = 18000,
	},
	{
		id = YoyoConfig.Tier.Diamond,
		label = "Diamond",
		damage = 50,
		cost = 180000,
	},
}

local function getTiers(part)
	if part == YoyoConfig.Part.String then
		return YoyoConfig.StringTiers
	end

	return YoyoConfig.BodyTiers
end

local function getTierIndex(tiers, tierId)
	for index, tier in ipairs(tiers) do
		if tier.id == tierId then
			return index
		end
	end

	return 1
end

function YoyoConfig.createDefault()
	return {
		body = YoyoConfig.Tier.Bronze,
		string = YoyoConfig.Tier.Bronze,
	}
end

function YoyoConfig.getTier(part, tierId)
	local tiers = getTiers(part)

	return tiers[getTierIndex(tiers, tierId)]
end

function YoyoConfig.getNextTier(part, tierId)
	local tiers = getTiers(part)
	local nextIndex = getTierIndex(tiers, tierId) + 1

	return tiers[nextIndex]
end

function YoyoConfig.getUpgradeCost(yoyo, part)
	local currentTier = if type(yoyo) == "table" then yoyo[part] else nil
	local nextTier = YoyoConfig.getNextTier(part, currentTier)

	return if nextTier then nextTier.cost else nil
end

function YoyoConfig.getDamage(yoyo)
	if type(yoyo) ~= "table" then
		yoyo = YoyoConfig.createDefault()
	end

	local body = YoyoConfig.getTier(YoyoConfig.Part.Body, yoyo.body)
	local stringTier = YoyoConfig.getTier(YoyoConfig.Part.String, yoyo.string)

	return (body.damage or 0) + (stringTier.damage or 0)
end

function YoyoConfig.getTierLabel(part, tierId)
	local tier = YoyoConfig.getTier(part, tierId)

	return tier.label
end

return YoyoConfig
