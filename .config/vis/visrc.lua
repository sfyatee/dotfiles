require("vis")
require("vis-leah-open")

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme sfyatee")
end)
