local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"


local BOOK_ATLAS = "images/warne_spellbook_ui.xml"

--[[local function OnSpellChangeLeft()
    
end

local function OnSpellChangeRight()
    
end]]

local SPELLSCALE = .7

local WarneSpellControls = Class(Widget, function(self)
    Widget._ctor(self, "WarneSpellControls")

    self.spellBtn = self:AddChild(ImageButton(BOOK_ATLAS, "createspell_button.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.spellBtn:SetScale(SPELLSCALE, SPELLSCALE, SPELLSCALE)
    self.spellBtn:SetPosition(0, -40, 0)
    self.spellBtn:SetText(STRINGS.UI.WARNE_SPELLS.SPELL)

    self.rotleft = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.rotleft:SetPosition(-80, -40, 0)
    self.rotleft:SetScale(-.7, .7, .7)
    --self.rotleft:SetOnClick()

    self.rotright = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.rotright:SetPosition(80, -40, 0)
    self.rotright:SetScale(.7, .7, .7)
    --self.rotright:SetOnClick()

    --self:RefreshTooltips()
end)

--[[function WarneSpellControls:RefreshTooltips()
    local controller_id = TheInput:GetControllerID()
    self.spellBtn:SetTooltip((self.map_tooltip or STRINGS.UI.HUD.MAP).."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_MAP))..")")
    self.rotleft:SetTooltip(STRINGS.UI.HUD.ROTLEFT.."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT))..")")
    self.rotright:SetTooltip(STRINGS.UI.HUD.ROTRIGHT.."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT))..")")
end]]

function WarneSpellControls:Show()
    self._base.Show(self)
    --self:RefreshTooltips()
end

function WarneSpellControls:ShowSpellButton()
    self.spellBtn:Show()
end

function WarneSpellControls:HideSpellButton()
    self.spellBtn:Hide()
end

return WarneSpellControls
