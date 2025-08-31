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
	if inst.components.workable and inst.components.workable:CanBeWorked() then
		inst.components.workable:Destroy(doer)
	end
end

local function CanRezFn(inst, doer)
	if inst.components.workable and inst.components.workable:CanBeWorked() then
		if math.random() < 0.5 then
			inst.components.workable:Destroy(doer)
		else
			return true
		end
	end
	
	return false
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