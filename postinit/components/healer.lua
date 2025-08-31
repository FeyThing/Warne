local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local Healer = require("components/healer")

local OldHeal = Healer.Heal
function Healer:Heal(target, doer, ...)
	if target and target:HasTag("lich") and not (target.canhealer_heal and target:canhealer_heal(target, doer)) then
		return false
	end
	
	return OldHeal(self, target, doer, ...)
end