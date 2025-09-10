local Warne_Rezminion = Class(function(self, inst)
	self.inst = inst
	self.minion_prefab = "warneminion"
	
	self.inst:AddTag("rezminion")
end)

function Warne_Rezminion:OnRemoveFromEntity()
	self.inst:RemoveTag("rezminion")
end

function Warne_Rezminion:Resurrect(doer)
	if self.canrez and not self.canrez(self.inst, doer) then
		return false
	end
	if self.onrezfn then
		self.onrezfn(self.inst, doer)
	end

	return true
end

function Warne_Rezminion:Spawn(doer)
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local minion = SpawnPrefab(self.minion_prefab)
	
	if minion then
		minion.Transform:SetPosition(x, y, z)
		if minion.sg then
			minion.sg:GoToState(self.rez_state or "warne_resurrected", self.inst)
		end
		if doer and minion.components.follower then
			minion.components.follower:SetLeader(doer)
		end
	end
	
	return true, minion
end

return Warne_Rezminion