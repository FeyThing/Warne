local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddStategraphPostInit = ENV.AddStategraphPostInit

local function DoTrail(inst)		
	if inst.sg and inst.sg:HasStateTag("running") then
		local fx2 = SpawnPrefab("cane_ancient_fx"..tostring(math.random(3)))
		fx2.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local states = {
	State{
		name = "deathtouch",
		tags = {"attack", "doing", "busy", "deathtouch"},
		
		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			local target = buffaction and buffaction.target or nil
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("give")
			inst.AnimState:PushAnimation("give_pst", false)
			inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f25")
			
			inst.sg.statemem.action = buffaction
		end,
		
		timeline = {
			TimeEvent(1 * FRAMES, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f25")
				local fx = SpawnPrefab("shadow_teleport_out")
				fx.Transform:SetPosition(x, y, z)
			end),
			TimeEvent(15 * FRAMES, function(inst)	
				inst.sg:RemoveStateTag("busy")
				inst:PerformBufferedAction()
			end),
			TimeEvent(19 * FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},
		
		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action and
			(inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "lichabsorb",
		tags = {"doing", "busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("deathtouch")
			inst.components.locomotor:Stop()
		end,
		
		timeline = {
			TimeEvent(6 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
		},
		
		events = {
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
	
	State{
		name = "run_float",
		tags = {"moving", "running", "canrotate", "flying", "noslip", "autopredict"},
		
		onenter = function(inst)
			inst.components.locomotor:RunForward()
			if not inst.AnimState:IsCurrentAnimation("float_loop") then
				inst.AnimState:PlayAnimation("float_loop", true)
			end			
			if inst.trailtask == nil then
				inst.trailtask = inst:DoPeriodicTask(0.2, DoTrail, FRAMES, inst)
			end
			
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,
		
		events = {
			EventHandler("carefulwalking", function(inst, data)
				if data.careful then	
						inst.sg:GoToState("run_float")					
				end
			end),
		},
		
		onupdate = function(inst)
			if not inst:HasTag("lich") then
				inst.sg:GoToState("run")
			end	
			inst.components.locomotor:RunForward()
		end,
		
		ontimeout = function(inst)
			inst.sg:GoToState("run_float")
		end,
	},
}

AddStategraphPostInit("wilson", function(sg)
	for _, state in pairs(states) do
		sg.states[state.name] = state
	end
	
	--Actionhandlers 
	
	local oldattack = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip == nil and inst:HasTag("lich") and not inst.components.rider:IsRiding() then
			return "deathtouch"
		end
		
		return oldattack(inst, action, ...)
	end
	
	--States
	
	local oldrun_start_onupdate = sg.states["run_start"].onupdate
	sg.states["run_start"].onupdate = function(inst, ...)
		oldrun_start_onupdate(inst, ...)
		if inst:HasTag("lich") and inst.AnimState:IsCurrentAnimation("run_pre") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.AnimState:PlayAnimation("float_pre")
		end
	end
	
	local oldrun_enter = sg.states["run"].onenter
	sg.states["run"].onenter = function(inst, ...)
		oldrun_enter(inst, ...)
		if inst:HasTag("lich") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.sg:GoToState("run_float")
			inst.components.locomotor:SetTriggersCreep(false)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:AddTag("bear_trap_immune")
		end
	end
	
	local oldrun_stop_enter = sg.states["run_stop"].onenter
	sg.states["run_stop"].onenter = function(inst, ...)
		oldrun_stop_enter(inst, ...)
		
		if inst:HasTag("lich") and inst.AnimState:IsCurrentAnimation("run_pst") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.AnimState:PlayAnimation("float_pst")
			inst.components.locomotor:SetTriggersCreep(true)
			inst:RemoveTag("bear_trap_immune")
		end
	end
end)

--- client
local TIMEOUT = 2

local client_states = {
	State{
		name = "deathtouch",
		tags = {"attack", "doing", "busy", "deathtouch"},
		
		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			local target = buffaction and buffaction.target or nil
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("give")
			inst.AnimState:PushAnimation("give_pst", false)
			inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f25")
			
			inst.sg.statemem.action = buffaction
		end,
		
		timeline = {
			TimeEvent(1 * FRAMES, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f25")
				local fx = SpawnPrefab("shadow_teleport_out")
				fx.Transform:SetPosition(x, y, z)
			end),
			TimeEvent(15 * FRAMES, function(inst)	
				inst.sg:RemoveStateTag("busy")
				inst:PerformBufferedAction()
				inst.sg:SetTimeout(TIMEOUT)
			end),
			TimeEvent(19 * FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},
		
		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action and
			(inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
				inst:ClearBufferedAction()
			end
		end,
	},
	
	State{
		name = "lichabsorb",
		tags = {"doing", "busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("deathtouch")
			inst.components.locomotor:Stop()
		end,
		
		timeline = {
			TimeEvent(6 * FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.sg:SetTimeout(TIMEOUT)
			end),
		},
		
		events = {
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
	
	State{
		name = "run_float",
		tags = {"moving", "running", "canrotate", "flying", "noslip", "autopredict"},
		
		onenter = function(inst)
			inst.components.locomotor:RunForward()
			if not inst.AnimState:IsCurrentAnimation("float_loop") then
				inst.AnimState:PlayAnimation("float_loop", true)
			end			
			if inst.trailtask == nil then
				inst.trailtask = inst:DoPeriodicTask(0.2, DoTrail, FRAMES, inst)
			end
			
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,
		
		events = {
			EventHandler("carefulwalking", function(inst, data)
				if data.careful then	
						inst.sg:GoToState("run_float")					
				end
			end),
		},
		
		onupdate = function(inst)
			if not inst:HasTag("lich") then
				inst.sg:GoToState("run")
			end	
			inst.components.locomotor:RunForward()
		end,
		
		ontimeout = function(inst)
			inst.sg:GoToState("run_float")
		end,
	},
}

AddStategraphPostInit("wilson_client", function(sg)
	for _, state in pairs(client_states) do
		sg.states[state.name] = state
	end
	
	--Actionhandlers 
	
	local oldattack = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip == nil and inst:HasTag("lich") and not inst.components.rider:IsRiding() then
			return "deathtouch"
		end
		
		return oldattack(inst, action, ...)
	end
	
	--States
	
	local oldrun_start_onupdate = sg.states["run_start"].onupdate
	sg.states["run_start"].onupdate = function(inst, ...)
		oldrun_start_onupdate(inst, ...)
		if inst:HasTag("lich") and inst.AnimState:IsCurrentAnimation("run_pre") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.AnimState:PlayAnimation("float_pre")
		end
	end
	
	local oldrun_enter = sg.states["run"].onenter
	sg.states["run"].onenter = function(inst, ...)
		oldrun_enter(inst, ...)
		if inst:HasTag("lich") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.sg:GoToState("run_float")
			inst.components.locomotor:SetTriggersCreep(false)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:AddTag("bear_trap_immune")
		end
	end
	
	local oldrun_stop_enter = sg.states["run_stop"].onenter
	sg.states["run_stop"].onenter = function(inst, ...)
		oldrun_stop_enter(inst, ...)
		
		if inst:HasTag("lich") and inst.AnimState:IsCurrentAnimation("run_pst") and not (inst.components.rider and inst.components.rider:IsRiding()) then
			inst.AnimState:PlayAnimation("float_pst")
			inst.components.locomotor:SetTriggersCreep(true)
			inst:RemoveTag("bear_trap_immune")
		end
	end
end)