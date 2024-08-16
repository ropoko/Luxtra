local lummander = require('lummander')
local Themes = require('luxtra.types.themes')
local Actions = require('luxtra.core.cli.actions')

local Cli = {
	instance = nil
}

function Cli:new()
	self.instance = lummander.new({
		title = 'Luxtra',
		tag = 'luxtra',
		description = 'Static blog generator based on markdown',
		version = '0.0.1',
		author = 'ropoko',
		theme = "acid",
		flag_prevent_help = false
	})
end

function Cli:options()
	self.instance:command('generate', 'start your blog')
	:action(function(parsed)
		Actions:generate()
	end)


	self.instance:command('build [theme]', 'build the website')
	:action(function(parsed)
		local theme = parsed.theme or Themes.DEFAULT
		Actions:build(theme)
	end)
end

function Cli:run(arg)
	self:new()
	self:options()
	self.instance:parse(arg)
end

return Cli
