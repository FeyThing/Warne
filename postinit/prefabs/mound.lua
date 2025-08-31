local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local OldOnFinishCallback
local function OnFinishCallback(inst, worker, ...)
    if worker and worker:HasTag("lich") then
        worker._sanity_dig_immune = true
    end
    if OldOnFinishCallback then
        OldOnFinishCallback(inst, worker, ...)
    end
    if worker and worker:HasTag("lich") then
        worker._sanity_dig_immune = nil
    end
end

local function OnRezFn(inst, doer)
		inst.AnimState:PlayAnimation("dug")
        inst:RemoveComponent("workable")
		if math.random() < 0.5 then
			inst.components.warne_rezminion:Spawn(doer)
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_REZ_SKELETON"))
        else
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_REZ_NO_SKELETON"))
		end
end

local function CanRezFn(inst, doer)
	return inst.components.workable and inst.components.workable:CanBeWorked()
end

ENV.AddPrefabPostInit("mound", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    inst:AddComponent("warne_rezminion")
	inst.components.warne_rezminion.onrezfn = OnRezFn
	inst.components.warne_rezminion.canrez = CanRezFn

    if inst.components.workable then
        if OldOnFinishCallback == nil then
            OldOnFinishCallback = inst.components.workable.onfinish
        end
        inst.components.workable.onfinish = OnFinishCallback
    end
end)