-- Created-at...: September 25, 2023
-- Description..: This file was autogenerated
-- @module Lines
-- M
-- Extension class for lines management
local M = {}

-- LuaFormatter off
M.keyseq_CTRLV = vim.api.nvim_replace_termcodes("<C-V>", true, false, true) -- Set left '< mark
M.keyseq_ESC   = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
M.keyseq_MLA   = vim.api.nvim_replace_termcodes("m<", true, false, true) -- Set left '< mark
M.keyseq_MRA   = vim.api.nvim_replace_termcodes("m>", true, false, true) -- Set right '> mark

--- Small class for duplication
--- @class M.Lines
M.Lines = { prototype = { ctx = {} } }
M.Lines._mt = {
	__index = function(table, key)
		return table.constructor.prototype[key]
		or table.constructor.super
		and table.constructor.super.prototype[key]
	end,
}
-- LuaFormatter on

--- Creates new instance static method)
--- @tparam  Table containing area
function M.Lines:new(config, posStart, posEnd)
	local instance = {}
	instance.config = config
	instance.constructor = self

	instance.posStart = posStart
	instance.posEnd   = posEnd
	

	setmetatable(instance, self._mt)
	return instance
end

--- Change nvim to visual mode and select text between two points
--- @tparam type param
--- @treturn returnType
function M.Lines.prototype:visualSelect() 
	local posStart = self.posStart
	local posEnd   = self.posEnd
	if #posStart == 4 then posStart = { posStart[2]	, posStart[3] } end
	if #posEnd == 4	  then posEnd   = { posEnd[2]	, posEnd[3] } end

	local selPosStart = { 0, 0 }
	local selPosEnd   = { 0, 0 }
	local sameLine	  = posStart[1] == posEnd[1]
	local sameCol     = posStart[2] == posEnd[2]

	if sameLine and sameCol then return end

	-- This hackery is used to update '< and '> marks later to select text.
	-- Neovim is truly crappy at keeping current selection updated as user moves
	-- cursor. Cursor at getpos('.') never matches '< mark
	selPosStart	= { math.min(posStart[1] ,posEnd[1]) ,math.min(posStart[2] ,posEnd[2]) }
	selPosEnd	= { math.max(posStart[1] ,posEnd[1]) ,math.max(posStart[2] ,posEnd[2]) }

	-- Set visual selection marks and go back to latest visual mode
	vim.api.nvim_win_set_cursor(0, selPosStart)
	vim.api.nvim_feedkeys(M.keyseq_MLA, "x", false)
	vim.api.nvim_win_set_cursor(0, selPosEnd)
	vim.api.nvim_feedkeys(M.keyseq_MRA, "x", false)

	-- print(vim.inspect(vim.fn.getpos("'<")),vim.inspect(vim.fn.getpos("'>")))
	vim.cmd([[noautocmd normal! gv]])
end

--- Duplicates lines
--- @tparam table - options from cb from nvim_create_user_command
--- @treturn *
function M.Lines:duplicate(options, config)
	--vim.api.nvim_win_get_cursor(0)
	local cursor = vim.fn.getpos(".")
	local line, col = cursor[2], cursor[3] - 1
	local linesAtCursor = vim.api.nvim_buf_get_lines(0, line - 1, line, false)
	local dupLineOffset = 0

	if #options.args > 0 then
		dupLineOffset = tonumber(options.args)
	end

	local offsetOld = dupLineOffset
	if dupLineOffset == 1 or dupLineOffset == -1 then
		dupLineOffset = 0
	end


	-- Default values
	if dupLineOffset < -1 then
		duplDirection = false
	end

	line = line + dupLineOffset

	local bufinfo = vim.fn.getbufinfo(vim.fn.bufnr())[1]

	vim.api.nvim_win_set_cursor(0, { math.min(bufinfo.linecount, math.max(1, line)), col })
	vim.api.nvim_put(linesAtCursor, "l", duplDirection, false)
	if offsetOld >= 1 then
		line = line + 1
	end

	vim.api.nvim_win_set_cursor(0, { math.max(1, line), col })
end

--- Duplicates lines
--- @tparam table - options from cb from nvim_create_user_command
--- @treturn *
function M.Lines:selectionDuplicate(options, config)
	-- vim.cmd([[noautocmd normal! gv]])
	-- if true then return end
	local mode = vim.fn.mode()
	-- Though, this function can duplicate blocks, we don't intend to allow it 
	if (not config.visual.block) and mode == M.keyseq_CTRLV then
		error("duplicate.nvim: blockwise visual mode is not supported yet, "
		.. "cause somehow start/stop selection points are shifted")
		return
	end 

	-- if not (string.match(mode, "[vVxsS]") or mode == M.keyseq_CTRLV) then
	-- 	error("duplicate.nvim: can only be called in visual mode. Current mode: " .. mode)
	-- 	return
	-- end

	local userSelLines = self:new(
		config,
		vim.fn.getpos("v"),
		vim.fn.getpos(".")
	)
	-- Flip positions, of posStart if it's below posEnd towards EOF 
	-- We assume that poStart is always near to 0 line
	-- This is used to ensure col is at the last cursor position
	-- if userSelLines.posStart[2] > userSelLines.posEnd[2] then
	-- 	local selTmp   = userSelLines.posStart
	-- 	-- userSelLines.posStart = userSelLines.posEnd
	-- 	-- userSelLines.posEnd   = selTmp
	-- end

	local _posStart = { 0, math.min(userSelLines.posStart[2], userSelLines.posEnd[2]), math.min(userSelLines.posStart[3], userSelLines.posEnd[3]), 0 }
	local _posEnd   = { 0, math.max(userSelLines.posStart[2], userSelLines.posEnd[2]), math.max(userSelLines.posStart[3], userSelLines.posEnd[3]), 0 }

	userSelLines.posStart = _posStart
	userSelLines.posEnd   = _posEnd

	-- Store currently selected lines into register 
	vim.cmd([[noautocmd normal! "0y"]]) 
	if vim.fn.foldclosed(userSelLines.posStart[2]) > 1 then
		vim.cmd([[noautocmd foldopen]])
	end

	if #options.args > 0 then
		dupLineOffset = tonumber(options.args)
	end

	-- true - downward
	local duplDirection = true
	local linesAtCursor = vim.split(vim.fn.getreg("0"), "\n", { trimempty = true })
	local bufinfo = vim.fn.getbufinfo(vim.fn.bufnr())[1]

	-- { line, col } is a position to paste selected text at
	-- col have to be remembered to be used for cursor later
	local line	   = 0
	local colStart = 0
	local colEnd  = userSelLines.posEnd[3]

	if dupLineOffset == 0 then
		vim.cmd([[noautocmd normal! gv]])
		return
	end

	if dupLineOffset == 1 then
		duplDirection = true
		line = userSelLines.posEnd[2] 
		-- No need to adjust current line pos; this is done by nvim_put
	end

	if dupLineOffset == -1 then
		duplDirection = false
		line = userSelLines.posStart[2]
		-- No need to adjust current line pos; this is done by nvim_put
	end

	if dupLineOffset > 1 then
		line = userSelLines.posEnd[2]
		line = line + dupLineOffset - 1
	end

	if dupLineOffset < -1 then
		-- dupLineOffset = 1
		line = userSelLines.posStart[2]
		duplDirection = false
		line = line + dupLineOffset + 1
	end

	vim.api.nvim_win_set_cursor(0, { math.min(bufinfo.linecount, math.max(1, line)), colEnd })
	vim.api.nvim_put(linesAtCursor, "l", duplDirection, false)

	-- Select pasted text
	if not config.visual.selectAfter then
		return
	end

	-- Adjust pasted text selection in different modes
	-- local nextSelectionColOffset = 0
	if mode == M.keyseq_CTRLV then
		local colMax = math.max(colStart, colEnd)
		local colMin = math.min(colStart, colEnd)
		local colMaxMinDiff = colMax - colMin
		colEnd   = colMaxMinDiff
	end

	-- In linewise visual mode V mode start and end columns should be maxxed out
	if mode == "V" then
		colEnd   = vim.v.maxcol
	end

	local nextSelectionLineOffset = 0
	if mode == "v" then
		if duplDirection then
			colStart = 0
		else
			nextSelectionLineOffset = 0
		end
	end

	if duplDirection then
		nextSelectionLineOffset = 1
	end

	local selLinesDiff	= userSelLines.posEnd[2] - userSelLines.posStart[2]
	local selPosStart	= { math.max(1, line + nextSelectionLineOffset), math.max(0, colStart) }
	local selPosEnd		= { math.max(1, line + nextSelectionLineOffset + selLinesDiff), math.max(0, colEnd) }
	local duplicatedLines = self:new(config, selPosStart, selPosEnd)
	duplicatedLines:visualSelect()
end

return M