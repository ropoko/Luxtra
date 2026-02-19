local io = require('io')
local os = require('os')
local lfs = require('lfs')
local etlua = require('etlua')

local json = require('luxtra.lib.json')
local MarkdownParser = require('luxtra.core.markdown_parser')
local DirectoriesType = require('luxtra.types.directories')
local FileUtils = require('luxtra.utils.file')
local Themes = require('luxtra.core.themes')
local Plugins = require('luxtra.core.plugins')

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

	FileUtils.save_html_file(DirectoriesType.DOCS_DIR .. '/index', html)
end

local function inject_head(template_html, injections_html)
	if #injections_html > 0 then
		return template_html:gsub("</head>", "\t" .. injections_html .. "\n</head>")
	end
	return template_html
end

local function process_markdown_files(index_template, post_template, ctx)
	local frontmatter_list = {}

	for file_name in lfs.dir(DirectoriesType.PAGES_DIR) do
		if file_name:match('%.md$') then
			local file_path = DirectoriesType.PAGES_DIR .. '/' .. file_name
			local markdown_content = FileUtils.get_file_content(file_path)

			if #markdown_content > 0 then
				local frontmatter = MarkdownParser:get_frontmatter(file_name, markdown_content)
				frontmatter = Plugins.emit('before_page', ctx, file_path, frontmatter)

				if frontmatter ~= false then
					table.insert(frontmatter_list, frontmatter)

					local raw_markdown = MarkdownParser:strip_frontmatter(markdown_content)
					raw_markdown = Plugins.emit('transform_markdown', ctx, raw_markdown, frontmatter)

					local html = MarkdownParser:parse(raw_markdown, true)
					html = Plugins.emit('transform_html', ctx, html, frontmatter)

					local template_ctx = Plugins.emit_merge('template_context', {
						title = frontmatter.title,
						date = frontmatter.date,
						description = frontmatter.description,
						content = html
					}, ctx, frontmatter, html)

					local head_injections = Plugins.emit_collect('head_injections', ctx, frontmatter)
					local injections_html = Plugins.render_head_injections(head_injections)
					local page_template = inject_head(post_template, injections_html)
					local render_html = etlua.compile(page_template)

					FileUtils.save_html_file(DirectoriesType.DOCS_DIR .. '/' .. frontmatter.slug, render_html(template_ctx))
				end
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

	Plugins.load(Actions.config)

	local ctx = {
		config = Actions.config,
		theme = theme,
		docs_dir = DirectoriesType.DOCS_DIR,
		pages_dir = DirectoriesType.PAGES_DIR
	}

	Plugins.emit('before_build', ctx)

	local index_template, post_template = Themes.load_theme(theme)
	process_markdown_files(index_template, post_template, ctx)

	Plugins.emit('after_build', ctx)
end

return Actions
