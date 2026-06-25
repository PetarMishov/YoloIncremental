local Regular = require(script:WaitForChild("Regular"))

local TrickAnimations = {}

function TrickAnimations.playRegular(character: Model, handle: BasePart)
	return Regular.play(character, handle)
end

return TrickAnimations
