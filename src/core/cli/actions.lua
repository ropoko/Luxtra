local io = require('io')
local os = require('os')
local lfs = require('lfs')
local etlua = require('etlua')

local json = require('luxtra.lib.json')
local MarkdownParser = require('luxtra.core.markdown_parser')
local DirectoriesType = require('luxtra.types.directories')
local FileUtils = require('luxtra.utils.file')

local Actions = {}

function Actions:generate()
	lfs.mkdir(DirectoriesType.PAGES_DIR)
	lfs.mkdir(DirectoriesType.DOCS_DIR)

	local config = io.open('luxtra.config.json', 'w')

	local config_content = [[
	{
		"title": "My Blog",
		"description": "This is my blog",
		"author": "John Doe"
	}
	]]

	-- remove spaces at the beginning of the line
	config:write((config_content:gsub("^%s+", ""):gsub("\n%s+", "\n")))
	config:close()

	local page1 = io.open(DirectoriesType.PAGES_DIR .. '/page1.md', 'w')
	if not page1 then return end

	local content = [[
	---
	title: Page 1
	description: This is page 1
	---
	# hello world
	hey, test post here
	]]

	page1:write((content:gsub("^%s+", ""):gsub("\n%s+", "\n")))
	page1:close()
end

local CONFIG = {}

--[[
	required files/directories:
	- luxtra.config.json
	- pages/
		- *.md
]]
local function check_directories()
	if not FileUtils.file_exists(DirectoriesType.CONFIG_FILE) then
		print('luxtra.config.json not found')
		os.exit(1)
	end

	CONFIG = json.decode(FileUtils.get_file_content(DirectoriesType.CONFIG_FILE))

	if not FileUtils.file_exists(DirectoriesType.PAGES_DIR) then
		print('pages/ directory not found')
		os.exit(1)
	end
end

local function generate_index_page(frontmatter, theme_template)
	local render_html = etlua.compile(theme_template)

	local html = render_html({ title = CONFIG.title, frontmatter = frontmatter })

	FileUtils.save_html_file(DirectoriesType.DOCS_DIR..'/index', html)
end

local function process_markdown_files(theme_template)
	local frontmatter_list = {}

	for file_name in lfs.dir(DirectoriesType.PAGES_DIR) do
		if file_name:match('%.md$') then
			local markdown_content = FileUtils.get_file_content(DirectoriesType.PAGES_DIR..'/'..file_name)

			if #markdown_content > 0 then
				local frontmatter = MarkdownParser:get_frontmatter(file_name, markdown_content)
				table.insert(frontmatter_list, frontmatter)

				local html = MarkdownParser:parse(markdown_content)
				FileUtils.save_html_file(DirectoriesType.DOCS_DIR..'/'..frontmatter.slug, html)
			end

		end
	end

	generate_index_page(frontmatter_list, theme_template)
end

function Actions:build(theme)
	local theme_template = FileUtils.get_file_content('themes/'..theme..'/index.html')

	check_directories()
	process_markdown_files(theme_template)
end

return Actions
