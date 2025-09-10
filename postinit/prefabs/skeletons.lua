local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local minions = {
	"skeleton",
	"skeleton_player",
	"scorched_skeleton",
}

local function OnRezFn(inst, doer)
	inst:Remove()
	inst.components.warne_rezminion:Spawn(doer)
	doer.components.talker:Say(GetString(doer, "ANNOUNCE_REZ_SKELETON"))
end

for i, prefab in ipairs(minions) do
	ENV.AddPrefabPostInit(prefab, function(inst)
		if not TheWorld.ismastersim then
			return
		end
		
		inst:AddComponent("warne_rezminion")
		inst.components.warne_rezminion.onrezfn = OnRezFn
	end)
end