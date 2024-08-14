local lummander = require('lummander')
local Actions = require('src.core.cli.actions')

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


	self.instance:command('build', 'build the website')
	:action(function(parsed)
		Actions:build()
	end)
end


function Cli:run(arg)
	self:new()
	self:options()
	self.instance:parse(arg)
end

return Cli
