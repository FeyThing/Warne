local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local Sanity = require("components/sanity")

local OldDoDelta = Sanity.DoDelta
function Sanity:DoDelta(...)
    if self.inst._sanity_dig_immune then
        return
    end
    
    return OldDoDelta(self, ...)
end