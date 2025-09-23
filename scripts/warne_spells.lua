local WARNE_SPELLS = {
	amplify = {type = "augment"},
	bounce = {type = "augment"},
	duration = {type = "augment"},
	explosion = {type = "augment"},
	homing = {type = "augment"},
	radius = {type = "augment"},
	speed = {type = "augment"},
	split = {type = "augment"},
	sticky = {type = "augment"},
	pierce = {type = "augment"},
	trail = {type = "augment"},
	curse = {type = "augment"},
	
	aoe = {type = "form"},
	line = {type = "form"},
	projectile = {type = "form"},
	empower = {type = "form"},
	
	electric = {type = "glyph"},
	fire = {type = "glyph"},
	ice = {type = "glyph"},
	leech = {type = "glyph"},
	light = {type = "glyph"},
	air = {type = "glyph"},
	water = {type = "glyph"},
	earth = {type = "glyph"},
	lunar = {type = "glyph"},
	shadow = {type = "glyph"},
	blink = {type = "glyph"},
	slow = {type = "glyph"},
	adrenaline = {type = "glyph"},
	buff = {type = "glyph"},
	protect = {type = "glyph"},
	vision = {type = "glyph"},
	thorns = {type = "glyph"},
	fortify = {type = "glyph"},
	invisibility = {type = "glyph"},
	gravity = {type = "glyph"},
}

for k, v in pairs(WARNE_SPELLS) do
	v.name = k
end

function AddWarneSpell(name, def)
	WARNE_SPELLS[name] = def
end

return WARNE_SPELLS