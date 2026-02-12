require("vis")
--require("vis-leah-open")

local plug = (function() if not pcall(require, 'plugins/vis-plug') then
 	os.execute('git clone --quiet https://github.com/erf/vis-plug ' ..
	 	(os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config')
	 	.. '/vis/plugins/vis-plug')
end return require('plugins/vis-plug') end)()

-- configure plugins in an array of tables with git urls and options
local plugins = {
	{ 'https://repo.or.cz/vis-surround.git' },
}

-- require and optionally install plugins on init
plug.init(plugins, true)

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme sfyatee")
	vis.options = { autoindent = true }
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command('set syntax off')
end)
