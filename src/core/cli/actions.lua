local io = require('io')
local os = require('os')
local lfs = require('lfs')
local etlua = require('etlua')

local json = require('luxtra.lib.json')
local MarkdownParser = require('luxtra.core.markdown_parser')
local DirectoriesType = require('luxtra.types.directories')
local FileUtils = require('luxtra.utils.file')
local Themes = require('luxtra.core.themes')

local Actions = {
	config = nil
}

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

	Actions.config = json.decode(FileUtils.get_file_content(DirectoriesType.CONFIG_FILE))

	if not FileUtils.file_exists(DirectoriesType.PAGES_DIR) then
		print('pages/ directory not found')
		os.exit(1)
	end
end

local function generate_index_page(frontmatter, theme_template)
	local render_html = etlua.compile(theme_template)

	local html = render_html({ title = Actions.config.title, frontmatter = frontmatter })

	FileUtils.save_html_file(DirectoriesType.DOCS_DIR..'/index', html)
end

local function process_markdown_files(index_template, post_template)
	local frontmatter_list = {}

	for file_name in lfs.dir(DirectoriesType.PAGES_DIR) do
		local render_html = etlua.compile(post_template)

		if file_name:match('%.md$') then
			local markdown_content = FileUtils.get_file_content(DirectoriesType.PAGES_DIR..'/'..file_name)

			if #markdown_content > 0 then
				local frontmatter = MarkdownParser:get_frontmatter(file_name, markdown_content)
				table.insert(frontmatter_list, frontmatter)

				local html = render_html({
					title = frontmatter.title,
					date = frontmatter.date,
					description = frontmatter.description,
					content = MarkdownParser:parse(markdown_content, true)
				})

				FileUtils.save_html_file(DirectoriesType.DOCS_DIR..'/'..frontmatter.slug, html)
			end
		end
	end

	generate_index_page(frontmatter_list, index_template)
end

function Actions:generate()
	lfs.mkdir(DirectoriesType.PAGES_DIR)
	lfs.mkdir(DirectoriesType.DOCS_DIR)

	local config = io.open(DirectoriesType.CONFIG_FILE, 'w')

	local config_content = [[
	{
		"title": "My Blog",
		"theme": "default"
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

function Actions:build(theme)
	check_directories()

	local index_template, post_template = Themes.load_theme(theme)
	process_markdown_files(index_template, post_template)
end

return Actions
