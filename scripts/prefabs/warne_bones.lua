local assets = {
	Asset("ANIM", "anim/warne_bones.zip"),
}

local function MakeBone(name, i)
	local function fn()
		local inst = CreateEntity()
		
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
		
		MakeInventoryPhysics(inst)
		
		inst:AddTag("warne_bone")
		
		inst.AnimState:SetBank("warne_bones")
		inst.AnimState:SetBuild("warne_bones")
		inst.AnimState:PlayAnimation("warnebone"..tostring(i - 1))
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst:AddComponent("inspectable")
		
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("stackable")
		
		return inst
	end
	
	return Prefab("warnebone_"..name, fn, assets)
end

local WARNE_BONES = {"generic", "ribcage", "skull", "arm", "leg"}
local prefs = {}

for i, v in ipairs(WARNE_BONES) do
	table.insert(prefs, MakeBone(v, i))
end

return unpack(prefs)