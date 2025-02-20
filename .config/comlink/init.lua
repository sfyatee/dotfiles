local comlink = require("comlink")

local config = {
	server = "chat.sfyatee.com",
	user = "sfyatee",
	nick = "sfyatee",
	password = "",
	real_name = "demian garcia",
}

-- server config to connect
comlink.connect(config)

-- binds
comlink.bind("ctrl+c", "quit")
comlink.bind("ctrl+n", "next-channel")
comlink.bind("ctrl+p", "prev-channel")
