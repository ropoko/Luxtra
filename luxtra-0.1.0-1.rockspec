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
		["core.cli.actions"] = "src/core/cli/actions.lua",
		["core.cli.cli"] = "src/core/cli/cli.lua",
		["core.markdown_parser"] = "src/core/markdown_parser.lua",
		["types.directories"] = "src/types/directories.lua",
		["utils.file"] = "src/utils/file.lua"
	},

	install = {
		bin = {
			"bin/luxtra"
		}
	}
}
