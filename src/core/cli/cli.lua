local lummander = require('lummander')
local Actions = require('core.cli.actions')

local cli = lummander.new({
	title = 'Luxtra',
	tag = 'luxtra',
	description = 'Static blog generator based on markdown',
	version = '0.0.1',
	author = 'ropoko',
	theme = "acid",
	flag_prevent_help = false
})

cli
	:command('generate', 'generate a placeholder project for your blog')
	:action(function()
		Actions:generate()
	end)


cli
	:command('build', 'generate the website')
	:action(function()
		Actions:build()
	end)

cli:parse(arg)
