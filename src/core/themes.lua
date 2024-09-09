local io = require('io')
local DirectoriesType = require('luxtra.types.directories')

local Themes = {}

function Themes.load_theme(theme_name)
	local theme_path = DirectoriesType.THEMES_DIR .. '/' .. theme_name

	local index_path = theme_path .. '/index.etlua'
	local style_path = theme_path .. '/style.css'

	local index_file = io.open(index_path, "r")

	if not index_file then
		error("Theme file not found: " .. index_path)
	end

	local index_content = index_file:read("*all")
	index_file:close()

	local style_file = io.open(style_path, "r")

	if not style_file then
		return nil, "Style file not found: " .. style_path
	end

	local style_content = style_file:read("*all")
	style_file:close()

	-- inject css
	local html_with_css = index_content:gsub("</head>", "<style>" .. style_content .. "</style></head>")

	return html_with_css
end

return Themes
