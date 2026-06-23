local Money = {}

local MAX_MONEY = 1e15

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

local function getMoneyValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local moneyValue = leaderstats:FindFirstChild("Money")

	if not moneyValue then
		moneyValue = Instance.new("NumberValue")
		moneyValue.Name = "Money"
		moneyValue.Parent = leaderstats
	end

	return moneyValue
end

function Money.sync(player, data)
	getMoneyValue(player).Value = Money.sanitize(data.money)
end

function Money.set(player, data, amount)
	data.money = Money.sanitize(amount)
	Money.sync(player, data)
end

return Money
