require("warne_strings")
require("warne_tuning")
require("warne_util")

local inits = {
	"init_actions",
	"init_assets",
	"init_prefabs",
	"init_character",
	"init_containers",
	"init_widgets",
	"init_recipes",
	"badges",
}

for _, v in pairs(inits) do
	modimport("init/"..v)
end

local prefabs = {
	"flower_evil",
	"mound",
	"player_common_extensions",
	"skeletons",
}

local components = {
	"book",
	"healer",
	"health",
	"sanity",
	"carefulwalker",
	"farmplantstress",
	"stageactingprop",
}

local stategraphs = {
	"wilson",
}

for _, v in pairs(prefabs) do
	modimport("postinit/prefabs/"..v)
end

for _, v in pairs(components) do
	modimport("postinit/components/"..v)
end

for _, v in pairs(stategraphs) do
	modimport("postinit/stategraphs/"..v)
end

modimport("postinit/modcompat")