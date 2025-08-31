local assets = {
	Asset("ANIM", "anim/warne_souljar.zip"),
}


local function souldrain(inst)
    local player = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
    
    if player and player:HasTag("lich") and player.components.hunger and player.components.hunger.current < (player.components.hunger.max - TUNING.WARNE_SOUL_REGEN)
        and inst.components.attunable and inst.components.attunable:IsAttuned(player) and inst.components.fueled and not inst.components.fueled:IsEmpty() then
        
        if player.components.hunger then
            player.components.hunger:DoDelta(TUNING.WARNE_SOUL_REGEN)
            
            if inst.components.fueled then
                inst.components.fueled:DoDelta(-1)
            end
            
            return false
        end                
    end
end

local function UpdateDrain(inst)
	if inst._draintask then
		inst._draintask:Cancel()
		inst._draintask = nil
	end
	
	inst:DoTaskInTime(TUNING.WARNE_SOUL_PERIOD, function()
		local player = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
		
		if player and player:HasTag("lich") then
			inst._draintask = inst:DoPeriodicTask(TUNING.WARNE_SOUL_PERIOD, inst.SoulDrain, 0)
		end
	end)
end

local function onattunecost(inst, player)
	return true
end

local function onlink(inst, player, isloading)
	if not isloading then
		inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/on")
        inst.AnimState:PushAnimation("idle_active", true)
	end
	inst._warneid = player and player.userid or inst._warneid
	inst._lichattuned:set(true)
end

local function onunlink(inst, player, isloading)
	if not (isloading or inst.AnimState:IsCurrentAnimation("idle_active")) then
		inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/off")
		inst.AnimState:PushAnimation("idle")
	end
	--inst._warneid = nil	TODO: only remove when actually changing of owner, not when disconnecting or moving to different shard. But this will be needed eventually
	inst._lichattuned:set(false)
end

local function OnSave(inst, data)
	data.warneid = inst._warneid
end

local function OnLoad(inst, data)
	if data and data.warneid then
		inst._warneid = data.warneid
	end
end

local function StartWarneRevive(inst, userid)
	if userid then
		inst.persists = false
		if inst.components.inventoryitem then
			inst.components.inventoryitem.canbepickedup = false
		end
		
		local cur_shard = TheShard:GetShardId()
		local x, y, z = inst.Transform:GetWorldPosition()
		
		SendModRPCToShard(GetShardModRPC("Warne", "SoulJarRevive_Over"), cur_shard, userid, cur_shard, x, y, z)
		for shard_id in pairs(Shard_GetConnectedShards()) do
			SendModRPCToShard(GetShardModRPC("Warne", "SoulJarRevive_Over"), shard_id, userid, cur_shard, x, y, z)
		end
		
		inst:DoTaskInTime(TUNING.WARNE_REVIVE_DELAY, ErodeAway)
		inst._warneid = nil
	end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst:AddTag("phylactery")
	inst:AddTag("resurrector")
	inst:AddTag("magical")
	
	inst.AnimState:SetBank("warne_souljar")
	inst.AnimState:SetBuild("warne_souljar")
	inst.AnimState:PlayAnimation("idle")
	
	inst._lichattuned = net_bool(inst.GUID, "_lichattuned", "onlichattuned")
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem:SetOnDroppedFn(UpdateDrain)
	inst.components.inventoryitem:SetOnPutInInventoryFn(UpdateDrain)
	
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(TUNING.WARNE_MAXUSES)
	inst.components.fueled.currentfuel = 0
	inst.components.fueled.accepting = false
	
	inst:AddComponent("attunable")
	inst.components.attunable:SetAttunableTag("lichresurrector")
	inst.components.attunable:SetOnAttuneCostFn(onattunecost)
	inst.components.attunable:SetOnLinkFn(onlink)
	inst.components.attunable:SetOnUnlinkFn(onunlink)
	
	inst.SoulDrain = souldrain
	inst.OnLoad = OnLoad
	inst.OnSave = OnSave
	inst.StartWarneRevive = StartWarneRevive
	
	inst:ListenForEvent("activateresurrection", inst.Remove)
	
	return inst
end

return Prefab("warne_souljar", fn, assets)