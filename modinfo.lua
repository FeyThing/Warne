name = "Warne"
author = "Feything"

version = "0.1"
local info_version = "󰀔 [ Version "..version.." ]"

description = info_version..[[ 

Ever wish to see what it was like to play as an old questionably evil magical dead guy?

No? Well too bad, Malhz'upher or Warne as he's called in the constant is here to raise the dead,
cast and crash the party as NPC and player alike.]]

forumthread = ""

api_version = 10

all_clients_require_mod = true
dst_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
	"warne", "character", "necromancer", "lich",
}

local function CreateLanguageOption(name, default, label, hover)
    return {
        name = name,
        label = label,
		hover = hover,
		
        options = {
            {description = "English", hover = "By Feything", data = "en"},
        },
        default = default or "en",
    }
end

local configs = {
	
}

local descs = {
	
}

local options = {
	
}

configuration_options = {
	CreateLanguageOption("language", "en", "Language", "Change the mod language."),
}