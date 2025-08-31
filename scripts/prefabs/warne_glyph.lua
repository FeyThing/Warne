local assets = {
    Asset("ANIM", "anim/warne_glyph.zip"),
}

local prefabs = {
	
}

local function OnTeach(inst, learner)

end


local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("warne_glyph")
    inst.AnimState:SetBuild("warne_glyph")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("_named")
    inst:SetPrefabNameOverride("warne_glyph")
	
    MakeInventoryFloatable(inst, "med", nil, 0.75)
	
    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:RemoveTag("_named")
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    
	inst:AddComponent("erasablepaper")

    inst:AddComponent("named")
    inst:AddComponent("teacher")
    inst.components.teacher.onteach = OnTeach
	
    MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("warne_glyph", fn, assets, prefabs)