local function clone(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}

	for key, child in pairs(value) do
		result[key] = clone(child)
	end

	return result
end

return clone
