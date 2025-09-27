local ORDERS = {
    {"spellcasting", {-214+18   , 76 + 30 }},
    {"necromancy", {-62       , 76 + 30}},
    {"soulreaver", {62       , 76 + 30}},
    {"allegiance", {0      , 176 + 30}},
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {
		---Necromancy
        warne_bone_collector1 = {
            title = "Bone Collector 1",
            desc = "Mobs have a 20% higher chance to drop parts when you, your minions or a (player affected by your spells) kills it.",
            icon = "warne_bone_collector1",
            pos = {62,0},
            group = "necromancy",
            tags = {"necromancy"},
            root = true,
            connects = {
                "warne_bone_collector2"
            },
        },

        warne_bone_collector2 = {
            title = "Bone Collector 2",
            desc = "There is a chance of finding bones from fishing, digging graves, and in tumbleweeds.",
            icon = "warne_bone_collector2",
            pos = {62,40},
            group = "necromancy",
            tags = {"necromancy"},
            connects = {
                "warne_command"
            },
        },


        warne_command = {
            title = "Command",
            desc = "You have access to a command wheel where you can now give proper orders to your minions, instead of them copying what you do.",
            icon = "warne_command",
            pos = {100,50},
            group = "necromancy",
            tags = {"necromancy"},
            connects = {
                "warne_advanced_skeletons"
            },
        },

        warne_advanced_skeletons = {
            title = "Advanced Skeletons",
            desc = "Skeleton minions begin to develop some form of self preservation. Their max health increases and they learn to kite enemies better.",
            icon = "warne_advanced_skeletons",
            pos = {160,50},
            group = "necromancy",
            tags = {"necromancy"},
            connects = {
                "warne_death_guard"
            },
        },

        warne_death_guard = {
            title = "Death Guard",
            desc = "You learn the command Guard. Your Minions can plant themselves in one spot, and become aggressive sentries towards unfriendly mobs that enter their range. \nYou can craft special weapons and armor for them befitting for your guards.",
            icon = "warne_death_guard",
            pos = {160,120},
            group = "necromancy",
            tags = {"necromancy"},
            connects = {
                "warne_infused_minions"
            },
        },

        warne_infused_minions = {
            title = "Infused Minions",
            desc = "Skeleton minions appearance changes. They start to become sturdier, bulkier and stronger. \nBones can be used to modify them and boost their effectiveness for specific tasks.",
            icon = "warne_infused_minions",
            pos = {160,180},
            group = "necromancy",
            tags = {"necromancy"},
        },
		
		---Soulreaver
		warne_artificial_soul1 = {
            title = "Artificial Soul 1",
            desc = "The rot you accumulated is now of use. You can use rot, ash, and boneshards to create soul dust. Which you can feed to your phylactery to restore 5 percent of it.",
            icon = "warne_artificial_soul1",
            pos = {0,0},
            group = "soulreaver",
            tags = {"soulreaver"},
            root = true,
            connects = {
                "warne_artificial_soul2"
            },
        },

        warne_artificial_soul2 = {
            title = "Artificial Soul 2",
            desc = "You can use soul dust with existing seed to create a soul seed which can be planted to grow an artificial soul as if it is worth 200 hp. \nUnfortunately plants still hate you, and the soul is no different.",
            icon = "warne_artificial_soul2",
            pos = {0,40},
            group = "soulreaver",
            tags = {"soulreaver"},
            connects = {
                "warne_soul_echo"
            },
        },

        warne_soul_echo = {
            title = "Soul Echo",
            desc = "When you kill mobs, you automatically absorb their soul.",
            icon = "warne_soul_echo",
            pos = {0,80},
            group = "soulreaver",
            tags = {"soulreaver"},
            connects = {
				"warne_death_dissonance",
				"warne_soulbound_weaponry1",
                "warne_death_siphon"
            },
        },

        warne_death_dissonance = {
            title = "Death Dissonance",
            desc = "When you die, your Wraith form can momentarily take control of any skeletal minions waiting for you to revive. \nThis does not stop the ghost drain of allies and you are still considered dead until you resurrect yourself from kills.",
            icon = "warne_death_dissonance",
            pos = {-62,110},
            group = "soulreaver",
            tags = {"soulreaver"},
        },

		warne_death_siphon = {
            title = "Death Siphon",
            desc = "Your Death touch, chains onto nearby enemies and leeches off them.",
            icon = "warne_death_siphon",
            pos = {56,110},
            group = "soulreaver",
            tags = {"soulreaver"},
            connects = {
                "warne_death_burst"
            },
        },

        warne_death_burst = {
            title = "Death Burst",
            desc = "Death touch builds up before bursting, inflicting more damage and dealing splash.",
            icon = "warne_death_burst",
            pos = {56,160},
            group = "soulreaver",
            tags = {"soulreaver"},
        },

        warne_soulbound_weaponry1 = {
            title = "Soulbound Weaponry 1",
            desc = "You can perform a ritual at resurrection stones at night per 20 days to bind your soul to a weapon instead of a jar. \nThe weapon’s durability is removed, is transformed, retains its previous stats/effects and it becomes your phylactery you can attune to.",
            icon = "warne_soulbound_weaponry1",
            pos = {0,140},
            group = "soulreaver",
            tags = {"soulreaver"},
            connects = {
                "warne_soulbound_weaponry2"
            },
        },

        warne_soulbound_weaponry2 = {
            title = "Soulbound Weaponry 2",
            desc = "Your soulbound weapon gains a small lifesteal effect similar to your death touch.",
            icon = "warne_soulbound_weaponry2",
            pos = {0,180},
            group = "soulreaver",
            tags = {"soulreaver"},
        },		
		---Spellcasting
		warne_spell_efficiency1 = {
            title = "Spell Efficiency 1",
            desc = "You use 20% less mana to cast spells with your staff.",
            icon = "warne_spell_efficiency1",
            pos = {-62,0},
            group = "spellcasting",
            tags = {"spellcasting"},
            root = true,
            connects = {
                "warne_spell_efficiency2"
            },
        },

        warne_spell_efficiency2 = {
            title = "Spell Efficiency 2",
            desc = "You can now combine 2 glyphs together.",
            icon = "warne_spell_efficiency2",
            pos = {-62,40},
            group = "spellcasting",
            tags = {"spellcasting"},
            connects = {
                "warne_artificer1",
				"warne_curse_bearer1",
            },
        },

        warne_artificer1 = {
            title = "Artificer 1",
            desc = "You are intrigued by the workings of machinery. You gain understanding of the inner most working of technology and can build clockworks as if they were skeleton minions. \nClockworks can be used with command if the skill has been chosen, and are repairable with gears unlike your skeletons.",
            icon = "warne_artificer1",
            pos = {-180,80},
            group = "spellcasting",
            tags = {"spellcasting"},
            connects = {
				"warne_artificer2",
            },
        },

        warne_artificer2 = {
            title = "Artificer 2",
            desc = "You learn how to make the Artificers workbench. A workstation that lets you use your mana and materials to create greater clockwork parts, advanced spellstaffs with mana cell storage and mana cells to store extra mana in advance.",
            icon = "warne_artificer2",
            pos = {-180,130},
            group = "spellcasting",
            tags = {"spellcasting"},
			connects = {
				"warne_artificer3",
            },
        },

		warne_artificer3 = {
            title = "Artificer 3",
            desc = "You learn how to Infuse spells into gear and weapons for a short period of time using the artificer’s workbench in exchange for charge. \nThe catch is that the spell is random.",
            icon = "warne_artificer3",
            pos = {-180,180},
            group = "spellcasting",
            tags = {"spellcasting"},
        },

        warne_curse_bearer1 = {
            title = "Curse Bearer 1",
            desc = "You’re used to suffering for power. You learn a new spell augment called curse which debuffs in exchange for a buff. \nYou are inflicted with the damaging/negative effects of the selected glyph, but all other augments assigned to the spell are doubled in their effectiveness.",
            icon = "warne_curse_bearer1",
            pos = {-120,80},
            group = "spellcasting",
            tags = {"spellcasting"},
			connects = {
				"warne_curse_bearer2",
            },
        },

        warne_curse_bearer2 = {
            title = "Curse Bearer 2",
            desc = "You have built up tolerance to cursing yourself to the point its negative effects are half as effective on you.",
            icon = "warne_curse_bearer2",
            pos = {-120,130},
            group = "spellcasting",
            tags = {"spellcasting"},
        },

        warne_advanced_spellcasting = {
            title = "Advanced Spellcaster",
            desc = "3 glyphs can now be combined together",
            icon = "warne_advanced_spellcasting",
            pos = {-120,180},
            group = "spellcasting",
            tags = {"spellcasting"},
            root = true,
        },	
		---allegiance
		warne_lunar_conqueror = {
            title = "Lunar Conqueror",
            desc = "You learn lunar magic, and your minions(including clockworks if you took Artificer 2) become lunar aligned (they visually mutate and they deal extra lunar damage.)",
            icon = "warne_lunar_conqueror",
            pos = {-100,220},
            group = "allegiance",
            tags = {"allegiance"},
            root = true,
        },

		warne_shadow_domination = {
            title = "Shadow Domination",
            desc = "You learn shadow magic, and your minions(including clockworks if you took Artificer 2) become shadow aligned (they visually corrupt and they deal extra shadow damage.)",
            icon = "warne_shadow_domination",
            pos = {100,220},
            group = "allegiance",
            tags = {"allegiance"},
            root = true,
        },		


	}	

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData