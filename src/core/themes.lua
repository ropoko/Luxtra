local io = require('io')
local DirectoriesType = require('luxtra.types.directories')

local Themes = {}

function Themes.load_theme(theme_name)
	local theme_path = DirectoriesType.THEMES_DIR .. '/' .. theme_name

	-- index page
	local index_path = theme_path .. '/index.etlua'
	local index_style_path = theme_path .. '/index.css'

	local index_file = io.open(index_path, "r")

	if not index_file then
		error("Theme file not found: " .. index_path)
	end

	local index_content = index_file:read("*all")
	index_file:close()

	local style_file = io.open(index_style_path, "r")

	if not style_file then
		return nil, "Style file not found: " .. index_style_path
	end

	local style_content = style_file:read("*all")
	style_file:close()

	-- inject css
	local index_with_css = index_content:gsub("</head>", "<style>" .. style_content .. "</style></head>")

	-- post page
	local post_path = theme_path .. '/post.etlua'
	local post_style_path = theme_path .. '/post.css'

	local post_file = io.open(post_path, "r")

	if not post_file then
		error("Theme file not found: " .. post_path)
	end

	local post_content = post_file:read("*all")
	post_file:close()

	local post_style_file = io.open(post_style_path, "r")

	if not post_style_file then
		return nil, "Style file not found: " .. post_style_path
	end

	local post_style_content = post_style_file:read("*all")
	post_style_file:close()

	local post_with_css = post_content:gsub("</head>", "<style>" .. post_style_content .. "</style></head>")


	return index_with_css, post_with_css
end

return Themes
