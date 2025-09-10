require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require "brains/braincommon"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 30

local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local TRADE_DIST = 20

local SEE_WORKABLE_DIST = 15
local KEEP_WORKING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local function AttackTarget(inst)
	if inst.components.combat:InCooldown() then
		return nil
	end
	
	local target = inst.components.combat.target
	if not target then
		return nil
	end
	
	local range = inst.components.combat.attackrange
	if inst:GetDistanceSqToInst(target) > range * range then
		return nil
	end
	
	inst:FacePoint(target:GetPosition())
	return BufferedAction(inst, target, ACTIONS.ATTACK)
end

local function ShouldRunAway(inst, target)
	return not inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetTraderFn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
	
	for _, player in ipairs(players) do
		if inst.components.trader:IsTryingToTradeWithMe(player) then
			return player
		end
	end
end

local function KeepTraderFn(inst, target)
	return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function CanBeWorked(target, inst)
	local tool = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	local workaction = target.components.workable and target.components.workable.action
	
	if workaction and target.components.workable:CanBeWorked()
		and tool and tool.components.tool and tool.components.tool:CanDoAction(target.components.workable.action) then
		
		return workaction ~= ACTIONS.DIG or target:HasTag("stump")
	end
end

local function IsDeciduousTreeMonster(guy)
	return guy.monster and guy.prefab == "deciduoustree"
end

local WORK_TAGS = {"CHOP_workable", "MINE_workable", "DIG_workable", "HAMMER_workable"}
local WORK_NOT_TAGS = {"INLIMBO"}

local function FindDeciduousTreeMonster(inst)
	return FindEntity(inst, SEE_WORKABLE_DIST / 3, IsDeciduousTreeMonster, nil, WORK_NOT_TAGS, WORK_TAGS)
end

local function KeepWorkingAction(inst)
	return inst.work_target ~= nil
		or (inst.components.follower.leader ~= nil and
			inst:IsNear(inst.components.follower.leader, KEEP_WORKING_DIST))
		or FindDeciduousTreeMonster(inst) ~= nil
end

local function StartWorkingCondition(inst)
	return inst.work_target ~= nil
		or (inst.components.follower.leader ~= nil and
			inst.components.follower.leader.sg ~= nil and
			inst.components.follower.leader.sg:HasStateTag("working"))
		or FindDeciduousTreeMonster(inst) ~= nil
end

local function FindWorkableAction(inst)
	local target = FindEntity(inst, SEE_WORKABLE_DIST, function(target) return CanBeWorked(target, inst) end, nil, WORK_NOT_TAGS, WORK_TAGS)
	
	if target then
		if inst.work_target ~= nil then
			target = inst.work_target
			inst.work_target = nil
		else
			target = FindDeciduousTreeMonster(inst) or target
		end
		
		return BufferedAction(inst, target, target.components.workable.action)
	end
end

local function GetTargetPos(inst)
	return inst.components.combat.target and inst.components.combat.target:GetPosition()
end

local function GetLeader(inst)
	return inst.components.follower.leader
end

local function RescueLeaderAction(inst)
	return BufferedAction(inst, GetLeader(inst), ACTIONS.UNPIN)
end

local function GetFaceTargetFn(inst)
	return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
	return inst.components.follower.leader == target
end

local function GetFaceTargetNearestPlayerFn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	return FindClosestPlayerInRange(x, y, z, START_RUN_DIST + 1, true)
end

local function KeepFaceTargetNearestPlayerFn(inst, target)
	return GetFaceTargetNearestPlayerFn(inst) == target
end

local WarneMinionBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function WarneMinionBrain:OnStart()
	local root = PriorityNode({
		Leash(self.inst, function() return GetTargetPos(self.inst) end, 3, 3),
		DoAction(self.inst, AttackTarget, "AttackTarget"),
		WhileNode(function() return GetLeader(self.inst) and GetLeader(self.inst).components.pinnable and GetLeader(self.inst).components.pinnable:IsStuck() end, "Leader Phlegmed",
			DoAction(self.inst, RescueLeaderAction, "Rescue Leader", true)),
		WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
			RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),			
		
		IfThenDoWhileNode(function() return StartWorkingCondition(self.inst) end, function() return KeepWorkingAction(self.inst) end, "Working",
			LoopNode{
				DoAction(self.inst, FindWorkableAction)}),
		
		WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
			Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
			FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
			RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST, function(target) return ShouldRunAway(self.inst, target) end ),
		IfNode(function() return GetLeader(self.inst) end, "Has Leader",
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
		FaceEntity(self.inst, GetFaceTargetNearestPlayerFn, KeepFaceTargetNearestPlayerFn),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return WarneMinionBrain
