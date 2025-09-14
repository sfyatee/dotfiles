local comlink = require("comlink")

---The Format module formats a message to IRC style formatting
---@class Format
local M = {}

-- Replace substring "old" with "new"
local function replace(string, old, new)
	local s = string
	local search_start_idx = 1

	while true do
		local start_idx, end_idx = s:find(old, search_start_idx, true)
		if not start_idx then
			break
		end

		local postfix = s:sub(end_idx + 1)
		s = s:sub(1, (start_idx - 1)) .. new .. postfix

		search_start_idx = -1 * postfix:len()
	end

	return s
end

local function format(cmdline)
	local channel = comlink.selected_channel()
	if channel then
		local s = replace(cmdline, "**", "\x02")
		s = replace(s, "*", "\x1D")
		s = replace(s, "~", "\x1E")
		s = replace(s, "_", "\x1F")
		s = replace(s, "<blue>", "\x0302")
		s = replace(s, "</blue>", "\x03")
		channel:send_msg(s)
	end
end

---@class FormatConfiguration

---Setup sets up the format cmd
---
---@param config FormatConfiguration The configuration
function M.setup(config)
	comlink.add_command("fmt", format)
end

return M
