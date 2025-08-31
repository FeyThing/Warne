local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local Health = require("components/health")

local OldDoDelta = Health.DoDelta
function Health:DoDelta(amount, overtime, cause, ...)
	if self.inst:HasTag("lich") and cause and cause == "wortox_soul" then
		amount = 0
	end
	
	OldDoDelta(self, amount, overtime, cause, ...)
end

--

function DoLichTween(inst)
	if inst.erode_task then
		return
	end
	
	inst.lichtween_out = not inst.lichtween_out
	if inst.lichtween_out then
		inst.components.colourtweener:StartTween({36 / 255, 30 / 255, 45 / 255, 0.9}, 0.8)
	else
		inst.components.colourtweener:StartTween({19 / 255, 15 / 255, 22 / 255, 0.6}, 0.9)
	end
	
	if inst._liched_fx and inst._liched_fx:IsValid() then
		local bbx1, bby1, bbx2, bby2 = inst.AnimState:GetVisualBB()
		local bbx = bbx2 - bbx1
		local bby = bby2 - bby1
		
		inst._liched_fx.AnimState:SetScale(math.max(bbx / 2.25, 1), math.max(bby / 2.5, 1))
	end
end

function LichErodeStart(inst)
	inst:AddTag("death_liched")
	
	if inst.components.colourtweener == nil then
		inst:AddComponent("colourtweener")
	end
	
	if inst._liched_fx == nil then
		inst._liched_fx = SpawnPrefab("shadow_trap_debuff_fx")
		inst._liched_fx.entity:SetParent(inst.entity)
	end
	if inst._lichtween_task == nil then
		inst._lichtween_task = inst:DoPeriodicTask(1, DoLichTween, 0)
	end
end

function LichErodeOver(inst, absorber)
	inst:AddTag("NOCLICK")
	inst:RemoveTag("death_liched")
	
	local self = inst.components.health
	if inst.components.colourtweener == nil then
		inst:AddComponent("colourtweener")
	end
	
	if inst._liched_fx and inst._liched_fx:IsValid() then
		inst._liched_fx:Remove()
		inst._liched_fx = nil
	end
	if inst._lichtween_task then
		inst._lichtween_task:Cancel()
		inst._lichtween_task = nil
	end
	
	if inst.erode_task == nil then
		inst.erode_task = self.inst:DoTaskInTime(0, ErodeAway)
	end
	
	if self then
		self.lich_erode_task_start = nil
		self.lich_erode_task_over = nil
	end
	
	local fx = SpawnPrefab("shadow_merm_spawn_poof_fx")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	if absorber then
		local orb = SpawnPrefab("darkenessorbs")
		
		orb.entity:AddFollower()
		orb.Follower:FollowSymbol(absorber.GUID, "hand", 0, 0, 0)
	end
end

local OldSetVal = Health.SetVal
function Health:SetVal(val, cause, afflicter, ...)
	OldSetVal(self, val, cause, afflicter, ...)
	
	if afflicter and (afflicter:HasTag("lich") or afflicter:HasTag("warneminion")) then
		self.lich_afflicted = true
	end
	
	if self.lich_afflicted then --and (not self.nofadeout or self.fadeout_lich_exception) then
		self.inst:RemoveTag("NOCLICK")
		
		if self.inst.erode_task then
			self.inst.erode_task:Cancel()
			self.inst.erode_task = nil
			
			self.lich_erode_task_start = self.inst:DoTaskInTime(TUNING.LICH_ERODE_START_TIME, LichErodeStart)
			self.lich_erode_task_over = self.inst:DoTaskInTime(TUNING.LICH_ERODE_OVER_TIME, LichErodeOver)
		end
	end
end