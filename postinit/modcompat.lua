local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddPrefabPostInit = ENV.AddPrefabPostInit
local AddComponentPostInit = ENV.AddComponentPostInit

---  Cherryforest
if KnownModIndex:IsModEnabled("workshop-1289779251") then	
	AddPrefabPostInit("warne", function(inst)
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst:AddComponent("cherryreputation")
		inst.components.cherryreputation:SetPercent(TUNING.WARNE_CHERRYREP_START_HATE)
		inst.components.cherryreputation.repmultiplier = -0.3
	end)
end

--- IA Core
if KnownModIndex:IsModEnabled("workshop-3435352667") then	
	AddPrefabPostInit("warne", function(inst)
		---note to self. Replace tag with inst.poisonimmune
	inst:AddTag("poisonimmune")
	end)
end