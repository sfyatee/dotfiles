local comlink = require("comlink")
local watcher = require("watcher")
local fmt = require("fmt")

local function run_command_and_trim(command)
	-- Execute the command and capture output
	local handle = io.popen(command)
	assert(handle, "Failed to execute command")

	-- Read the output
	local result = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	-- Check if command executed successfully
	assert(success, "Command failed with exit code: " .. (exit_code or "unknown"))

	-- Trim whitespace (including newlines)
	if result then
		result = result:match("^%s*(.-)%s*$")
	end

	return result
end

fmt.setup({})
watcher.setup({
	channels = {
		"#comlink",
		"#ghostty",
		"#vaxis",
	},
})

comlink.setup({ markread_on_focus = false })

comlink.add_command("shrug", function()
	local channel = comlink.selected_channel()
	if channel then
		channel:send_msg(" ̄\\_(ツ)_/ ̄")
	end
end)

local conn = comlink.connect({
	server = "sfyatee.com",
	nick = "sfyatee",
	password = run_command_and_trim('opcache read "op://Private/76plh4kdmgqqvru6x3w4okrty4/password"'),
	real_name = "demian garcia",
	tls = true,
})
-- Set the on_message handler
conn.on_message = watcher.on_message

-- Bind a key to an action
comlink.bind("ctrl+c", "quit")
comlink.bind("ctrl+r", function()
	local channel = comlink.selected_channel()
	if channel then
		channel:mark_read()
	end
end)

comlink.add_command("screenshot", function()
	local channel = comlink.selected_channel()
	if not channel then
		comlink.log("No selected channel for cmd 'screenshot'")
		return
	end
	local handle =
		io.popen("grimshot --notify save anything - | curl --silent -F'file=@-;type=image/png' https://0x0.st")
	if not handle then
		comlink.log("Failed to execute grimshot or curl")
		return
	end
	local success, err = pcall(function()
		for line in handle:lines() do
			channel:insert_text(line)
		end
	end)
	handle:close()
	if not success then
		comlink.log("Failed to process screenshot: " .. err)
	end
end)

comlink.add_command("sh", function(cmd)
	local channel = comlink.selected_channel()
	if not channel then
		comlink.log("No selected channel for cmd 'sh'")
		return
	end
	local handle = io.popen(cmd)
	if not handle then
		comlink.log("Failed to execute " .. cmd)
		return
	end
	local success, err = pcall(function()
		for line in handle:lines() do
			channel:insert_text(line)
		end
	end)
	handle:close()
	if not success then
		comlink.log("Failed to process sh: " .. err)
	end
end)
