local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local function WarneRecipe(name, ingredients, tech, config, filters)
	if config == nil then
		config = {}
	end	

	config.nounlock = config.nounlock == nil and true or config.nounlock

	ENV.AddRecipe2(name, ingredients, tech, config, filters)
end

--	[ 		Recipes			]	--

--	[ 		Warne Equipment	]	--

--- In the souljar recipe. The nightmarefuel  will be replaced with a nightmaregem.
WarneRecipe("warne_souljar", 			{Ingredient("marble", 2), Ingredient("nightmarefuel", 1), Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)}, 									TECH.NONE,		{builder_tag = "lich", nounlock = false}, {"CHARACTER", "MAGIC"})
WarneRecipe("warne_spellbook", 			{Ingredient("papyrus", 2), Ingredient("pigskin", 1), Ingredient("nightmarefuel", 2)}, 														TECH.NONE,		{builder_tag = "lich", nounlock = false}, {"CHARACTER", "MAGIC"})
WarneRecipe("warnestaff", 				{Ingredient("spear", 1), Ingredient("bluegem", 1), Ingredient("redgem", 1)}, 																TECH.NONE,		{builder_tag = "lich", nounlock = false}, {"CHARACTER", "MAGIC"})
WarneRecipe("warneminion_builder", 		{Ingredient("warnebone_skull", 1), Ingredient("warnebone_ribcage", 1), Ingredient("warnebone_arm", 2), Ingredient("warnebone_leg", 2)}, 	TECH.NONE, 		{builder_tag = "lich", nounlock = false, placer = "warneminion_builder_placer"}, {"CHARACTER"}, {"MAGIC"})

--	[ 		Crafting Stations			]	--
WarneRecipe("warne_scribetable", 		{Ingredient("cutstone", 4), Ingredient("nightmarefuel", 2), Ingredient("purplegem", 1)}, 													TECH.NONE, 		{builder_tag = "lich", nounlock = false, placer = "warne_scribetable_placer"}, {"CHARACTER"}, {"MAGIC"})
--	[ 		Glyphs			]	--