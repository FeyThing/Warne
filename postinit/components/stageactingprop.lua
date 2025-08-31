local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local general_scripts = require("play_generalscripts")
local fn = require("play_commonfn")

---Performance for Warne

general_scripts.WARNE1 = {
	cast = {"warne"},
	lines = {
		{roles = {"warne"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[1]},
		{roles = {"warne"}, 	duration = 3, 	line = STRINGS.STAGEACTOR.WARNE1[2]},
		{actionfn = fn.callbirds, 	duration = 1.5},	
		{roles = {"BIRD2"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[3], 		sgparam = "disappointed"},
		{roles = {"BIRD1"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[4]},
		{roles = {"warne"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[5],		anim = "emote_annoyed_facepalm"},
		{roles = {"warne"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[6]},		
		{roles = {"BIRD1"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[7]},
		{roles = {"BIRD2"}, 	duration = 2.5, 	line = STRINGS.STAGEACTOR.WARNE1[8]},
		{roles = {"warne"}, 	duration = 1.8, line = STRINGS.STAGEACTOR.WARNE1[9]}, 	
		{roles = {"warne"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[10]},
		{roles = {"warne"}, 	duration = 1.8, line = STRINGS.STAGEACTOR.WARNE1[11]},
		{roles = {"warne"}, 	duration = 2.5, 	line = STRINGS.STAGEACTOR.WARNE1[12]},
		{roles = {"warne"}, 	duration = 3.5, 	line = STRINGS.STAGEACTOR.WARNE1[13],     anim= "look"},
		{roles = {"warne"}, 	duration = 2.5, 	line = STRINGS.STAGEACTOR.WARNE1[14]},
		{roles = {"warne"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[15]},
		{roles = {"BIRD1"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[16], 	sgparam = "laugh"},
		{roles = {"warne"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[17]}, 	
		{roles = {"warne"}, 	duration = 3, 	line = STRINGS.STAGEACTOR.WARNE1[18]},
		{roles = {"warne"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[19]},
		{roles = {"warne"}, 	duration = 3.5, 	line = STRINGS.STAGEACTOR.WARNE1[20],		anim= "emote_shrug"},
		{roles = {"BIRD2"}, 	duration = 2, 	line = STRINGS.STAGEACTOR.WARNE1[21], 	sgparam = "disappointed"},
		
		{roles = {"warne"}, 	duration = 3, 	line = STRINGS.STAGEACTOR.WARNE1[22],		anim = "emote_annoyed_palmdown"},
		{roles = {"warne"}, 	duration = 1.5, line = STRINGS.STAGEACTOR.WARNE1[23], 	anim = "emote_laugh"},	
		{actionfn = fn.exitbirds, 	duration = 1},
	}
}