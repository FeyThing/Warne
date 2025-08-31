local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local WarneSpellBookWidget = require "widgets/redux/warnespellbookwidget"

local WarneSpellBookPopupScreen = Class(Screen, function(self, owner)
	Screen._ctor(self, "WarneSpellBookPopupScreen")
	
	self.owner = owner
	
	local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
	black.image:SetVRegPoint(ANCHOR_MIDDLE)
	black.image:SetHRegPoint(ANCHOR_MIDDLE)
	black.image:SetVAnchor(ANCHOR_MIDDLE)
	black.image:SetHAnchor(ANCHOR_MIDDLE)
	black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
	black.image:SetTint(0, 0, 0, 0.5)
	black:SetOnClick(function() TheFrontEnd:PopScreen() end)
	black:SetHelpTextMessage("")
	
	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	root:SetHAnchor(ANCHOR_MIDDLE)
	root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)
	
	self.warnespellbook = root:AddChild(WarneSpellBookWidget(owner))
	
	self.default_focus = self.warnespellbook
	
	SetAutopaused(true)
end)

function WarneSpellBookPopupScreen:OnDestroy()
	SetAutopaused(false)
	
	POPUPS.WARNESPELLBOOK:Close(self.owner)
	
	WarneSpellBookPopupScreen._base.OnDestroy(self)
end

function WarneSpellBookPopupScreen:OnBecomeInactive()
	WarneSpellBookPopupScreen._base.OnBecomeInactive(self)
end

function WarneSpellBookPopupScreen:OnBecomeActive()
	WarneSpellBookPopupScreen._base.OnBecomeActive(self)
end

function WarneSpellBookPopupScreen:OnControl(control, down)
	if WarneSpellBookPopupScreen._base.OnControl(self, control, down) then
		return true
	end
	
	if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		TheFrontEnd:PopScreen()
		return true
	end
	
	return false
end

function WarneSpellBookPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	
	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL).." "..STRINGS.UI.HELP.BACK)
	
	return table.concat(t, "  ")
end

return WarneSpellBookPopupScreen