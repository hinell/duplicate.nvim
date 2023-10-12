-- Created-at...: October 16, 2023
--- @module editor
local M = {}
M.Range = require("duplicate.Range").Range

-- LuaFormatter off
M.keyseq_CTRLV = vim.api.nvim_replace_termcodes("<C-V>", true, false, true) -- Set left '< mark
M.keyseq_ESC   = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
M.keyseq_MLA   = vim.api.nvim_replace_termcodes("m<", true, false, true) -- Set left '< mark
M.keyseq_MRA   = vim.api.nvim_replace_termcodes("m>", true, false, true) -- Set right '> mark
M.keyseq_O     = vim.api.nvim_replace_termcodes("O", true, false, true) -- Set right '> mark

--- Duplicates line starting at given cursor; offset may be specified; 
--- expected to be run in normal or insert mode if used in vim command
--- @tparam table - options from cb from nvim_create_user_command
--- @treturn M.Range
function M:duplicateLine(cursor, options)

	if type(self.Range) ~= "table" and self.Range.new == nil then
		return error(("%s: expect Range class with :new() method"):format(debug.getinfo(1).source)) 
	end

	local cursor = cursor or vim.fn.getpos(".")
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
	cursor = vim.fn.getpos(".")
	return self.Range:new(cursor, cursor)
end

--- Duplicates lines;
--- @tparam table - options from cb from nvim_create_user_command 
--- @treturn M.Range
function M:duplicateByOffset(dupLineOffset, config)

	if type(self.Range) ~= "table" and self.Range.new == nil then
		return error(("%s: expect Range class with :new() method"):format(debug.getinfo(1).source)) 
	end
	
	-- if true then return end
	local mode = vim.api.nvim_get_mode().mode
	-- Though, this function can duplicate blocks, we don't intend to allow it 
	if (not config.visual.block) and mode == M.keyseq_CTRLV then
		error("duplicate.nvim: blockwise visual mode is not supported yet, "
		.. "cause somehow start/stop selection points are shifted")
		return
	end 
	-- If run from cmd pane (normal/insert mode),
	-- switch to the last visual mode
	if mode == "n" or mode == "i" then
		vim.cmd([[noautocmd normal! gv]])
	end
	-- if not (string.match(mode, "[vVxsS]") or mode == M.keyseq_CTRLV) then
	-- 	error("duplicate.nvim: can only be called in visual mode. Current mode: " .. mode)
	-- 	return
	-- end

	local userSelLines = self.Range:new(
		vim.fn.getpos("v"),
		vim.fn.getpos(".")
	)

	-- Flip positions, of posStart if it's below posEnd towards EOF 
	-- We assume that poStart is always near to 0 line
	-- This is used to ensure col is at the last cursor position
	-- if userSelLines.posStart[2] > userSelLines[2][2] then
	-- 	local selTmp   = userSelLines.posStart
	-- 	-- userSelLines.posStart = userSelLines[2]
	-- 	-- userSelLines[2]   = selTmp
	-- end

	local selPosStart = { 0, math.min(userSelLines[1][2], userSelLines[2][2]), math.min(userSelLines[1][3], userSelLines[2][3]), 0 }
	local selPosEnd   = { 0, math.max(userSelLines[1][2], userSelLines[2][2]), math.max(userSelLines[1][3], userSelLines[2][3]), 0 }

	userSelLines[1] = selPosStart
	userSelLines[2] = selPosEnd

	-- Store currently selected lines into register 
	vim.cmd([[noautocmd normal! "dy]]) 

	if vim.fn.foldclosed(userSelLines[1][2]) > 1 then
		vim.cmd([[noautocmd foldopen]])
	end

	-- true - downward
	local duplDirection = true
	local linesAtCursor = vim.split(vim.fn.getreg("d"), "\n", { trimempty = true })
	local bufinfo = vim.fn.getbufinfo(vim.fn.bufnr())[1]

	-- { line, col } is a position to paste selected text at
	-- col have to be remembered to be used for cursor later
	local line	   = 0
	local colStart = 0
	local colEnd  = math.max(userSelLines[1][3], userSelLines[2][3])

	if dupLineOffset == 0 then
		vim.cmd([[noautocmd normal! gv]])
		return
	end

	if dupLineOffset == 1 then
		duplDirection = true
		line = userSelLines[2][2] 
		-- No need to adjust current line pos; this is done by nvim_put
	end

	if dupLineOffset == -1 then
		duplDirection = false
		line = userSelLines[1][2]
		-- No need to adjust current line pos; this is done by nvim_put
	end

	if dupLineOffset > 1 then
		line = userSelLines[2][2]
		line = line + dupLineOffset - 1
	end

	if dupLineOffset < -1 then
		-- dupLineOffset = 1
		line = userSelLines[1][2]
		duplDirection = false
		line = line + dupLineOffset + 1
	end

	vim.api.nvim_win_set_cursor(0, { math.min(bufinfo.linecount, math.max(1, line)), colEnd })
	vim.api.nvim_put(linesAtCursor, "l", duplDirection, false)

	-- Adjust pasted text selection in different modes
	-- local nextSelectionColOffset = 0
	if mode == self.keyseq_CTRLV then
		local colMax = math.max(colStart, colEnd)
		local colMin = math.min(colStart, colEnd)
		local colMaxMinDiff = colMax - colMin
		colEnd   = colMaxMinDiff
	end

	-- In linewise visual mode V mode start and end columns should be maxxed out
	if mode == "V" then
		colStart = 0
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

	local selLinesDiff	  = userSelLines[2][2] - userSelLines[1][2]
	local nextSelPosStart = { math.max(1, line + nextSelectionLineOffset), math.max(0, colStart) }
	local nextSelPosEnd   = { math.max(1, line + nextSelectionLineOffset + selLinesDiff), math.max(0, colEnd) }
	return self.Range:new(nextSelPosStart, nextSelPosEnd)
end


--- Set visual marks '< and '> to positions provided to Range 
--- @treturn nil
function M.setVisualMarksTo(range)
	local posStart = range[1]
	local posEnd   = range[2]
	if #posStart == 4 then posStart = { posStart[2]	, posStart[3] } end
	if #posEnd	 == 4 then posEnd   = { posEnd[2]	, posEnd[3] } end

	local sameLine	  = posStart[1] == posEnd[1]
	local sameCol     = posStart[2] == posEnd[2]

	if sameLine and sameCol then return end

	local selPosStart = { 0, 0 }
	local selPosEnd   = { 0, 0 }
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
end

--- Change nvim to visual mode and select a range (text between two points)
--- @treturn nil
function M:selectVisual(range)
	self.setVisualMarksTo(range)
	vim.cmd([[noautocmd normal! gv]])
end

--- TODO: Add description [October 16, 2023]
-- @tparam type self
-- @treturn {type}
function M:isVisualMode (mode)
	mode = mode or vim.api.nvim_get_mode().mode
	return (mode == "v" or mode == "V" or mode == self.keyseq_CTRLV)
end

return M
