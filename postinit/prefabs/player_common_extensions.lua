local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local player_common_extensions = require("prefabs/player_common_extensions")
local OldOnMakePlayerGhost = player_common_extensions.OnMakePlayerGhost

player_common_extensions.OnMakePlayerGhost = function(inst, data, ...)
    OldOnMakePlayerGhost(inst, data, ...)
    
    if inst:HasTag("lich") then
        inst.AnimState:SetBank("ghost_warne")
        inst.AnimState:SetBuild("ghost_shadow_warne")

        inst.Light:SetIntensity(.1)
        inst.Light:SetRadius(.1)
        inst.Light:SetFalloff(.1)
        inst.Light:SetColour(180/255, 55/255, 180/255)
        inst.Light:Enable(true)
    end
end


