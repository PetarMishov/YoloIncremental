local Money = {}

local MAX_MONEY = 9007199254740991

local function isFiniteNonNegative(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge and value >= 0
end

function Money.isValid(value)
	return isFiniteNonNegative(value) and value <= MAX_MONEY
end

function Money.sanitize(value)
	if not isFiniteNonNegative(value) then
		return 0
	end

	return math.min(value, MAX_MONEY)
end

local function getLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	return leaderstats
end

local function getNumberValue(player, name)
	local leaderstats = getLeaderstats(player)
	local value = leaderstats:FindFirstChild(name)

	if not value then
		value = Instance.new("NumberValue")
		value.Name = name
		value.Parent = leaderstats
	end

	return value
end

function Money.sync(player, data)
	getNumberValue(player, "Total Earned").Value = Money.sanitize(data.totalMoneyEarned)
	getNumberValue(player, "Money").Value = Money.sanitize(data.money)
end

function Money.set(player, data, amount)
	data.money = Money.sanitize(amount)
	Money.sync(player, data)
end

function Money.add(player, data, amount)
	local sanitizedAmount = Money.sanitize(amount)

	data.money = Money.sanitize((data.money or 0) + sanitizedAmount)
	data.totalMoneyEarned = Money.sanitize((data.totalMoneyEarned or 0) + sanitizedAmount)
	Money.sync(player, data)
end

return Money
