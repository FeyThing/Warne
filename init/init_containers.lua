local Containers = require "containers"

local params = {
    warne_scribetable = 
	{
		widget = 
		{
			slotpos =
			{
				GLOBAL.Vector3(-84, 38, 0),
				GLOBAL.Vector3(0, 38, 0),
				GLOBAL.Vector3(84, 38, 0),
				GLOBAL.Vector3(-74, -55, 0),
                GLOBAL.Vector3(74, -55, 0), 
			},
			slotbg =
			{
            {image = "warne_ui_slot.tex", atlas = "images/warne_ui_images.xml" },
			{image = "warne_ui_slot.tex", atlas = "images/warne_ui_images.xml" },
			{image = "warne_ui_slot.tex", atlas = "images/warne_ui_images.xml" },
			{image = "warne_ui_pen.tex", atlas = "images/warne_ui_images.xml" },
            {image = "warne_ui_papyrus.tex", atlas = "images/warne_ui_images.xml" },		
			},
			animbank = "ui_warne_scribetable",
			animbuild = "ui_warne_scribetable",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160,
			buttoninfo =
			{
				text = GLOBAL.STRINGS.ACTIONS.WARNE_SCRIBE,
				position = GLOBAL.Vector3(0, -150, 0),
			},
		},
		usespecificslotsforitems = true,
		type = "chest",
        itemtestfn = function(container, item, slot)
		
			return false
        end,
    },
}

for k, v in pairs(params) do
    Containers.params[k] = v
    Containers.MAXITEMSLOTS = math.max(Containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
