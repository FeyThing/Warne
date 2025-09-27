
Assets = {
	Asset("ANIM", "anim/player_float.zip"),
	Asset("ANIM", "anim/player_lichpowers.zip"),
	Asset("ANIM", "anim/health_warne.zip"),
	Asset("ANIM", "anim/hunger_warne.zip"),

	Asset("IMAGE", "images/saveslot_portraits/warne.tex"),
	Asset("ATLAS", "images/saveslot_portraits/warne.xml"),

	Asset("IMAGE", "images/selectscreen_portraits/warne.tex"),
	Asset("ATLAS", "images/selectscreen_portraits/warne.xml"),
	
	Asset("IMAGE", "images/selectscreen_portraits/warne_silho.tex"),
	Asset("ATLAS", "images/selectscreen_portraits/warne_silho.xml"),

	Asset("IMAGE", "bigportraits/warne.tex"),
	Asset("ATLAS", "bigportraits/warne.xml"),
	Asset("IMAGE", "bigportraits/warne_none.tex"),
	Asset("ATLAS", "bigportraits/warne_none.xml"),
	
	Asset("IMAGE", "images/avatars/avatar_warne.tex"),
	Asset("ATLAS", "images/avatars/avatar_warne.xml"),
	
	Asset("IMAGE", "images/avatars/avatar_ghost_warne.tex"),
	Asset("ATLAS", "images/avatars/avatar_ghost_warne.xml"),
	
	Asset("IMAGE", "images/avatars/self_inspect_warne.tex"),
	Asset("ATLAS", "images/avatars/self_inspect_warne.xml"),
	
	Asset("IMAGE", "images/names_warne.tex"),
	Asset("ATLAS", "images/names_warne.xml"),
	
	Asset("IMAGE", "images/names_gold_warne.tex"),
	Asset("ATLAS", "images/names_gold_warne.xml"),
	
	Asset("IMAGE", "images/warne_redux.tex"),
	Asset("ATLAS", "images/warne_redux.xml"),

	Asset("IMAGE", "images/warne_spellbook_ui.tex"),
	Asset("ATLAS", "images/warne_spellbook_ui.xml"),

	Asset("IMAGE", "images/warne_spellbook_glyphs.tex"),
	Asset("ATLAS", "images/warne_spellbook_glyphs.xml"),

	Asset("IMAGE", "images/warne_skilltree.tex"),
	Asset("ATLAS", "images/warne_skilltree.xml"),

	--sound
	Asset("SOUNDPACKAGE", "sound/warne.fev"),
	Asset("SOUND", "sound/warne.fsb"),

	--items
	Asset("IMAGE", "images/warne_inventory.tex"),
	Asset("ATLAS", "images/warne_inventory.xml"),
	Asset("ATLAS_BUILD", "images/warne_inventory.xml", 256),
	
	Asset("IMAGE", "images/warne_minimap.tex"),
	Asset("ATLAS", "images/warne_minimap.xml"),

	Asset("ATLAS", "images/warne_ui_images.xml"),
	Asset("IMAGE", "images/warne_ui_images.tex"),
}

AddMinimapAtlas("images/warne_minimap.xml")

local WARNE_ICONS = GLOBAL.resolvefilepath("images/warne_inventory.xml")
local _GetInventoryItemAtlas_Internal = GLOBAL.GetInventoryItemAtlas_Internal
function GLOBAL.GetInventoryItemAtlas_Internal(imagename, ...)
    return GLOBAL.TheSim:AtlasContains(WARNE_ICONS, imagename) and WARNE_ICONS
            or _GetInventoryItemAtlas_Internal(imagename, ...)
end
