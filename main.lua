local etlua = require('etlua')
local os = require('os')
local lfs = require('lfs')

local json = require('lib.json')

local MarkdownParser = require('src.core.markdown_parser')
local DirectoriesType = require('src.types.directories')
local FileUtils = require('src.utils.file')

-- TODO: remove later
local current_path = 'examples/blog/'

local CONFIG = {}

--[[
	required files/directories:
	- luxtra.config.json
	- pages/
		- *.md
]]
local function check_directories()
	if not FileUtils.file_exists(current_path..DirectoriesType.CONFIG_FILE) then
		print('luxtra.config.json not found')
		os.exit(1)
	end

	CONFIG = json.decode(FileUtils.get_file_content(current_path..DirectoriesType.CONFIG_FILE))

	if not FileUtils.file_exists(current_path..DirectoriesType.PAGES_DIR) then
		print('pages/ directory not found')
		os.exit(1)
	end
end

local function generate_index_page(frontmatter)
	local render_html = etlua.compile([[
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title><%= title %></title>
		</head>
		<body>
			<h1><%= title %></h1>

			<% for k, item in pairs(frontmatter) do %>
				<a href="<%= item.slug %>.html"> <h1> <%= item.title %> </h1> </a>
				<small> <%= item.description %> </small>
				<hr />
			<% end %>
		</body>
		</html>
	]])

	local html = render_html({ title = CONFIG.title, frontmatter = frontmatter })

	FileUtils.save_html_file(current_path..DirectoriesType.PAGES_DIR..'/index', html)
end

local function process_markdown_files()
	local frontmatter_list = {}

	for file_name in lfs.dir(current_path..DirectoriesType.PAGES_DIR) do
		if file_name:match('%.md$') then
			local markdown_content = FileUtils.get_file_content(current_path..DirectoriesType.PAGES_DIR..'/'..file_name)

			if #markdown_content > 0 then
				local frontmatter = MarkdownParser:get_frontmatter(file_name, markdown_content)
				table.insert(frontmatter_list, frontmatter)

				local html = MarkdownParser:parse(markdown_content)
				FileUtils.save_html_file(current_path..DirectoriesType.PAGES_DIR..'/'..frontmatter.slug, html)
			end

		end
	end

	generate_index_page(frontmatter_list)
end

local function build()
	check_directories()
	process_markdown_files()
end

build()
