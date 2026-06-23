local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeConfig = require(ReplicatedStorage.Shared.UpgradeConfig)

local Format = {}

function Format.percent(value)
	return tostring(math.floor((value or 0) * 100 + 0.5)) .. "%"
end

function Format.number(value)
	local rounded = math.floor((value or 0) * 100 + 0.5) / 100
	return tostring(rounded)
end

function Format.money(value)
	return "$" .. Format.number(value)
end

function Format.statLabel(statId)
	for _, stat in ipairs(UpgradeConfig.Stats) do
		if stat.id == statId then
			return stat.label
		end
	end

	return statId
end

function Format.trickLabel(trickId)
	for _, trick in ipairs(UpgradeConfig.Tricks) do
		if trick.id == trickId then
			return trick.label
		end
	end

	return trickId
end

function Format.effect(effect)
	return Format.leveledEffect(effect, 0, 1)
end

function Format.leveledEffect(effect, currentLevel, maxLevel)
	local target = if effect.target == "crewMember" then "Member" elseif effect.target == "crew" then "Crew" else "You"

	if effect.action == "addMember" then
		if currentLevel >= maxLevel then
			return "Crew: recruited"
		end

		return "Crew: recruit"
	end

	local currentAmount = effect.amount * currentLevel
	local nextAmount = effect.amount * math.min(currentLevel + 1, maxLevel)
	local label
	local currentText
	local nextText

	if effect.trick then
		label = Format.trickLabel(effect.trick)
		currentText = Format.percent(currentAmount)
		nextText = Format.percent(nextAmount)
	elseif effect.stat == "successRate" or effect.stat == "critChance" then
		label = Format.statLabel(effect.stat)
		currentText = Format.percent(currentAmount)
		nextText = Format.percent(nextAmount)
	else
		label = Format.statLabel(effect.stat)
		currentText = Format.number(currentAmount)
		nextText = Format.number(nextAmount)
	end

	if currentLevel <= 0 then
		return target .. ": +" .. nextText .. " " .. label
	end

	if currentLevel >= maxLevel then
		return target .. ": +" .. currentText .. " " .. label
	end

	return target .. ": +" .. currentText .. " -> +" .. nextText .. " " .. label
end

return Format
