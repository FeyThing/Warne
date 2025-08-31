local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddClassPostConstruct = ENV.AddClassPostConstruct

AddClassPostConstruct("widgets/healthbadge", function(self)
    if self.anim and self.owner and self.owner:HasTag("lich") then
        self.anim:GetAnimState():SetMultColour(0.2, 0.2, 0.2, 1)
        
        self.backing:GetAnimState():OverrideSymbol("bg", "health_warne", "bg")
        self.circleframe:GetAnimState():OverrideSymbol("icon", "health_warne", "heart")
        self.circleframe2:GetAnimState():OverrideSymbol("frame_circle", "health_warne", "frame_circle")
    end
end)

AddClassPostConstruct("widgets/hungerbadge", function(self)
    if self.anim and self.owner and self.owner:HasTag("lich") then
        self.anim:GetAnimState():SetMultColour(0.5, 0.2, 0.5, 1)
        
        self.backing:GetAnimState():OverrideSymbol("bg", "hunger_warne", "bg")
        self.circleframe:GetAnimState():OverrideSymbol("icon", "hunger_warne", "heart")
        self.circleframe:GetAnimState():OverrideSymbol("frame_circle", "hunger_warne", "frame_circle")
    end
end)

AddClassPostConstruct("widgets/hungerbadge", function(self)
    if self.anim and self.owner and self.owner:HasTag("lich") then
        self.anim:GetAnimState():SetMultColour(0.5, 0.2, 0.5, 1)
        
        self.backing:GetAnimState():OverrideSymbol("bg", "hunger_warne", "bg")
        self.circleframe:GetAnimState():OverrideSymbol("icon", "hunger_warne", "heart")
        self.circleframe:GetAnimState():OverrideSymbol("frame_circle", "hunger_warne", "frame_circle")
    end
end)

local TEMPLATES = require("widgets/redux/templates")

local OldMakeUIStatusBadge = TEMPLATES.MakeUIStatusBadge
function TEMPLATES.MakeUIStatusBadge(_status_name, c, ...)
	local status = OldMakeUIStatusBadge(_status_name, c, ...)
	
	local OldChangeCharacter = status and status.ChangeCharacter
	if OldChangeCharacter then
		status.ChangeCharacter = function(self, character, ...)
			OldChangeCharacter(self, character, ...)
			
			if character == "warne" then
				local status_name = TUNING.CHARACTER_DETAILS_OVERRIDE[character.."_".._status_name] or _status_name
				status.status_icon:SetTexture("images/warne_redux.xml", "status_"..status_name..".tex")
			end
		end
	end
	
	return status
end