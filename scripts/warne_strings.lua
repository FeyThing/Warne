STRINGS.CHARACTER_TITLES.warne = "The Undead Mage"
STRINGS.CHARACTER_NAMES.warne = "Warne"
STRINGS.CHARACTER_DESCRIPTIONS.warne = "*Master of the Arcane\n*Passively levitates\n*Despises physical activity\n*Is undead and benefits from all of its pros and cons"
STRINGS.CHARACTER_QUOTES.warne = "\"You lose some and gain some. Doesn't matter to me, hahahaha!!!\""
STRINGS.CHARACTER_SURVIVABILITY.warne = "Grim"

STRINGS.CHARACTERS.WARNE = require "speech_warne"

STRINGS.NAMES.WARNE = "Malhz'upher"
STRINGS.SKIN_NAMES.warne_none = "Malhz'upher"

STRINGS.NAMES.WARNESTAFF= "Spell Focus"
STRINGS.RECIPE_DESC.WARNESTAFF = "Impossible! How did I even lose it in the first place?"

STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNESTAFF = "I can also stab someone with it!"

STRINGS.NAMES.WARNE_SOULJAR = "Phylactery"
STRINGS.RECIPE_DESC.WARNE_SOULJAR = "My own hubris has caught up to me again. Whoops my bad, time to whip up another one."

STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNE_SOULJAR = "Good job world! As if making my life force less inconspicuous was the icing on top."

STRINGS.NAMES.WARNE_SPELLBOOK = "Ars Nekros"
STRINGS.RECIPE_DESC.WARNE_SPELLBOOK = "Originally a book of necromancy. Now it's repurposed to cast a variety of versatile spells."

STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNE_SPELLBOOK = "If I catch anyone with their grubby paws on it, they're going to be missing more than just fingers."

STRINGS.NAMES.WARNE_SCRIBETABLE = "Arcane Scribe Table"
STRINGS.RECIPE_DESC.WARNE_SCRIBETABLE = "A table used for the creation of spells."

STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNE_SCRIBETABLE = "Utilizing ingredients found, I can convert it into new spells!"

STRINGS.NAMES.WARNE_GLYPH = "Glyph"
STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNE_GLYPH = "The building blocks for progessing arcane experimentation!"

-- Minions
STRINGS.NAMES.WARNEMINION = "Skeleton Minion"
STRINGS.CHARACTERS.WARNE.DESCRIBE.WARNEMINION = "You, obey!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WARNEMINION = "It's pretty spooky."
STRINGS.CHARACTERS.WARNE.ANNOUNCE_SITCOMMAND = "Stay."
STRINGS.CHARACTERS.WARNE.ANNOUNCE_SITCOMMAND_CANCEL = "Follow."

STRINGS.NAMES.WARNEBONE_GENERIC = "Big Bone"
STRINGS.NAMES.WARNEBONE_RIBCAGE = "Ribcage"
STRINGS.NAMES.WARNEBONE_SKULL = "Skull"
STRINGS.NAMES.WARNEBONE_ARM = "Arm Bones"
STRINGS.NAMES.WARNEBONE_LEG = "Leg Bones"

STRINGS.NAMES.WARNEMINION_BUILDER = "Skeleton"
STRINGS.RECIPE_DESC.WARNEMINION_BUILDER = "That should do the trick."

-- Actions
STRINGS.ACTIONS.LICHABSORB = "Absorb"
STRINGS.ACTIONS.LICHRESURRECTMINION = "Resurrect"

STRINGS.ACTIONS.SITCOMMAND = "Order to Stay"
STRINGS.ACTIONS.SITCOMMAND_CANCEL = "Order to Follow"

STRINGS.ACTIONS.WARNE_SCRIBE = "Scribe"

-- Spellbook
STRINGS.UI.WARNE_SPELLS = {
	AUGMENT = "Augment",
	FORM = "Form",
	GLYPHS = "Glyphs",
	COMPLETION = "{num}/{max}",
	CREATE_SPELL = "Create",
	NAMES = {
		augment_amplify = "Amplify",
		augment_bounce = "Bounce",
		augment_duration = "Duration",
		augment_explosion = "Explosion",
		augment_homing = "Homing",
		augment_radius = "Radius",
		augment_speed = "Speed",
		augment_split = "Split",
		augment_sticky = "Sticky",
		augment_harmless = "Harmless",
		augment_trail = "Trail",
		augment_curse = "Curse",
		form_aoe = "AOE",
		form_line = "Line",
		form_projectile = "Projectile",
		form_self = "Self",
		glyph_electric = "Electric",
		glyph_fire = "Fire",
		glyph_ice = "Ice",
		glyph_leech = "Leech",
		glyph_light = "Light",
		glyph_air  = "Air",
		glyph_water = "Water",
		glyph_earth =  "Earth",
		glyph_lunar = "Lunar",
		glyph_shadow =  "Shadow",
		glyph_blink = "Blink",
		glyph_slow =  "Slow",
		glyph_adrenaline =  "Adrenaline",
		glyph_buff =  "Buff",
		glyph_protect =  "Protect",
		glyph_vision =  "Vision",
		glyph_thorns =  "Thorns",
		glyph_fortify =  "Fortify",
		glyph_invisibility = "invisibility",
		glyph_gravity =  "gravity",
	},
}

STRINGS.SKILLTREE.WARNE = {
		--COUNT_LOCK_1_DESC = "Learn 5 skills to unlock.", These are bound to change in favor of more interesting stuff.
		
		--COUNT_LOCK_2_DESC = "Learn 10 skills on the right to unlock.",
		
		BONE_COLLECTOR1_TITLE = "Bone Collector 1",
		BONE_COLLECTOR1_DESC = "Mobs have a 20% higher chance to drop parts when you, your minions or a (player affected by your spells) kills it.",
		
		BONE_COLLECTOR2_TITLE = "Bone Collector 2",
		BONE_COLLECTOR2_DESC = "You have a chance of finding rare bones from fishing, digging graves, and in tumbleweeds.",
		
		COMMAND_TITLE = "Command",
		COMMAND_DESC = "You have access to a command wheel where you can now give proper orders to your minions, instead of them copying what you do.",
		
		ADVANCED_SKELETONS_TITLE = "Advanced Skeletons",
		ADVANCED_SKELETONS_DESC = "Your skeletons begin to develop some form of self preservation, and learn to kite enemies.",
		
		DEATH_GUARD_TITLE = "Death Guard",
		DEATH_GUARD_DESC = "You learn the command Guard. Your Minions can plant themselves in one spot, and become aggressive sentries towards unfriendly mobs that enter their range. \nYou can craft special weapons and armor for them befitting for your guards.",
		
		INFUSED_MINIONS_TITLE = "Infused Minions",
		INFUSED_MINIONS_DESC = "Your skeleton minions appearance changes. They start to become sturdier, bulkier and stronger. \nBones can be used to modify them and boost their effectiveness for specific tasks.",
		
		ARTIFICIAL_SOUL1_TITLE = "Artificial Soul 1",
		ARTIFICIAL_SOUL1_DESC = "The rot you accumulated is now of use. You can use rot, ash, and boneshards to create soul dust. Which you can feed to your phylactery to restore 5 percent of it.",
		
		ARTIFICIAL_SOUL2_TITLE = "Artificial Soul 2",
		ARTIFICIAL_SOUL2_DESC = "You can use soul dust with existing seed to create a soul seed which can be planted to grow an artificial soul as if it is worth 200 hp. \nUnfortunately plants still hate you, and the soul is no different.",
		
		SOUL_ECHO_TITLE = "Soul Echo",
		SOUL_ECHO_DESC = "When you kill mobs, you automatically absorb their soul. ",

		DEATH_DISSONANCE_TITLE = "Death Dissonance",
		DEATH_DISSONANCE_DESC = "When you die, your Wraith form can momentarily take control of any skeletal minions waiting for you to revive. \nThis does not stop the ghost drain of allies and you are still considered dead until you resurrect yourself.",
		
		DEATH_SIPHON_TITLE = "Death Siphon",
		DEATH_SIPHON_DESC = "Your Death touch, chains onto nearby enemies and leeches off them.",
		
		DEATH_BURST_TITLE = "Death Burst",
		DEATH_BURST_DESC = "Your Death touch builds up before bursting, inflicting more damage and dealing splash.",
		
		SOUL_WEAPONRY1_TITLE = "Soul Weaponry 1",
		SOUL_WEAPONRY1_DESC = "You can perform a ritual at resurrection stones at night per 20 days to bind your soul to a weapon instead of a jar. \nThe weapon’s durability is removed, is transformed, retains its previous stats/effects and it becomes your phylactery you can attune to.",
		
		SOUL_WEAPONRY2_TITLE = "Soul Weaponry 2",
		SOUL_WEAPONRY2_DESC = "Your soulbound weapon gains a small lifesteal effect similar to your death touch.",
		
		SPELL_EFFICIENCY1_TITLE = "Spell Efficiency 1",
		SPELL_EFFICIENCY1_DESC = "You use 20% less mana to cast spells with your staff.",
		
		SPELL_EFFICIENCY2_TITLE = "Spell Efficiency 2",
		SPELL_EFFICIENCY2_DESC = "You can now combine 2 glyphs together.",
		
		ARTIFICER1_TITLE = "Artificer 1",
		ARTIFICER1_DESC = "You are intrigued by the workings of machinery. You gain understanding of the inner most working of technology and can build clockworks as if they were skeleton minions. \nClockworks can be used with command if the skill has been chosen, and are repairable with gears unlike your skeletons.",
		
		ARTIFICER2_TITLE = "Artificer 2",
		ARTIFICER2_DESC = "You learn how to make the Artificers workbench. A workstation that lets you use your mana and materials to create greater clockwork parts, advanced spellstaffs with mana cell storage and mana cells to store extra mana in advance.",
		
		ARTIFICER3_TITLE = "Artificer 3",
		ARTIFICER3_DESC = "You learn how to Infuse spells into gear and weapons for a short period of time using the artificer’s workbench in exchange for charge. \nThe catch is that the spell is random.",
		
		CURSE_BEARER1_TITLE = "Curse Bearer 1",
		CURSE_BEARER1_DESC = "You’re used to suffering for power. You learn a new spell augment called curse which debuffs in exchange for a buff. \nYou are inflicted with the damaging/negative effects of the selected glyph, but all other augments assigned to the spell are doubled in their effectiveness.",
		
		CURSE_BEARER2_TITLE = "Curse Bearer 2",
		CURSE_BEARER2_DESC = "You have built up tolerance to cursing yourself to the point its negative effects are half as effective on you.",
		
		ADVANCED_SPELLCASTER_TITLE = "Advanced Spellcaster",
		ADVANCED_SPELLCASTER_DESC = "You can now combine 3 glyphs together",
		
		LUNAR_CONQUEROR_TITLE = "Lunar Conqueror",
		LUNAR_CONQUEROR_DESC = "You learn lunar magic, and your minions(including clockworks if you took Artificer 2) become lunar aligned (they visually mutate and they deal extra lunar damage.)",
		
		SHADOW_DOMINATION_TITLE = "Shadow Domination", 
		SHADOW_DOMINATION_DESC = "You learn shadow magic, and your minions(including clockworks if you took Artificer 2) become shadow aligned (they visually corrupt and they deal extra shadow damage.)", 
	}

--- Stage

STRINGS.STAGEACTOR.WARNE1 = {
		-- WARNE
        "Alright, listen up!",
        "Oh do I have a story to share with yooooooou.",
        
        -- BIRDS
        "So the lich wishes to \"prattle.\"",
        "Fine skeleton, we'll listen.",
        
        -- WARNE
        "Bah, you morons speak like you don't trust me!",
        "I promise to not disentegrate you.",
        
        -- BIRDS
        "\"Surely.\"",
        "But out of curiosity we wouldn't miss any good entertainment, even from you.",
        
        -- WARNE
        "Fantastic!",
        "Once upon a time there lived an idiot.",
		"He had a meaningless life,",
        "But he craved fortune and power.",
        "So much so that he sold out even his loved ones for money,",
		"You know one of those guys who fancy tacky decor and probably wears cheap perfume.",
        "Soooo do you know what happened next?",
		
		-- BIRDS
        "What exactly?",
		
		-- WARNE
        "I killed him!",
        "He thought he could swindle me, Malhz'upher!",
		"Word of advice,",
        "Never answer your door half-dressed in the morning to someone wishing to sell you something.",
				
	    -- BIRDS
        "...",

		-- WARNE
        "Oh so you were expecting a tale of heroes vs villians?",
        "Too bad! Maybe next time!",		
	}

