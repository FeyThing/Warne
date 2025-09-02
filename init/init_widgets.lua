local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddClassPostConstruct = ENV.AddClassPostConstruct

--	Phylactery inv fx

local UIAnim = require("widgets/uianim")
local WarneSpellBookScreen = require("screens/warnespellbookpopupscreen")
local WarneSpellControls = require("widgets/warnespellcontrols")

AddClassPostConstruct("widgets/itemtile", function(self, invitem)
	local function ToggleSoulBoundFX()
		if ThePlayer and ThePlayer.components.attuner and ThePlayer.components.attuner:IsAttunedTo(invitem) then
			if self.shadowfx == nil then
				self.shadowfx = self.image:AddChild(UIAnim())
				self.shadowfx:GetAnimState():SetBank("inventory_fx_shadow")
				self.shadowfx:GetAnimState():SetBuild("inventory_fx_shadow")
				self.shadowfx:GetAnimState():PlayAnimation("idle", true)
				self.shadowfx:GetAnimState():SetTime(math.random() * self.shadowfx:GetAnimState():GetCurrentAnimationTime())
				self.shadowfx:SetScale(.25)
				self.shadowfx:GetAnimState():AnimateWhilePaused(false)
				self.shadowfx:SetClickable(false)
			end
		elseif self.shadowfx then
			self.shadowfx:Kill()
			self.shadowfx = nil
		end
	end
	
	if invitem:HasTag("phylactery") then
		ToggleSoulBoundFX()
		
		self.inst:ListenForEvent("onlichattuned", function(invitem)
			ToggleSoulBoundFX()
		end, invitem)
	end
end)

--	Spellbook

ENV.AddPopup("WARNESPELLBOOK")

POPUPS.WARNESPELLBOOK.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseWarneSpellBook()
        elseif not inst.HUD:OpenWarneSpellBook() then
            POPUPS.WARNESPELLBOOK:Close(inst)
        end
    end
end


AddClassPostConstruct("screens/playerhud", function(self)
    function self:OpenWarneSpellBook()
        self:CloseWarneSpellBook()
        self.WarneSpellBook = WarneSpellBookScreen(self.owner)
        self:OpenScreenUnderPause(self.WarneSpellBook)
        
        return true
    end
    
    function self:CloseWarneSpellBook()
        if self.WarneSpellBook ~= nil then
            if self.WarneSpellBook.inst:IsValid() then
                TheFrontEnd:PopScreen(self.WarneSpellBook)
            end
            self.WarneSpellBook = nil
        end
    end
end)

-- SpellButton

AddClassPostConstruct("widgets/controls", function(self)
	if self.owner and self.owner.prefab == "warne" then
		self.warnespellcontrols = self.bottom_root:AddChild(WarneSpellControls(self.owner))
		self.warnespellcontrols:SetPosition(-590, 70, 0)
	end
end)