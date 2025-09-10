local assets = {
	Asset("ANIM", "anim/book_warne.zip"),
}

local prefabs = {
	
}

local function Openspellbook(inst, player)
	player:ShowPopUp(POPUPS.WARNESPELLBOOK, true)
	return true
end

local function SaveSpell(inst, glyph, form, augment, i)
	i = math.clamp(i, 1, TUNING.WARNE_SPEELBOOK_NUM_SPELLS)
	
	inst.saved_spells[i] = {glyph = glyph, form = form, augment = augment}
end

local function OnSaveSpellDirty(inst)
	local glyph, form, augment, i = inst.last_spell.glyph:value(),
		inst.last_spell.form:value(),
		inst.last_spell.augment:value(),
		inst.last_spell.id:value()
	
	SaveSpell(inst, glyph, form, augment, i)
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("book_warne")
	inst.AnimState:SetBuild("book_warne")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	
	inst:AddTag("book")
	inst:AddTag("bookcabinet_item")
	
	inst.saved_spells = {}
	for i = 1, TUNING.WARNE_SPEELBOOK_NUM_SPELLS do
		inst.saved_spells[i] = {}
	end
	inst.SaveSpell = SaveSpell
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		inst.last_spell = {}
		inst.last_spell.glyph = net_string(inst.GUID, "warne_spellbook._glyph")
		inst.last_spell.form = net_string(inst.GUID, "warne_spellbook._form")
		inst.last_spell.augment = net_string(inst.GUID, "warne_spellbook._augment")
		inst.last_spell.id = net_smallbyte(inst.GUID, "warne_spellbook._id", "onsavespelldirty")
		
		inst:ListenForEvent("lightdirty", OnSaveSpellDirty)
		
		return inst
	end

	---note redo anime with wickerbottom book build

	--inst.swap_build = "warne_spellbook"
	
	inst:AddComponent("inspectable")
	inst:AddComponent("book")
	inst.components.book:SetOnRead(Openspellbook)
	--inst.components.book:SetOnPeruse(def.perusefn)
	--inst.components.book:SetFx(def.fx, def.fxmount)
	
	inst:AddComponent("inventoryitem")
	
	MakeHauntableLaunch(inst)
	
	return inst
end

return Prefab("warne_spellbook", fn, assets, prefabs)