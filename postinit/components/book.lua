local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local Book = require("components/book")

local OldOnPeruse = Book.OnPeruse
function Book:OnPeruse(reader, ...)
	local _old_peruse_sanity = self.peruse_sanity
	if reader ~= nil and reader:HasTag("lich") then
		self.peruse_sanity = 0
	end
	
	local success, reason = OldOnPeruse(self, reader, ...)
	
	self.peruse_sanity = _old_peruse_sanity
	
	return success, reason
end