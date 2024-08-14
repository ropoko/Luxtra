package = "luxtra"
version = "0.1.0-1"

source = {
	url = "git://github.com/ropoko/luxtra"
}

description = {
	summary = "Static blog generator based on markdown",

	detailed = [[
		Luxtra is a static site generator written in Lua, inspired by Nextra.
		It processes Markdown files and generates a static blog website.
	]],

	homepage = "https://github.com/ropoko/luxtra",
	license = "MIT"
}

dependencies = {
	"lua >= 5.4",
	"luafilesystem >= 1.8.0-1",
	"etlua >= 1.3.0-1",
	"lummander >= 0.1.0-2"
}

build = {
	type = "builtin",

	modules = {
		["luxtra"] = "main.lua",
		["core.cli"] = "src/core/cli.lua",
		["luxtra.core.markdown"] = "src/core/markdown_parser.lua",
		["luxtra.utils.file"] = "src/utils/file.lua",
		["luxtra.types.directories"] = "src/types/directories.lua"
	},

	install = {
		bin = {
			"bin/luxtra"
		}
	}
}
