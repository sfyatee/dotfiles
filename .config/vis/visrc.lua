require("vis")
require("vis-leah-open")

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme sfyatee")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command('set syntax off')
end)
