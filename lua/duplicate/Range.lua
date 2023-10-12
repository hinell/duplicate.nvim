-- Created-at...: September 25, 2023
-- Description..: Range class
--- @module Range
-- Extension class for lines management
-- TODO: [October 14, 2023] Move this to nvim-api.nvim 
local M = {}

--- Small class for duplication
--- @class M.Range
M.Range = { prototype = { ctx = {} } }
M.Range._mt = {
	__index = function(table, key)
		return table.constructor.prototype[key]
		or table.constructor.super
		and table.constructor.super.prototype[key]
	end,
}
-- LuaFormatter on

--- Creates new instance static method)
--- @tparam  Table containing area
function M.Range:new(posStart, posEnd, config)
	local instance = {}
	instance.config = config
	instance.constructor = self
	
	instance[1] = posStart
	instance[2] = posEnd

	setmetatable(instance, self._mt)
	return instance
end

--- Check if range is on the same line
--- @tparam  
--- @treturn boolean
function M.Range.prototype:sameLine ()
	return self[1][2] == self[2][2]
end

return M
