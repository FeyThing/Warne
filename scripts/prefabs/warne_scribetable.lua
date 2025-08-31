local assets = {
	Asset("ANIM", "anim/warne_scribetable.zip"),
	Asset("ANIM", "anim/ui_warne_scribetable.zip"),
}

--function Default_PlayAnimation(inst, anim, loop)
    --inst.AnimState:PlayAnimation(idle_loop, loop)
--end

--function Default_PushAnimation(inst, anim, loop)
    --inst.AnimState:PushAnimation(idle_loop, loop)
--end


local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_active", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .5)
	
	
	inst:AddTag("structure")
	inst:AddTag("scribetable")
	
	
	inst.AnimState:SetBank("warne_scribetable")
	inst.AnimState:SetBuild("warne_scribetable")
	inst.AnimState:PlayAnimation("idle_active", true)
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("warne_scribetable")

	
	inst:ListenForEvent("onbuilt", OnBuilt)
	
	--inst._PlayAnimation = Default_PlayAnimation
	--inst._PushAnimation = Default_PushAnimation

	return inst
end

return Prefab("warne_scribetable", fn, assets),
	MakePlacer("warne_scribetable_placer", "warne_scribetable", "warne_scribetable", "idle_active")