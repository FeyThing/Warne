require("stategraphs/commonstates")

local function DoEquipmentFoleySounds(inst)
	for k, v in pairs(inst.components.inventory.equipslots) do
		if v.foleysound ~= nil then
			inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
		end
	end
end

local function DoFoleySounds(inst)
	DoEquipmentFoleySounds(inst)
	if inst.foleysound ~= nil then
		inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
	end
end

local DoRunSounds = function(inst)
	if inst.sg.mem.footsteps > 3 then
		PlayFootstep(inst, 0.6, true)
	else
		inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
		PlayFootstep(inst, 1, true)
	end
end

local function GetUnequipState(inst, data)
	return (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
		or (not data.slip and "item_in")
		or (data.item ~= nil and data.item:IsValid() and "tool_slip")
		or "toolbroke", data.item
end

local function ConfigureRunState(inst)
	if inst.components.inventory:IsHeavyLifting() then
		inst.sg.statemem.heavy = true
	elseif inst:HasTag("groggy") then
		inst.sg.statemem.groggy = true
	else
		inst.sg.statemem.normal = true
	end
end

local function GetRunStateAnim(inst)
	return (inst.sg.statemem.heavy and "heavy_walk")
		or (inst.sg.statemem.groggy and "idle_walk")
		or (inst.sg.statemem.careful and "careful_walk")
		or "run"
end

local function ForceStopHeavyLifting(inst)
	if inst.components.inventory:IsHeavyLifting() then
		inst.components.inventory:DropItem(inst.components.inventory:Unequip(EQUIPSLOTS.BODY), true, true)
	end
end

local actionhandlers = {
	ActionHandler(ACTIONS.ATTACK,
		function(inst, action)
			if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
				local weapon = inst.components.combat and inst.components.combat:GetWeapon() or nil
				
				if weapon == nil then
					return "attack"
				end
				
				return (weapon:HasOneOfTags({"blowdart", "blowpipe"}) and "blowdart")
					or (weapon:HasTag("thrown") and "throw")
					or (weapon:HasTag("pillow") and "attack_pillow_pre")
					or "attack"
			end
		end),
	ActionHandler(ACTIONS.CHOP,
		function(inst)
			return not inst.sg:HasStateTag("prechop")
				and (inst.sg:HasStateTag("chopping") and
					"chop" or
					"chop_start")
				or nil
		end),
	ActionHandler(ACTIONS.MINE,
		function(inst)
			return not inst.sg:HasStateTag("premine")
				and (inst.sg:HasStateTag("mining") and
					"mine" or
					"mine_start")
				or nil
		end),
	ActionHandler(ACTIONS.HAMMER,
		function(inst)
			return not inst.sg:HasStateTag("prehammer")
				and (inst.sg:HasStateTag("hammering") and
					"hammer" or
					"hammer_start")
				or nil
		end),
	ActionHandler(ACTIONS.DIG,
		function(inst)
			return not inst.sg:HasStateTag("predig")
				and (inst.sg:HasStateTag("digging") and
					"dig" or
					"dig_start")
				or nil
		end),
	ActionHandler(ACTIONS.DROP, "doshortaction"),
	ActionHandler(ACTIONS.PICK,
		function(inst, action)
			return action.target ~= nil
				and action.target.components.pickable ~= nil
				and ((action.target.components.pickable.jostlepick and "dojostleaction") or
					(inst:HasTag("fastpicker") and "doshortaction") or
					"dolongaction")
				or nil
		end),
	ActionHandler(ACTIONS.TAKEITEM,
		function(inst, action)
			return action.target ~= nil
				and action.target.takeitem ~= nil
				and "give"
				or "dolongaction"
		end),
	ActionHandler(ACTIONS.PICKUP, "doshortaction",
		function(inst, action)
			return action.target ~= nil
				and action.target:HasTag("minigameitem")
				and "dosilentshortaction"
				or "doshortaction"
		end),
	ActionHandler(ACTIONS.ACTIVATE,
		function(inst, action)
			local obj = action.target or action.invobject
			return action.target.components.activatable ~= nil
				and ((action.target.components.activatable.standingaction and "dostandingaction") 
				or (action.target.components.activatable.quickaction and "doshortaction")
				or "dolongaction") or nil
		end),
	ActionHandler(ACTIONS.GIVE, "give"),
	ActionHandler(ACTIONS.GIVETOPLAYER, "give"),
	ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
	ActionHandler(ACTIONS.DROP, "dropitem"),
	ActionHandler(ACTIONS.UNPIN, "doshortaction"),
	ActionHandler(ACTIONS.FEEDPLAYER, "give"),
	ActionHandler(ACTIONS.HARVEST, "harvest"),
}

local events = {
	CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(nil, TUNING.PIG_MAX_STUN_LOCKS),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnHop(),
	EventHandler("freeze", function(inst)
		inst.sg:GoToState("frozen")
	end),
	EventHandler("locomote", function(inst, data)
		if inst.sg:HasStateTag("busy") then
			return
		end
		local is_moving = inst.sg:HasStateTag("moving")
		local should_move = inst.components.locomotor:WantsToMoveForward()
		
		if is_moving and not should_move then
			inst.sg:GoToState("run_stop")
		elseif not is_moving and should_move then
			inst.sg:GoToState("run_start")
		elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle"))  then
			inst.sg:GoToState("idle")
		end
	end),
	EventHandler("equip", function(inst, data)
		if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
			inst.sg:GoToState("heavylifting_start")
		elseif inst.components.inventory:IsHeavyLifting() then
			if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
				inst.sg:GoToState("heavylifting_item_hat")
			end
		elseif (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
			inst.sg:GoToState(
				(data.item ~= nil and data.item.projectileowner ~= nil and "catch_equip") or
				(data.eslot == EQUIPSLOTS.HANDS and "item_out") or
				"item_hat"
			)
		elseif data.item ~= nil and data.item.projectileowner ~= nil then
			SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
		end
	end),
	EventHandler("unequip", function(inst, data)
		if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
			if not inst.sg:HasStateTag("busy") then
				inst.sg:GoToState("heavylifting_stop")
			end
		elseif inst.components.inventory:IsHeavyLifting() then
			if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
				inst.sg:GoToState("heavylifting_item_hat")
			end
		elseif inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
			inst.sg:GoToState(GetUnequipState(inst, data))
		end
	end),
	EventHandler("toolbroke",
		function(inst, data)
			inst.sg:GoToState("toolbroke", data.tool)
		end),
	EventHandler("itemranout",
		function(inst, data)
			if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
				local sameTool = inst.components.inventory:FindItem(function(item)
					return item.prefab == data.prefab and
						item.components.equippable ~= nil and
						item.components.equippable.equipslot == data.equipslot
				end)
				if sameTool ~= nil then
					inst.components.inventory:Equip(sameTool)
				end
			end
		end),
}

local states = {
	State{
		name = "idle",
		tags = {"idle", "canrotate"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_loop")
		end,
		
		events = {
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end)
		},
	},
	
	State{
		name = "refuse",
		tags = {"busy", "pausepredict"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.components.locomotor:Clear()
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.components.inventory:IsHeavyLifting() and "heavy_refuseeat" or "refuseeat")
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "frozen",
		tags = {"busy", "frozen", "nopredict", "nodangle"},
		
		onenter = function(inst)
			if inst.components.pinnable and inst.components.pinnable:IsStuck() then
				inst.components.pinnable:Unstick()
			end
			
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			
			inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
			inst.AnimState:PlayAnimation("frozen")
			inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
			
			inst.components.inventory:Hide()
			if inst.components.freezable == nil then
				inst.sg:GoToState("hit", true)
			elseif inst.components.freezable:IsThawing() then
				inst.sg.statemem.isstillfrozen = true
				inst.sg:GoToState("thaw")
			elseif not inst.components.freezable:IsFrozen() then
				inst.sg:GoToState("hit", true)
			end
		end,
		
		events = {
			EventHandler("onthaw", function(inst)
				inst.sg.statemem.isstillfrozen = true
				inst.sg:GoToState("thaw")
			end),
			EventHandler("unfreeze", function(inst)
				inst.sg:GoToState("hit", true)
			end),
		},
		
		onexit = function(inst)
			if not inst.sg.statemem.isstillfrozen then
				inst.components.inventory:Show()
			end
			inst.AnimState:ClearOverrideSymbol("swap_frozen")
		end,
	},
	
	State{
		name = "thaw",
		tags = {"busy", "thawing", "nopredict", "nodangle"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			
			inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
			inst.AnimState:PlayAnimation("frozen_loop_pst", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
			
			inst.components.inventory:Hide()
			inst:PushEvent("ms_closepopups")
		end,
		
		events = {
			EventHandler("unfreeze", function(inst)
				inst.sg:GoToState("hit", true)
			end),
		},
		
		onexit = function(inst)
			inst.components.inventory:Show()
			inst.SoundEmitter:KillSound("thawing")
			inst.AnimState:ClearOverrideSymbol("swap_frozen")
		end,
	},
	
	State{
		name = "dostandingaction",
		tags = {"doing", "busy"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("give")
			inst.AnimState:PushAnimation("give_pst", false)
			
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(14 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(6 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			TimeEvent(12 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:GoToState("idle", true)
		end,
		
		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "doshortaction",
		tags = {"doing", "busy"},
		
		onenter = function(inst, silent)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("pickup")
			inst.AnimState:PushAnimation("pickup_pst", false)
			
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg.statemem.silent = silent
			inst.sg:SetTimeout(10 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			TimeEvent(6 * FRAMES, function(inst)
				if inst.sg.statemem.silent then
					inst:PerformBufferedAction()
				else
					inst:PerformBufferedAction()
				end
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:GoToState("idle", true)
		end,
		
		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "dosilentshortaction",
		
		onenter = function(inst)
			inst.sg:GoToState("doshortaction", true)
		end,
	},
	
	State{
		name = "domediumaction",
		
		onenter = function(inst)
			inst.sg:GoToState("dolongaction", 0.5)
		end,
	},
	
	State{
		name = "dolongaction",
		tags = {"doing", "busy", "nodangle"},
		
		onenter = function(inst, timeout)
			if timeout == nil then
				timeout = 1
			elseif timeout > 1 then
				inst.sg:AddStateTag("slowaction")
			end
			inst.sg:SetTimeout(timeout)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
			
			inst.AnimState:PlayAnimation("build_pre")
			inst.AnimState:PushAnimation("build_loop", true)
		end,
		
		ontimeout = function(inst)
			inst.SoundEmitter:KillSound("make")
			inst.AnimState:PlayAnimation("build_pst")
			inst:PerformBufferedAction()
		end,
		
		events = {
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			inst.SoundEmitter:KillSound("make")
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "attack",
		tags = {"attack", "notalking", "abouttoattack", "autopredict"},
		
		onenter = function(inst)
			if inst.components.combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end
			
			if inst.sg.laststate == inst.sg.currentstate then
				inst.sg.statemem.chained = true
			end
			
			local buffaction = inst:GetBufferedAction()
			local target = buffaction ~= nil and buffaction.target or nil
			local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.components.combat:SetTarget(target)
			inst.components.combat:StartAttack()
			inst.components.locomotor:Stop()
			
			local cooldown = inst.components.combat.min_attack_period
			if equip and equip:HasTag("toolpunch") then
				inst.AnimState:PlayAnimation("toolpunch")
				inst.sg.statemem.istoolpunch = true
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, inst.sg.statemem.attackvol, true)
				cooldown = math.max(cooldown, 13 * FRAMES)
			elseif equip and equip:HasTag("whip") then
				inst.AnimState:PlayAnimation("whip_pre")
				inst.AnimState:PushAnimation("whip", false)
				inst.sg.statemem.iswhip = true
				inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
				cooldown = math.max(cooldown, 17 * FRAMES)
			elseif equip and equip:HasTag("pocketwatch") then
				inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
				inst.AnimState:PushAnimation("pocketwatch_atk", false)
				inst.sg.statemem.ispocketwatch = true
				cooldown = math.max(cooldown, 15 * FRAMES)
				if equip:HasTag("shadow_item") then
					inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
					inst.AnimState:Show("pocketwatch_weapon_fx")
					inst.sg.statemem.ispocketwatch_fueled = true
				else
					inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
					inst.AnimState:Hide("pocketwatch_weapon_fx")
				end
			elseif equip and equip:HasTag("book") then
				inst.AnimState:PlayAnimation("attack_book")
				inst.sg.statemem.isbook = true
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
				cooldown = math.max(cooldown, 19 * FRAMES)
			elseif equip and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
				inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
				inst.AnimState:PushAnimation("woodie_chop_loop", false)
				inst.sg.statemem.ischop = true
				cooldown = math.max(cooldown, 11 * FRAMES)
			elseif equip and equip:HasTag("jab") then
				inst.AnimState:PlayAnimation("spearjab_pre")
				inst.AnimState:PushAnimation("spearjab", false)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
				cooldown = math.max(cooldown, 21 * FRAMES)
			elseif equip and equip.components.weapon and not equip:HasTag("punch") then
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
				if (equip.projectiledelay or 0) > 0 then
					inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
					if inst.sg.statemem.projectiledelay > FRAMES then
						inst.sg.statemem.projectilesound =
							(equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
							(equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
							(equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
							"dontstarve/wilson/attack_weapon"
					elseif inst.sg.statemem.projectiledelay <= 0 then
						inst.sg.statemem.projectiledelay = nil
					end
				end
				if inst.sg.statemem.projectilesound == nil then
					inst.SoundEmitter:PlaySound(
						(equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
						(equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
						(equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
						(equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
						"dontstarve/wilson/attack_weapon",
						nil, nil, true
					)
				end
				cooldown = math.max(cooldown, 13 * FRAMES)
			elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
				cooldown = math.max(cooldown, 13 * FRAMES)
			else
				inst.AnimState:PlayAnimation("punch")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
				cooldown = math.max(cooldown, 24 * FRAMES)
			end
			
			inst.sg:SetTimeout(cooldown)
			
			if target then
				inst.components.combat:BattleCry()
				if target:IsValid() then
					inst:FacePoint(target:GetPosition())
					inst.sg.statemem.attacktarget = target
					inst.sg.statemem.retarget = target
				end
			end
		end,
		
		onupdate = function(inst, dt)
			if (inst.sg.statemem.projectiledelay or 0) > 0 then
				inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
				if inst.sg.statemem.projectiledelay <= FRAMES then
					if inst.sg.statemem.projectilesound ~= nil then
						inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
						inst.sg.statemem.projectilesound = nil
					end
					if inst.sg.statemem.projectiledelay <= 0 then
						inst:PerformBufferedAction()
						inst.sg:RemoveStateTag("abouttoattack")
					end
				end
			end
		end,
		
		timeline = {
			TimeEvent(6 * FRAMES, function(inst)
				if inst.sg.statemem.ischop then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
				end
			end),
			TimeEvent(8 * FRAMES, function(inst)
				if not (inst.sg.statemem.iswhip or
						inst.sg.statemem.ispocketwatch or
						inst.sg.statemem.isbook) and
					inst.sg.statemem.projectiledelay == nil then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
			TimeEvent(10 * FRAMES, function(inst)
				if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
			TimeEvent(17 * FRAMES, function(inst)
				if inst.sg.statemem.ispocketwatch then
					inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
				end
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:RemoveStateTag("attack")
			inst.sg:AddStateTag("idle")
		end,

		events = {
			EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
	},
	
	State{
		name = "attack_pillow_pre",
		tags = {"doing", "busy", "notalking"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pillow_pre")
			inst.AnimState:PushAnimation("atk_pillow_hold", true)
			
			local buffaction = inst:GetBufferedAction()
			if buffaction and buffaction.target and buffaction.target:IsValid() then
				inst:ForceFacePoint(buffaction.target.Transform:GetWorldPosition())
			end
			
			local pillow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.sg:SetTimeout((pillow and pillow._laglength) or 1)
		end,
		
		events = {
			EventHandler("unequip", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:GoToState("attack_pillow")
		end,
	},
	
	State{
		name = "attack_pillow",
		tags = {"doing", "busy", "notalking", "pausepredict"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pillow")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
		end,
		
		timeline = {
			TimeEvent(FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
			TimeEvent(13 * FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},
		
		events = {
			EventHandler("unequip", function(inst)
				inst.sg:GoToState("idle")
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "blowdart",
		tags = {"attack", "notalking", "abouttoattack", "autopredict"},
		
		onenter = function(inst)
			if inst.components.combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end
			
			local buffaction = inst:GetBufferedAction()
			local target = buffaction and buffaction.target or nil
			local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.components.combat:SetTarget(target)
			inst.components.combat:StartAttack()
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("dart_pre")
			
			if inst.sg.laststate == inst.sg.currentstate then
				inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(5)
			end
			inst.AnimState:PushAnimation("dart", false)
			
			inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, inst.components.combat.min_attack_period))
			
			if target and target:IsValid() then
				inst:FacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.attacktarget = target
				inst.sg.statemem.retarget = target
			end
			
			if (equip and equip.projectiledelay or 0) > 0 then
				inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 9 or 14) * FRAMES - equip.projectiledelay
				if inst.sg.statemem.projectiledelay <= 0 then
					inst.sg.statemem.projectiledelay = nil
				end
			end
		end,
		
		onupdate = function(inst, dt)
			if (inst.sg.statemem.projectiledelay or 0) > 0 then
				inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
				if inst.sg.statemem.projectiledelay <= 0 then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end
		end,
		
		timeline = {
			TimeEvent(8 * FRAMES, function(inst)
				if inst.sg.statemem.chained then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
				end
			end),
			TimeEvent(9 * FRAMES, function(inst)
				if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
			TimeEvent(13 * FRAMES, function(inst)
				if not inst.sg.statemem.chained then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
				end
			end),
			TimeEvent(14 * FRAMES, function(inst)
				if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:RemoveStateTag("attack")
			inst.sg:AddStateTag("idle")
		end,
		
		events = {
			EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
	},
	
	State{
		name = "throw",
		tags = {"attack", "notalking", "abouttoattack", "autopredict"},
		
		onenter = function(inst)
			if inst.components.combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end
			
			local buffaction = inst:GetBufferedAction()
			local target = buffaction and buffaction.target or nil
			inst.components.combat:SetTarget(target)
			inst.components.combat:StartAttack()
			inst.components.locomotor:Stop()
			
			local cooldown = math.max(inst.components.combat.min_attack_period, 11 * FRAMES)
			
			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw", false)
			
			inst.sg:SetTimeout(cooldown)
			
			if target and target:IsValid() then
				inst:FacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.attacktarget = target
				inst.sg.statemem.retarget = target
			end
		end,
		
		timeline = {
			TimeEvent(7 * FRAMES, function(inst)
				if inst:PerformBufferedAction() then
					inst.sg.statemem.thrown = true
				end
				inst.sg:RemoveStateTag("abouttoattack")
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:RemoveStateTag("attack")
			inst.sg:AddStateTag("idle")
		end,
		
		events = {
			EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("unequip", function(inst, data)
				if inst.sg.statemem.thrown and data.eslot == EQUIPSLOTS.HANDS then
					inst.sg.statemem.thrown = nil
				else
					inst.sg:GoToState("idle")
				end
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
	},
	
	State{
		name = "chop_start",
		tags = {"prechop", "working"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation(inst:HasTag("woodcutter") and "woodie_chop_pre" or "chop_pre")
			inst:AddTag("prechop")
		end,
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.chopping = true
					inst.sg:GoToState("chop")
				end
			end),
		},
		
		onexit = function(inst)
			if not inst.sg.statemem.chopping then
				inst:RemoveTag("prechop")
			end
		end,
	},
	
	State{
		name = "chop",
		tags = {"prechop", "chopping", "working"},
		
		onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
			inst.sg.statemem.iswoodcutter = inst:HasTag("woodcutter")
			inst.AnimState:PlayAnimation(inst.sg.statemem.iswoodcutter and "woodie_chop_loop" or "chop_loop")
			inst:AddTag("prechop")
		end,
		
		timeline = {
			TimeEvent(2 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst:PerformBufferedAction()
				end
			end),
			
			TimeEvent(5 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("prechop")
					inst:RemoveTag("prechop")
				end
			end),
			
			TimeEvent(10 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter and inst.sg.statemem.action and
					inst.sg.statemem.action:IsValid() and
					inst.sg.statemem.action.target and
					inst.sg.statemem.action.target.components.workable and
					inst.sg.statemem.action.target.components.workable:CanBeWorked() and
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					
					inst.sg.statemem.action.options.no_predict_fastforward = true
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),
			
			TimeEvent(12 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("chopping")
				end
			end),
			
			TimeEvent(2 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst:PerformBufferedAction()
				end
			end),
			
			TimeEvent(9 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("prechop")
					inst:RemoveTag("prechop")
				end
			end),
			
			TimeEvent(14 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter and inst.sg.statemem.action and
					inst.sg.statemem.action:IsValid() and
					inst.sg.statemem.action.target and
					inst.sg.statemem.action.target.components.workable and
					inst.sg.statemem.action.target.components.workable:CanBeWorked() and
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					
					inst.sg.statemem.action.options.no_predict_fastforward = true
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),
			
			TimeEvent(16 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("chopping")
				end
			end),
		},
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			inst:RemoveTag("prechop")
		end,
	},
	
	State{
		name = "mine_start",
		tags = {"premine", "working"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("pickaxe_pre")
			inst:AddTag("premine")
		end,
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.mining = true
					inst.sg:GoToState("mine")
				end
			end),
		},
		
		onexit = function(inst)
			if not inst.sg.statemem.mining then
				inst:RemoveTag("premine")
			end
		end,
	},
	
	State{
		name = "mine",
		tags = {"premine", "mining", "working"},
		
		onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
			inst.AnimState:PlayAnimation("pickaxe_loop")
			inst:AddTag("premine")
		end,
		
		timeline = {
			TimeEvent(7 * FRAMES, function(inst)
				if inst.sg.statemem.action ~= nil then
					PlayMiningFX(inst, inst.sg.statemem.action.target)
				end
				inst.sg.statemem.recoilstate = "mine_recoil"
				inst:PerformBufferedAction()
			end),
			
			TimeEvent(9 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("premine")
				inst:RemoveTag("premine")
			end),
			
			TimeEvent(14 * FRAMES, function(inst)
				if inst.sg.statemem.action and
					inst.sg.statemem.action:IsValid() and
					inst.sg.statemem.action.target and
					inst.sg.statemem.action.target.components.workable and
					inst.sg.statemem.action.target.components.workable:CanBeWorked() and
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					
					inst.sg.statemem.action.options.no_predict_fastforward = true
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),
		},
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("pickaxe_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
		},
		
		onexit = function(inst)
			inst:RemoveTag("premine")
		end,
	},
	
	State{
		name = "mine_recoil",
		tags = {"busy", "nopredict", "nomorph"},
		
		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			
			inst.AnimState:PlayAnimation("pickaxe_recoil")
			if data and data.target and data.target:IsValid() then
				SpawnPrefab("impact").Transform:SetPosition(data.target.Transform:GetWorldPosition())
			end
			
			inst.Physics:SetMotorVel(-6, 0, 0)
		end,
		
		onupdate = function(inst)
			if inst.sg.statemem.speed then
				inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
			end
		end,
		
		timeline = {
			FrameEvent(4, function(inst)
				inst.sg.statemem.speed = -3
			end),
			FrameEvent(17, function(inst)
				inst.sg.statemem.speed = nil
				inst.Physics:Stop()
			end),
			FrameEvent(23, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nopredict")
				inst.sg:RemoveStateTag("nomorph")
			end),
			FrameEvent(30, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			inst.Physics:Stop()
		end,
	},
	
	State{
		name = "hammer_start",
		tags = {"prehammer", "working"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("pickaxe_pre")
			inst:AddTag("prehammer")
		end,
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.hammering = true
					inst.sg:GoToState("hammer")
				end
			end),
		},
		
		onexit = function(inst)
			if not inst.sg.statemem.hammering then
				inst:RemoveTag("prehammer")
			end
		end,
	},
	
	State{
		name = "hammer",
		tags = {"prehammer", "hammering", "working"},
		
		onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
			inst.AnimState:PlayAnimation("pickaxe_loop")
			inst:AddTag("prehammer")
		end,
		
		timeline = {
			TimeEvent(7 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sg.statemem.action and inst.sg.statemem.action.invobject and inst.sg.statemem.action.invobject.hit_skin_sound or "dontstarve/wilson/hit")
				inst.sg.statemem.recoilstate = "mine_recoil"
				inst:PerformBufferedAction()
			end),
			
			TimeEvent(9 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("prehammer")
				inst:RemoveTag("prehammer")
			end),
			
			TimeEvent(14 * FRAMES, function(inst)
				if inst.sg.statemem.action and
					inst.sg.statemem.action:IsValid() and
					inst.sg.statemem.action.target and
					inst.sg.statemem.action.target.components.workable and
					inst.sg.statemem.action.target.components.workable:CanBeWorked() and
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					
					inst.sg.statemem.action.options.no_predict_fastforward = true
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),
		},
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("pickaxe_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
		},
		
		onexit = function(inst)
			inst:RemoveTag("prehammer")
		end,
	},
	
	State{
		name = "dig_start",
		tags = {"predig", "working"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("shovel_pre")
			inst:AddTag("predig")
		end,
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.digging = true
					inst.sg:GoToState("dig")
				end
			end),
		},
		
		onexit = function(inst)
			if not inst.sg.statemem.digging then
				inst:RemoveTag("predig")
			end
		end,
	},
	
	State{
		name = "dig",
		tags = {"predig", "digging", "working"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("shovel_loop")
			inst.sg.statemem.action = inst:GetBufferedAction()
			inst:AddTag("predig")
		end,
		
		timeline = {
			TimeEvent(15 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("predig")
				inst:RemoveTag("predig")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
				inst:PerformBufferedAction()
			end),
			
			TimeEvent(35 * FRAMES, function(inst)
				if inst.sg.statemem.action and
					inst.sg.statemem.action:IsValid() and
					inst.sg.statemem.action.target and
					inst.sg.statemem.action.target.components.workable and
					inst.sg.statemem.action.target.components.workable:CanBeWorked() and
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					
					inst.sg.statemem.action.options.no_predict_fastforward = true
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),
		},
		
		events = {
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("shovel_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
		},
		
		onexit = function(inst)
			inst:RemoveTag("predig")
		end,
	},
	
	State{
		name = "harvest",
		tags = {"doing", "busy", "nodangle"},
		
		onenter = function(inst, timeout)
			if timeout == nil then
				timeout = 1
			elseif timeout > 1 then
				inst.sg:AddStateTag("slowaction")
			end
			inst.sg:SetTimeout(timeout)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
			inst.AnimState:PlayAnimation("build_pre")
			inst.AnimState:PushAnimation("build_loop", true)
			
			if inst.bufferedaction then
				inst.sg.statemem.action = inst.bufferedaction
				if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
					inst.bufferedaction.target:PushEvent("startlongaction")
				end
			end
		end,
		
		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
		
		ontimeout = function(inst)
			inst.SoundEmitter:KillSound("make")
			inst.AnimState:PlayAnimation("build_pst")
			inst:PerformBufferedAction()
		end,
		
		onexit = function(inst)
			inst.SoundEmitter:KillSound("make")
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "give",
		tags = {"giving"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("give")
			inst.AnimState:PushAnimation("give_pst", false)
		end,
		
		timeline = {
			TimeEvent(13 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
		},
		
		events = {
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "dropitem",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("pickup")
			inst.AnimState:PushAnimation("pickup_pst", false)
		end,
		
		timeline = {
			TimeEvent(6 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
		},
		
		events = {
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "hit",
		tags = {"busy", "pausepredict"},
		
		onenter = function(inst, frozen)
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			
			inst.AnimState:PlayAnimation("hit")
			
			local stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), frozen and 10 or 6)
			inst.sg:SetTimeout(stun_frames * FRAMES)
		end,
		
		ontimeout = function(inst)
			inst.sg:GoToState("idle", true)
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "death",
		tags = {"busy", "dead", "pausepredict", "nomorph"},

		onenter = function(inst)		
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst.components.locomotor:Clear()
			inst:ClearBufferedAction()
			
			inst.components.inventory:DropEverything(true)
			inst.AnimState:PlayAnimation("death")
			inst.AnimState:Hide("swap_arm_carry")
			
			if inst.components.burnable then
				inst.components.burnable:Extinguish()
			end
		end,
	},
	
	State{
		name = "item_hat",
		tags = {"idle"},
		
		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_hat")
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "item_in",
		tags = {"idle", "nodangle", "busy"},
		
		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_in")
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			if inst.sg.statemem.followfx then
				for i, v in ipairs(inst.sg.statemem.followfx) do
					v:Remove()
				end
			end
		end,
	},
	
	State{
		name = "item_out",
		tags = {"idle", "nodangle"},
		
		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_out")
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "run_start",
		tags = {"moving", "running", "canrotate", "autopredict"},
		
		onenter = function(inst)
			ConfigureRunState(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pre")

			inst.sg.mem.footsteps = 0
		end,
		
		onupdate = function(inst)
			inst.components.locomotor:RunForward()
		end,
		
		timeline = {
			TimeEvent(1 * FRAMES, function(inst)
				if inst.sg.statemem.heavy then
					PlayFootstep(inst, nil, true)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(4 * FRAMES, function(inst)
				if inst.sg.statemem.normal then
					PlayFootstep(inst, nil, true)
					DoFoleySounds(inst)
				end
			end),
		},
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},
	},
	
	State{
		name = "run",
		tags = {"moving", "running", "canrotate", "autopredict"},
		
		onenter = function(inst)
			ConfigureRunState(inst)
			inst.components.locomotor:RunForward()
			
			local anim = GetRunStateAnim(inst)
			if anim == "run" then
				anim = "run_loop"
			end
			if not inst.AnimState:IsCurrentAnimation(anim) then
				inst.AnimState:PlayAnimation(anim, true)
			end
			
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,
		
		onupdate = function(inst)
			inst.components.locomotor:RunForward()
		end,
		
		timeline = {
			TimeEvent(7 * FRAMES, function(inst)
				if inst.sg.statemem.normal then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(15 * FRAMES, function(inst)
				if inst.sg.statemem.normal then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(26 * FRAMES, function(inst)
				if inst.sg.statemem.careful then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(1 * FRAMES, function(inst)
				if inst.sg.statemem.groggy then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(12 * FRAMES, function(inst)
				if inst.sg.statemem.groggy then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(11 * FRAMES, function(inst)
				if inst.sg.statemem.heavy then
					DoRunSounds(inst)
					DoFoleySounds(inst)
					if inst.sg.mem.footsteps > 3 then
						inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
					end
				elseif inst.sg.statemem.careful then
					DoRunSounds(inst)
					DoFoleySounds(inst)
				end
			end),
			
			TimeEvent(36 * FRAMES, function(inst)
				if inst.sg.statemem.heavy then
					DoRunSounds(inst)
					DoFoleySounds(inst)
					if inst.sg.mem.footsteps > 12 then
						inst.sg.mem.footsteps = math.random(4, 6)
						inst:PushEvent("encumberedwalking")
					elseif inst.sg.mem.footsteps > 3 then
						inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
					end
				end
			end),
		},
		
		events = {
			EventHandler("carefulwalking", function(inst, data)
				if not data.careful then
					if inst.sg.statemem.careful then
						inst.sg:GoToState("run")
					end
				elseif not (inst.sg.statemem.heavy or
							inst.sg.statemem.groggy or
							inst.sg.statemem.careful) then
					inst.sg:GoToState("run")
				end
			end),
		},
		
		ontimeout = function(inst)
			inst.sg:GoToState("run")
		end,
	},
	
	State{
		name = "run_stop",
		tags = {"canrotate", "idle", "autopredict"},
		
		onenter = function(inst)
			ConfigureRunState(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	
	State{
		name = "warne_resurrected",
		tags = {"busy", "nopredict", "silentmorph"},
		
		onenter = function(inst, source)
			if source == nil or source:HasTag("skeleton") then
				inst.AnimState:PlayAnimation("wakeup")
			else
				inst.AnimState:OverrideSymbol("wormmovefx", "mole_build", "wormmovefx")
				inst.AnimState:PlayAnimation("grave_spawn")
				inst.SoundEmitter:PlaySound("meta5/wendy/revive_emerge")
			end
			
			inst.components.health:SetInvincible(true)
		end,
		
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		
		onexit = function(inst)
			inst.components.health:SetInvincible(false)
		end,
	},
}

return StateGraph("warneminion", states, events, "idle", actionhandlers)