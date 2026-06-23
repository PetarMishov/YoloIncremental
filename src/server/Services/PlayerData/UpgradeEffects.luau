local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultPlayerData = require(ReplicatedStorage.Shared:WaitForChild("DefaultPlayerData"))
local UpgradeConfig = require(ReplicatedStorage.Shared:WaitForChild("UpgradeConfig"))

local UpgradeEffects = {}

local function getCrewMember(data, memberId)
	for _, member in ipairs(data.crew.members) do
		if member.id == memberId then
			return member
		end
	end

	return nil
end

local function getCrewSlot(memberId)
	for _, slot in ipairs(UpgradeConfig.CrewSlots) do
		if slot.memberId == memberId then
			return slot
		end
	end

	return nil
end

local function addStat(stats, stat, amount)
	stats[stat] = (stats[stat] or 0) + amount
end

local function addTrick(stats, trick, amount)
	stats.tricks[trick] = math.clamp((stats.tricks[trick] or 0) + amount, 0, 1)
end

local function addTrickMultiplier(stats, trick, amount)
	if type(stats.trickMultipliers) ~= "table" then
		stats.trickMultipliers = {}
	end

	stats.trickMultipliers[trick] = (stats.trickMultipliers[trick] or 1) + amount
end

local function applyToCrewMember(data, effect, context)
	if type(context) ~= "table" or context.scope ~= "crew" then
		return
	end

	local slot = getCrewSlot(context.memberId)
	if not slot then
		return
	end

	if effect.action == "addMember" then
		if #data.crew.members >= data.crew.maxSize or getCrewMember(data, slot.memberId) then
			return
		end

		table.insert(data.crew.members, DefaultPlayerData.createCrewMember(slot.memberId, slot.memberName))
		return
	end

	local member = getCrewMember(data, slot.memberId)
	if not member then
		return
	end

	if effect.trickMultiplier then
		addTrickMultiplier(member.stats, effect.trickMultiplier, effect.amount)
	elseif effect.trick then
		addTrick(member.stats, effect.trick, effect.amount)
	else
		addStat(member.stats, effect.stat, effect.amount)
	end
end

function UpgradeEffects.apply(data, upgrade, context)
	for _, effect in ipairs(upgrade.effects or {}) do
		if effect.target == "player" then
			if effect.trickMultiplier then
				addTrickMultiplier(data.player.stats, effect.trickMultiplier, effect.amount)
			elseif effect.trick then
				addTrick(data.player.stats, effect.trick, effect.amount)
			else
				addStat(data.player.stats, effect.stat, effect.amount)
			end
		elseif effect.target == "crewMember" then
			applyToCrewMember(data, effect, context)
		end
	end
end

return UpgradeEffects
