local prefs = {}

table.insert(prefs, CreatePrefabSkin("warne_none", {
	base_prefab = "warne",
	type = "base",
	build_name_override = "warne",
	rarity = "Character",
	skin_tags = {"BASE", "WARNE"},
	bigportrait_anim = {build = "bigportraits/warne_none.xml", symbol = "warne_none_oval.tex"},
	skins = {normal_skin = "warne"},
}))

return unpack(prefs)