RegisterSkilltreeBGForCharacter("images/warne_skilltree.xml", "warne") -- add bg
local SkillTreeDefs = require("prefabs/skilltree_defs")
local CreateSkillTree = function()
    local BuildSkillsData = require("prefabs/skilltree_warne")
    if BuildSkillsData then
        local data = BuildSkillsData(SkillTreeDefs.FN)

        if data then
            for name, data in pairs(data.SKILLS) do
                if not data.lock_open and data.icon then
                    RegisterSkilltreeIconsAtlas("images/warne_skilltree.xml", name .. ".tex") -- add icons
                end
            end
            SkillTreeDefs.CreateSkillTreeFor("warne", data.SKILLS)
            SkillTreeDefs.SKILLTREE_ORDERS["warne"] = data.ORDERS
        end
    end
end
CreateSkillTree();

local SKIN_AFFINITY_INFO = require("skin_affinity_info")

GLOBAL.PREFAB_SKINS.warne = {"warne_none"}
GLOBAL.PREFAB_SKINS_IDS.warne = {}
SKIN_AFFINITY_INFO.warne = {}


AddModCharacter("warne", "MALE", skin_modes)