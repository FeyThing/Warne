local ENV = env
GLOBAL.setfenv(1, GLOBAL)

ENV.AddPrefabPostInit("flower_evil", function(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	
    local _onpickedfn = inst.components.pickable.onpickedfn
    inst.components.pickable.onpickedfn = function(inst, picker, ...)
        if picker:HasTag("lich") then
                picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
            return 
        end
        return _onpickedfn(inst, picker, ...)
    end
end)

