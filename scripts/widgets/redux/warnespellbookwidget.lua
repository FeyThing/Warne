local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local WARNE_SPELLS = require("warne_spells")

local BOOK_ATLAS = "images/warne_spellbook_ui.xml"
local BOOK_ICON_ATLAS = "images/warne_spellbook_glyphs.xml"

local NUM_TABS = TUNING.WARNE_SPEELBOOK_NUM_SPELLS
local TAB_SPACING = 70

local font_size = 30

global("Warne_Spellbook") -- TEMP for testing, remove later
Warne_Spellbook = nil

local WarneSpellBookWidget = Class(Widget, function(self, owner, book_spells)
	Widget._ctor(self, "WarneSpellBookWidget")
	
	self.root = self:AddChild(Widget("root"))
	self.owner = owner
	
	self.backdrop = self.root:AddChild(Image(BOOK_ATLAS, "page_ui-1.tex"))
	self.backdrop:SetScale(0.7, 0.7)
	self.backdrop:SetPosition(0, 10)
	
	self:BuildTabs()
	
	self.page = self.root:AddChild(Image(BOOK_ATLAS, "page_ui-0.tex"))
	self.page:SetScale(0.7, 0.7)
	self.page:SetPosition(0, 10)
	
	self:BuildSpellz()
	self:Decorate()
	self:NameSpell()
	
	Warne_Spellbook = self
end)

function WarneSpellBookWidget:BuildSpellz()
	self.num_spellz_discovered = 0
	
	self.form_list = self.root:AddChild(self:ListSpells("form"))
	self.form_list:SetPosition(195, 142)
	self.form_list:SetScale(0.7, 0.7)
	
	self.augment_list = self.root:AddChild(self:ListSpells("augment"))
	self.augment_list:SetPosition(195, 35)
	self.augment_list:SetScale(0.7, 0.7)
	
	self.glyphs_list = self.root:AddChild(self:ListSpells("glyphs"))
	self.glyphs_list:SetPosition(-195, 0)
	self.glyphs_list:SetScale(0.7, 0.7)
	
	self.all_form = {}
	self.all_augment = {}
	self.all_glyphs = {}
	for k, v in pairs(WARNE_SPELLS) do
		if v.type == "form" then
			table.insert(self.all_form, {def = v})
		elseif v.type == "augment" then
			table.insert(self.all_augment, {def = v})
		else
			table.insert(self.all_glyphs, {def = v})
		end
		
		if self:HasSpell(k) then
			self.num_spellz_discovered = self.num_spellz_discovered + 1
		end
	end
	
	self.form_list:SetItemsData(self.all_form)
	self.augment_list:SetItemsData(self.all_augment)
	self.glyphs_list:SetItemsData(self.all_glyphs)
end

function WarneSpellBookWidget:BuildTabs()
	self.tabs = {}
	
	for i = 1, NUM_TABS do
		local tab = self.root:AddChild(ImageButton(BOOK_ATLAS, "tab_ui_closed.tex", nil, nil, nil, "tab_ui_open.tex"))
		tab:SetScale(0.7, 0.7)
		tab:SetPosition(400 + GetRandomMinMax(-16, 2), 200 - (i == 1 and 0 or TAB_SPACING * (i - 1)))
		
		table.insert(self.tabs, tab)
	end
end

function WarneSpellBookWidget:Decorate()
	self.decor = {}
	
	self.decor.bg = self.page:AddChild(Image(BOOK_ATLAS, "page_bg.tex"))
	self.decor.bg:SetPosition(300, 35)
	self.decor.bg:SetScale(0.89, 0.88)

	self.decor.bg1 = self.page:AddChild(Image(BOOK_ATLAS, "page_bg.tex"))
	self.decor.bg1:SetPosition(-263, -17)
	self.decor.bg1:SetScale(0.83, 1.72)
	
	self.result_button = self.page:AddChild(ImageButton(BOOK_ATLAS, "createspell_button.tex"))
	self.result_button:SetPosition(150, -300)
	self.result_button:SetText(STRINGS.UI.WARNE_SPELLS.CREATE_SPELL)
	self.result_button:SetOnClick(function()
		-- Add spell on book, rpc event as book needs to memorize it
	end)
	
	--
	
	self.decor.left_line = self.page:AddChild(Image(BOOK_ATLAS, "divider_side.tex"))
	self.decor.left_line:SetPosition(30, 0)
	
	self.decor.devider1 = self.page:AddChild(Image(BOOK_ATLAS, "divider_1.tex"))
	self.decor.devider1:SetPosition(280, 295)
	
	self.decor.devider2 = self.page:AddChild(Image(BOOK_ATLAS, "divider_2.tex"))
	self.decor.devider2:SetPosition(-250 - 20, 200)
	self.decor.devider2:SetScale(.92, 1)

	
	self.decor.devider3 = self.page:AddChild(Image(BOOK_ATLAS, "divider_3.tex"))
	self.decor.devider3:SetPosition(-250 - 20, 295)
	self.decor.devider3:SetScale(.88, 1)
	
	self.decor.devider4 = self.page:AddChild(Image(BOOK_ATLAS, "divider_1.tex"))
	self.decor.devider4:SetPosition(280, 140)
	self.decor.devider4:SetScale(1, -1)
	
	self.decor.devider5 = self.page:AddChild(Image(BOOK_ATLAS, "divider_2.tex"))
	self.decor.devider5:SetPosition(-250 - 20, -230)
	self.decor.devider5:SetScale(.92, -1)

	self.decor.devider6 = self.page:AddChild(Image(BOOK_ATLAS, "divider_1.tex"))
	self.decor.devider6:SetPosition(280, -70)

	self.decor.devider7 = self.page:AddChild(Image(BOOK_ATLAS, "divider_1.tex"))
	self.decor.devider7:SetPosition(-250 - 20, -315)
	self.decor.devider7:SetScale(.83, 1)
	
	--
	
	self.decor.hands_decal1 = self.page:AddChild(Image(BOOK_ATLAS, "hands_decal.tex"))
	self.decor.hands_decal1:SetPosition(-270 + 180, -280)
	
	self.decor.hands_decal2 = self.page:AddChild(Image(BOOK_ATLAS, "hands_decal.tex"))
	self.decor.hands_decal2:SetPosition(-270 - 180, -280)
	self.decor.hands_decal2:SetScale(-1, 1)
	
	--self.decor.skull_decal = self.page:AddChild(Image(BOOK_ATLAS, "skull_decal.tex"))
	--self.decor.skull_decal:SetPosition(-260, -318)
	
	self.decor.result_decal = self.page:AddChild(Image(BOOK_ATLAS, "spellresults_decal.tex"))
	self.decor.result_decal:SetPosition(380, -215)
	
	--
	
	local num_spells = #self.all_form + #self.all_augment + #self.all_glyphs
	self.decor.completion = self.page:AddChild(Text(HEADERFONT, font_size * 1.4, subfmt(STRINGS.UI.WARNE_SPELLS.COMPLETION, {num = self.num_spellz_discovered, max = num_spells}), UICOLOURS.GOLD))
	self.decor.completion:SetPosition(-250 - 20, 325)
	
	self.decor.text_form = self.page:AddChild(Text(HEADERFONT, font_size * 1.4, STRINGS.UI.WARNE_SPELLS.FORM, UICOLOURS.BLACK))
	self.decor.text_form:SetPosition(280, 325)
	
	self.decor.text_augment = self.page:AddChild(Text(HEADERFONT, font_size * 1.3, STRINGS.UI.WARNE_SPELLS.AUGMENT, UICOLOURS.BLACK))
	self.decor.text_augment:SetPosition(280, 170)
	
	self.decor.text_glyphs = self.page:AddChild(Text(HEADERFONT, font_size * 1.5, STRINGS.UI.WARNE_SPELLS.GLYPHS, UICOLOURS.BLACK))
	self.decor.text_glyphs:SetPosition(-250 - 20, 255)
end

local STRING_MAX_LENGTH = 25

function WarneSpellBookWidget:NameSpell()
	self.namespell_bg = self.page:AddChild( Image("images/textboxes.xml", "textbox2_small_grey.tex") )
    self.namespell_bg:SetPosition( -250 - 20, -285 )
    self.namespell_bg:ScaleToSize( 160, 40 )

	self.namespell = self.page:AddChild( TextEdit( BUTTONFONT, 30, "" ) )
	self.namespell:SetPosition( -218 - 20, -288)
	self.namespell:SetRegionSize( 230, 40 )
	self.namespell:SetHAlign(ANCHOR_LEFT)
	self.namespell:SetFocusedImage( self.namespell_bg, "images/textboxes.xml", "textbox2_grey.tex", "textbox2_gold.tex", "textbox2_gold_greyfill.tex" )
	self.namespell:SetTextLengthLimit( STRING_MAX_LENGTH )
    self.namespell:SetForceEdit(true)
end
--

function WarneSpellBookWidget:HasSpell(name)
	return true -- Whenever I know the unlock logic, that'll be lockable / unlockable
end

function WarneSpellBookWidget:ListSpells(spell_type)
	local function ScrollWidgetsCtor(context, index)
		local widget = Widget("spell-cell-"..index)
		
		widget.cell_root = widget:AddChild(ImageButton(BOOK_ATLAS, "spell_icon_inactive.tex", "spell_icon_active.tex"))
		widget.cell_root:SetScale(0.92, 0.92)
		widget.focus_forward = widget.cell_root
		
		return widget
	end
	
	local function ScrollWidgetSetData(context, widget, data, index)
		if data == nil then
			widget.cell_root:Hide()
			return
		else
			widget.cell_root:Show()
		end
		
		if widget.data ~= data then
			widget.data = data
			if widget.icon ~= nil then
				widget.icon:Kill()
			end
			
			local knows = self:HasSpell(data.def.name)
			
			local spell_atlas = knows and (data.def.atlas or BOOK_ICON_ATLAS) or BOOK_ATLAS
			local spell_image = knows and (data.def.type.."_"..data.def.name) or "spell_icon_unknown"
			widget.icon = widget.cell_root:AddChild(Image(spell_atlas, spell_image..".tex"))
			widget.icon:SetClickable(false)
			
			if knows then
				widget.cell_root:SetHoverText(STRINGS.UI.WARNE_SPELLS.NAMES[data.def.name], {offset_y = 90})
			else
				widget.cell_root:ClearHoverText()
			end
			
			if knows then
				widget.cell_root:SetClickable(true)
				widget.cell_root:SetOnClick(function()
					-- Add to builder here
				end)
			else
				widget.cell_root:SetClickable(false)
			end
		end
	end
	
	local grid = TEMPLATES.ScrollingGrid({}, {
		context = {},
		widget_width = 100,
		widget_height = 100,
		force_peek = true,
		num_visible_rows = spell_type == "form" and 2 or spell_type == "augment" and 2 or 4,
		num_columns = spell_type == "form" and 5 or 4,
		item_ctor_fn = ScrollWidgetsCtor,
		apply_fn = ScrollWidgetSetData,
		scrollbar_offset = spell_type == "glyphs" and 8 or 28,
		scrollbar_height_offset = 0,
		peek_percent = spell_type == "glyphs" and 0.4 or 0,
		end_offset = 1,
	})
	
	grid.up_button:SetTextures(BOOK_ATLAS, "scroll_arrow.tex")
	grid.up_button:SetScale(1, 1)
	
	grid.down_button:SetTextures(BOOK_ATLAS, "scroll_arrow.tex")
	grid.down_button:SetScale(1, -1)
	
	grid.scroll_bar_line:SetTexture(BOOK_ATLAS, spell_type == "glyphs" and "scroll_line_long.tex" or "scroll_line_short.tex")
	grid.scroll_bar_line:SetScale(1, 1)
	
	grid.position_marker:SetTextures(BOOK_ATLAS, "scroll_slider.tex")
	grid.position_marker.image:SetTexture(BOOK_ATLAS, "scroll_slider.tex")
	grid.position_marker:SetScale(1, 1)
	
	return grid
end

--

function WarneSpellBookWidget:Kill()
	WarneSpellBookWidget._base.Kill(self)
end

function WarneSpellBookWidget:OnControl(control, down)
	if WarneSpellBookWidget._base.OnControl(self, control, down) then
		return true
	end
end

function WarneSpellBookWidget:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	
	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	
	return table.concat(t, "  ")
end

return WarneSpellBookWidget