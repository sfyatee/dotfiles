-- complete file path at primary selection location using a bash style
-- completion

-- 25may2019  +leah+
-- 13dec2020  +leah+ also bind C-x C-f

local posix = require 'posix'
local math = require 'math'

fun = function()
	local win = vis.win
	local file = win.file
	local pos = win.selection.pos
	if not pos then return end
	-- TODO do something clever here
	local range = file:text_object_longword(pos > 0 and pos-1 or pos);
	if not range then return end
	if range.finish > pos then range.finish = pos end
	local prefix = file:content(range)
	if not prefix then return end
	if prefix:match("^%s*$") then
		prefix = ""
		range.start = pos
		range.finish = pos
	end

	if prefix:match("^:") then
		out = {}
		-- as of 2019-02-09 f8c9f23
		for _, cmd in pairs({
		      ":cd", ":help", ":map", ":map-window", ":unmap",
		      ":unmap-window", ":langmap", ":new", ":open",
		      ":qall", ":set", ":split", ":vnew", ":vsplit",
		      ":wq", ":earlier", ":later"
		}) do
			if cmd:match("^" .. prefix) then
				table.insert(out, cmd .. " ")
			end
		end
	else
		local stat = posix.stat(prefix)
		out = posix.glob(prefix .. "*", 0)
		
		if out == nil then
			out = { }
		end
	end

	if #out == 0 then
		out = prefix
	elseif #out == 1 then
		out = out[1]
		local stat = posix.stat(out)
		if stat and stat.type == "directory" then
			out = out .. "/"
		end
	else
		local lcp = out[1]
		for _, file in pairs(out) do
			for i = 1, math.min(#lcp, #file) do
				if lcp:sub(i,i) ~= file:sub(i,i) then
					lcp = lcp:sub(1,i-1)
					break
				end
			end
		end

		if #lcp > #prefix then
			out = lcp
		else
			local msg = ""
			for _, file in pairs(out) do
				msg = msg .. file:gsub(".*/", "") .. " "
			end
			vis:info(msg)
			out = prefix
		end
	end

	file:delete(range)
	file:insert(range.start, out)
	win.selection.pos = range.start + #out
end
vis:map(vis.modes.INSERT, "<C-x><C-o>", fun, "Complete file name")
vis:map(vis.modes.INSERT, "<C-x><C-f>", fun, "Complete file name")
