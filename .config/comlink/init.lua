local comlink = require("comlink")

local config = {
	server = "",
	user = "sfyatee",
	nick = "sfyatee",
	password = "",
	real_name = "demian garcia",
}

-- Pass the server config to connect. Connect to as many servers as you need
comlink.connect(config)

-- Bind a key to an action
comlink.bind("ctrl+c", "quit")
