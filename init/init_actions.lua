local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddAction = ENV.AddAction
local AddComponentAction = ENV.AddComponentAction
local AddStategraphActionHandler = ENV.AddStategraphActionHandler

local function WarneAction(name, act)
	local action = Action(act)
	action.id = name
	action.str = STRINGS.ACTIONS[name]
	AddAction(action)
	
	return action
end

--	Actions

local MINION_BONES_LOOTERS = {
	"hound", "pig", "epic", "largecreature",
}
local MINION_BONES_PARTS = {
	ribcage = 1,
	skull = 1,
	arm = 2,
	leg = 2,
}

local LICHABSORB = WarneAction("LICHABSORB", {distance = 15, priority = 2})
LICHABSORB.fn = function(act)
	if act.target and act.target:IsValid() then
		act.target:AddTag("NOCLICK")
		act.target:RemoveTag("death_liched")
		
		if act.target.erode_task then
			act.target.erode_task:Cancel()
		end
		
		local health = act.target.components.health
		if health then
			health.lich_erode_task_start = nil
			health.lich_erode_task_over = nil
			
			if act.doer and act.doer.components.inventory then
				local staff
				local equipped_staff = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
				
				if equipped_staff and equipped_staff:HasTag("lichfocus") and equipped_staff.components.finiteuses then
					staff = equipped_staff
				else
					staff = act.doer.components.inventory:FindItem(function(obj)
						return obj:HasTag("lichfocus") and obj.components.finiteuses and obj.components.finiteuses:GetPercent() < 1
					end)
				end
				
				if staff then
					local recharge = math.floor(health:GetMaxWithPenalty() / TUNING.LICH_ABSORB_STAFF_USE_PER_HP)
					staff.components.finiteuses:Repair(TUNING.LICH_ABSORB_STAFF_USES * recharge)
					
					if act.doer.SoundEmitter then
						act.doer.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
					end
				end
				
				--
				
				local souljar = act.doer.components.inventory:FindItem(function(obj)
					return obj:HasTag("phylactery") and obj.components.fueled and obj.components.fueled:GetPercent() < 1
					and obj.components.attunable and obj.components.attunable:IsAttuned(act.doer)
				end)
				
				if souljar then
					local repaired = math.floor(health:GetMaxWithPenalty() / TUNING.LICH_ABSORB_STAFF_USE_PER_HP)
					souljar.components.fueled:DoDelta(TUNING.WARNE_ABSORB_SOUL_USES * repaired)
					
					if act.doer.SoundEmitter then
						act.doer.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
					end
				end
			end
		end
		
		if act.target.components.lootdropper and act.target:HasAnyTag(MINION_BONES_LOOTERS) then
			local amt = (act.target:HasTag("epic") and 3 or 1) * (act.target:HasTag("largecreature") and 2 or 1)
			local rmd_chance = (act.target:HasTag("epic") and 0.5 or 0.25) + (act.target:HasTag("largecreature") and 0.25 or 0)
			for i = 1, amt do
				if math.random() < rmd_chance then
					act.target.components.lootdropper:SpawnLootPrefab("warnebone_"..weighted_random_choice(MINION_BONES_PARTS))
				end
			end
		end
		
		LichErodeOver(act.target, act.doer)
		
		return true
	end
	
	return false
end

local REZMINION = WarneAction("LICHRESURRECTMINION", {rmb = true, invalid_hold_action = true, distance = 1.8})
REZMINION.fn = function(act)
    if act.target and act.target.components.warne_rezminion then
		return act.target.components.warne_rezminion:Resurrect(act.doer)
    end
end


local ATTUNEFN = ACTIONS.ATTUNE.fn
ACTIONS.ATTUNE.fn = function(act)
	if act.doer and act.invobject and act.invobject.components.attunable then
		return act.invobject.components.attunable:LinkToPlayer(act.doer)
	end
	
	return ATTUNEFN(act)
end

--

local COMPONENT_ACTIONS = WarneUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")

local oldhealth = COMPONENT_ACTIONS.SCENE.health
COMPONENT_ACTIONS.SCENE.health = function(inst, doer, actions, right, ...)
	if doer:HasTag("lich") and inst:HasTag("death_liched") then
		table.insert(actions, ACTIONS.LICHABSORB)
	elseif oldhealth then
		oldhealth(inst, doer, actions, right, ...)
	end
end

local oldinventoryitem = COMPONENT_ACTIONS.INVENTORY.inventoryitem
COMPONENT_ACTIONS.INVENTORY.inventoryitem = function(inst, doer, actions, right, ...)
	if doer:HasTag("lich") and inst:HasTag("phylactery") then
		table.insert(actions, ACTIONS.ATTUNE)
	end
	if oldinventoryitem then
		oldinventoryitem(inst, doer, actions, right, ...)
	end
end

AddComponentAction("SCENE", "warne_rezminion", function(inst, doer, actions, right)
    if right and (not inst:HasTag("grave") or inst:HasTag("DIG_workable")) then
        table.insert(actions, ACTIONS.LICHRESURRECTMINION)
    end
end)

--

local function AddToSGAC(action, state)
	ENV.AddStategraphActionHandler("wilson", ActionHandler(ACTIONS[action], state))
	ENV.AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS[action], state))
end

local actionhandlers = {
	LICHABSORB = "lichabsorb",
	LICHRESURRECTMINION = "deathtouch",
}

for action, state in pairs(actionhandlers) do
	AddToSGAC(action, state)
end