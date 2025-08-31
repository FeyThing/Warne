local assets =
{
	Asset("ANIM", "anim/warne_glow_fx.zip"),
}

local prefabs = {
	"warne_glow_fx",
}


local function CreateFxFollowFrame(i)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	
	inst:AddTag("FX")
	
	inst.AnimState:SetBank("warne_glow_fx")
	inst.AnimState:SetBuild("warne_glow_fx")
	inst.AnimState:PlayAnimation("glow"..i)

	inst.AnimState:SetSymbolBloom("glow")
	inst.AnimState:SetSymbolLightOverride("glow", 1)
	
	inst.persists = false
	
	return inst
end


local function fx_OnRemoveEntity(inst)
	for i, v in ipairs(inst.fx) do
		v:Remove()
	end
end

local function fx_SpawnFxForOwner(inst, owner)
	inst.owner = owner
	inst.fx = {}

	local frame
	for i = 1, 4 do
		local fx = CreateFxFollowFrame(i)
		
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, "face", -5, -10, 0, true, nil, i - 1)
		table.insert(inst.fx, fx)
	end
	for i = 5, 8 do
		local fx = CreateFxFollowFrame(i)
		
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, "face", -10, -13, 0, true, nil, i - 1)
		table.insert(inst.fx, fx)
	end
	for i = 9, 33 do
		local fx = CreateFxFollowFrame(i)
		
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, "face", -5, -10, 0, true, nil, i - 1)
		table.insert(inst.fx, fx)
	end
	
	inst.OnRemoveEntity = fx_OnRemoveEntity
end

local function fx_OnEntityReplicated(inst)
	local owner = inst.entity:GetParent()
	if owner ~= nil then
		fx_SpawnFxForOwner(inst, owner)
	end
end

local function fx_AttachToOwner(inst, owner)
	inst.entity:SetParent(owner.entity)
	if not TheNet:IsDedicated() then
		fx_SpawnFxForOwner(inst, owner)
	end
end

local function fxfn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	
	inst:AddTag("FX")
	
	inst.entity:SetPristine()
	
	inst.activated = net_bool(inst.GUID, "warne_glow_fx.activated", "activateddirty")
	
	if not TheWorld.ismastersim then
		inst.OnEntityReplicated = fx_OnEntityReplicated
		
		return inst
	end
	
	inst.persists = false
	
	inst.AttachToOwner = fx_AttachToOwner
	
	return inst
end

return Prefab("warne_glow_fx", fxfn, assets)