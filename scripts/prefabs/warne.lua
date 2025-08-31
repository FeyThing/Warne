local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("ANIM", "anim/warne.zip"),
	Asset("ANIM", "anim/ghost_shadow_warne.zip"),
	Asset("ANIM", "anim/player_idles_warne.zip"),	
}

local start_inv = {}

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WARNE
end

local prefabs = FlattenTree(start_inv, true)
table.insert(prefabs, "lichdarkenessorbs")

local function customidleanimfn()
	return math.random() < 0.5 and "idle_warne" or "idle_wilson"
end

---glow
local function SetGlow(inst, show, delete)
	if delete then
		if inst.glow and inst.glow:IsValid() then
			inst.glow:Remove()
		end
		inst.glow = nil
		
		return
	end
	
	if inst.glow == nil then
		inst.glow = SpawnPrefab("warne_glow_fx")
		inst.glow:AttachToOwner(inst)
	end
	
	if inst.glow and inst.glow.fx then
		inst.glow._shown = show
		for i, v in ipairs(inst.glow.fx) do
			if show then
				v:Show()
			else
				v:Hide()
			end
		end
	end
end

local function GlowTask(inst)
	inst:SetGlow(true)
end

---
local function onattack(inst, data)
	local victim = data.target
	
	inst.leechvictim = function(inst, attacker)
		if attacker and attacker.components.health and not attacker.components.health:IsDead() then
			SpawnPrefab("lichdarkenessorbs"):AlignToTarget(inst, attacker, true)					
		end
	end
	
	if inst.IsValidVictim(victim) then
		if inst.sg and inst.sg:HasStateTag("deathtouch") then
			inst:leechvictim(data.target)
			inst.components.health:DoDelta(TUNING.WARNE_RECOVERY)
		end
	end
end

local function GetEquippableDapperness(owner, equippable)
	local dapperness = equippable:GetDapperness(owner, owner.components.sanity.no_moisture_penalty)
	
	return equippable.inst:HasTag("shadow_item") and dapperness * TUNING.WARNE_SHADOW_ITEM_RESISTANCE or dapperness
end

local function ItemGet(inst)
	if inst.RestoreTask == nil then		
		if inst.components.inventory:HasItemWithTag("phylactery", 1) then
		end
	end
end

local function ItemLose(inst)
	if not inst.components.inventory:HasItemWithTag("phylactery", 1) then
		if inst.RestoreTask ~= nil then
			inst.RestoreTask:Cancel()
			inst.RestoreTask = nil
		end
	end
end

--

local function OnSave(inst, data)
	data.souljar_reviving = inst._souljar_reviving
end

local function OnLoad(inst, data)
	if data and data.souljar_reviving then
		inst._souljar_reviving = true
	end
end

local function IsValidVictim(victim)
	return victim and victim.components.health and victim.components.combat
		and not (victim:HasAnyTag(NON_LIFEFORM_TARGET_TAGS) or victim:HasTag("deckcontainer") or victim:HasTag("companion"))
end

local function StartWarneJarRevive(inst, complete)
	inst._souljar_reviving = true
	
	if complete and (inst:HasTag("playerghost") or inst.components.health and inst.components.health:IsDead()) then
		inst:PushEvent("respawnfromghost")
		inst._souljar_reviving = nil
	end
end

local function OnDeath(inst, data)
	SendModRPCToShard(GetShardModRPC("Warne", "SoulJarRevive_Start"), TheShard:GetShardId(), inst.userid)
	for shard_id in pairs(Shard_GetConnectedShards()) do
		SendModRPCToShard(GetShardModRPC("Warne", "SoulJarRevive_Start"), shard_id, inst.userid)
	end
end

local function OnInit(inst)
	if inst._souljar_reviving then
		inst:StartWarneJarRevive(true)
	end
end

--

local common_postinit = function(inst) 
	inst.MiniMapEntity:SetIcon("warne.png")
	
	inst:AddTag("lich")
	inst:AddTag("reader")
	inst:AddTag("insomniac")
	inst:AddTag("monster")
	inst:AddTag("soulless")
	inst:AddTag("has_gasmask")
	
	inst.components.talker.font = TALKINGFONT_HERMIT
	inst.components.talker.colour = Vector3(189 / 255, 69 / 255, 169 / 255)
	
	if TheNet:GetServerGameMode() == "quagmire" then
		inst:AddTag("quagmire_shopper")
	end
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	inst.soundsname = "warneevent"
	
	inst.talker_path_override = "warne/"
	
	inst.customidleanim = customidleanimfn
	
	inst.components.health:SetMaxHealth(TUNING.WARNE_HEALTH)
	inst.components.health.disable_penalty = true
	
	inst.components.hunger:SetMax(TUNING.WARNE_HUNGER)
	inst.components.hunger.hungerrate = .5 * TUNING.WILSON_HUNGER_RATE
	
	inst.components.sanity:SetMax(TUNING.WARNE_SANITY)
	inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness
	inst.components.sanity:SetPlayerGhostImmunity(true)
	inst.components.sanity:SetNegativeAuraImmunity(true)
	inst.components.sanity:SetLightDrainImmune(true)
	
	inst.components.combat.damagemultiplier = 1
	
	if inst.components.eater then
		inst.components.eater:SetAbsorptionModifiers(TUNING.WARNE_FOOD_MULT, TUNING.WARNE_FOOD_MULT, TUNING.WARNE_FOODSANITY_MULT)
		inst.components.eater:SetStrongStomach(true)
		inst.components.eater:SetCanEatRawMeat(true)
	end
	
	inst.components.inventory.noheavylifting = true
	
	inst:AddComponent("staffsanity")	
	inst.components.staffsanity:SetMultiplier(TUNING.WARNE_STAFFSANITY)
	
	inst:AddComponent("reader")
	
	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_WARNE_MULT)

	inst.skeleton_prefab = nil
	
	inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	inst.IsValidVictim = IsValidVictim
	inst.StartWarneJarRevive = StartWarneJarRevive
	
	inst._souljar_reviving_task = inst:DoTaskInTime(1, OnInit)
	
	inst:ListenForEvent("onattackother", onattack)
	inst:ListenForEvent("itemget", ItemGet)
	inst:ListenForEvent("itemlose", ItemLose)
	inst:ListenForEvent("death", OnDeath)

	inst.SetGlow = SetGlow
	
	inst._GlowTask = inst:DoTaskInTime(0, GlowTask)
end

return MakePlayerCharacter("warne", prefabs, assets, common_postinit, master_postinit)