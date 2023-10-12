local usercmd = vim.api.nvim_create_user_command
local config = require("duplicate.config")
local editor = require("duplicate.editor")

usercmd("LineDuplicate",
        function(options) editor:duplicateLine(nil, options, config) end,
        { count = true, nargs = 1, addr = "lines" })

usercmd("VisualDuplicate", function(options)

	-- The offset specified by +-N in `:Command +N`
	local offset = #options.args > 0 and tonumber(options.args) or 0
	local duplicatedRange = editor:duplicateByOffset(offset, config)

	if not config.visual.selectAfter then return end
	local mode = vim.api.nvim_get_mode().mode
	if duplicatedRange then
		editor:selectVisual(duplicatedRange)
		if (editor:isVisualMode()) and offset < 0 then
			vim.api.nvim_feedkeys(editor.keyseq_O, "x", false)
		end
	end
end, { range = "%", nargs = 1, addr = "lines" })

usercmd("LinesDuplicate", function()
	local message = "LinesDuplicate is deprecated; use VisualDuplicate instead"
	vim.notify(message, vim.log.levels.WARN)
end, { range = "%", nargs = 1, addr = "lines" })
