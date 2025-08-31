local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local FarmPlantStress = require("components/farmplantstress")

local OldSetStressed = FarmPlantStress.SetStressed
function FarmPlantStress:SetStressed(name, stressed, doer, ...)
	if not self.ignore_lich and doer and doer:HasTag("lich") then
		self.inst:DoTaskInTime(0.5, function()
			SpawnPrefab("farm_plant_unhappy").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
		end)
		
		stressed = true
		self.inst.no_oversized = true
	end
    
    return OldSetStressed(self, name, stressed, doer, ...)
end