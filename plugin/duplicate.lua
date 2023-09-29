local usercmd = vim.api.nvim_create_user_command
local config  = require("duplicate.config") 
local Lines   = require("duplicate.Lines").Lines

usercmd("LineDuplicate"		,function(options) return Lines:duplicate(options, config) end, { count = true, nargs =1, addr = "lines" })
usercmd("VisualDuplicate"	,function(options) return Lines:selectionDuplicate(options, config) end, { range = "%", nargs =1, addr = "lines" })

