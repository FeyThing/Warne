local assets =
{
    Asset("ANIM", "anim/warnestaff.zip"),
}

local function onequip(inst, owner)
    
    owner.AnimState:OverrideSymbol("swap_object", "warnestaff", "swap_warnestaff")
   
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("warnestaff")
    inst.AnimState:SetBuild("warnestaff")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")
    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("jab")
inst:AddTag("lichfocus")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)

    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.WARNE_MAXCHARGE)
inst.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)
    inst.components.finiteuses:SetUses(0)

    inst:AddComponent("inventoryitem")
--inst.components.inventoryitem.keepondeath = true
--inst.components.inventoryitem.keepondrown = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("warnestaff", fn, assets)