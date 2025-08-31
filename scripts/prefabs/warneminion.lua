local assets = {
	Asset("ANIM", "anim/warne_skeleton_minion.zip"),
}

local prefabs = {
	
}

local brain = require("brains/warneminionbrain")

local RETARGET_MUST_TAGS = {"_combat"}
local RETARGET_NOT_TAGS = {"INLIMBO"}

local function RetargetFn(inst)
	local leader = inst.components.follower:GetLeader()
	local target = FindEntity(inst, 6, function(guy) return guy.components.combat and guy.components.combat.target == leader and leader ~= nil end,
	RETARGET_MUST_TAGS, RETARGET_NOT_TAGS)
	
	if target then
		return target
	elseif leader and leader.components.combat then
		return leader.components.combat.target
	end
end

local function KeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function CalcSanityAura(inst, observer)
	return observer:HasTag("lich") and 0 or -TUNING.SANITYAURA_MED
end

local function ShouldAcceptItem(inst, item)
	return item.components.equippable ~= nil
end

local function OnGetItemFromPlayer(inst, giver, item)
	if item.components.equippable then
		local slot = item.components.equippable.equipslot
		local current = inst.components.inventory:GetEquippedItem(slot)
		
		if current then
			inst.components.inventory:DropItem(current)
		end
		inst.components.inventory:Equip(item)
		if slot == EQUIPSLOTS.HEAD then
			inst.AnimState:Show("hat")
		end
	end
end

local function OnRefuseItem(inst, item)
	inst.sg:GoToState("refuse")
end

local function OnAttacked(inst, data)
	local attacker = data and data.attacker
	if attacker and inst.components.follower.leader ~= attacker then
		inst.components.combat:SetTarget(attacker)
	end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	
	inst.Transform:SetFourFaced()
	
	MakeCharacterPhysics(inst, 75, 0.5)
	
	inst.DynamicShadow:SetSize(1.3, 0.6)
	
	inst:AddTag("character")
	inst:AddTag("scarytoprey")
	inst:AddTag("warneminion")
	
	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("warne_skeleton_minion")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:Hide("hat")
	inst.AnimState:Hide("ARM_carry")
	inst.AnimState:Hide("HAIR_HAT")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "torso"
	inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
	inst.components.combat:SetAttackPeriod(0)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	
	inst:AddComponent("drownable")
	
	inst:AddComponent("embarker")
	
	inst:AddComponent("follower")
	inst.components.follower.keepdeadleader = true
    inst.components.follower:KeepLeaderOnAttacked()
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(250)
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventory")
	
	inst:AddComponent("locomotor")
	inst.components.locomotor:SetAllowPlatformHopping(true)
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"boneshard"})
	
	inst:AddComponent("knownlocations")
	
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = CalcSanityAura
	
	inst:AddComponent("timer")

	inst:AddComponent("trader")
	inst.components.trader.acceptnontradable = true
	inst.components.trader.deleteitemonaccept = false
	inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.trader.onrefuse = OnRefuseItem
	inst.components.trader:SetAcceptTest(ShouldAcceptItem)
	
	MakeMediumBurnableCharacter(inst, "torso")
	MakeMediumFreezableCharacter(inst, "torso")
	MakeHauntablePanic(inst)
	
	inst:SetBrain(brain)
	inst:SetStateGraph("SGwarneminion")
	
	inst:ListenForEvent("attacked", OnAttacked)
	
	return inst
end

local function OnBuiltFn(inst, builder)
	if inst.components.warne_rezminion and builder then
		inst.components.warne_rezminion:Resurrect(builder)
	end
	inst:Remove()
end

local function builder()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	
	inst:AddTag("CLASSIFIED")
	
	inst.persists = false
	
	inst:DoTaskInTime(0, inst.Remove)
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("warne_rezminion")
	
	inst.OnBuiltFn = OnBuiltFn
	
	return inst
end

local function PlacerPostinitFn(inst)
	inst.AnimState:PlayAnimation("idle"..math.random(6))
end

return Prefab("warneminion", fn, assets, prefabs),
	Prefab("warneminion_builder", builder, assets, prefabs),
	MakePlacer("warneminion_builder_placer", "skeleton", "skeleton", "idle1", nil, nil, nil, nil, nil, nil, PlacerPostinitFn)