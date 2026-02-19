local MarkdownParser = {}

function MarkdownParser:escape_html(text)
	return text
			:gsub("&", "&amp;")
			:gsub("<", "&lt;")
			:gsub(">", "&gt;")
			:gsub('"', "&quot;")
end

function MarkdownParser:parse_code_blocks(text)
	local blocks = {}
	local block_index = 0

	local function replace_code(match_lang, match_content)
		block_index = block_index + 1
		local lang = (match_lang or ""):gsub("^%s*(.-)%s*$", "%1")
		local escaped = self:escape_html(match_content)
		local lang_attr = #lang > 0 and string.format(' class="language-%s"', lang) or ""
		local placeholder = string.format("__CODEBLOCK_%d__", block_index)
		blocks[placeholder] = string.format('<pre><code%s>%s</code></pre>', lang_attr, escaped)
		return placeholder
	end

	-- Match ```optional_lang\ncontent\n```
	local processed = text:gsub("```([^\n]*)\n(.-)```", replace_code)

	return processed, blocks
end

function MarkdownParser:parse(markdown_text, skip_frontmatter)
	local html = ""

	if markdown_text:sub(1, 3) == "---" then
		local _, end_index = markdown_text:find("\n%-%-%-\n", 4)

		if end_index then
			markdown_text = markdown_text:sub(end_index + 1)
		end
	end

	local processed, code_blocks = self:parse_code_blocks(markdown_text)
	local lines = self:split_lines(processed)

	for _, line in pairs(lines) do
		html = html .. self:parse_line(line)
	end

	for placeholder, block_html in pairs(code_blocks) do
		html = html:gsub("<p>" .. placeholder .. "</p>", block_html)
		html = html:gsub(placeholder, block_html)
	end

	return html
end

function MarkdownParser:split_lines(text)
	local lines = {}

	for line in text:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	return lines
end

function MarkdownParser:parse_image(line)
	-- images in markdown format
	-- e.g.: "![alt text](image.png)" will match and return "alt text" and "image.png"
	local alt_text, image_url = line:match("^!%[(.-)%]%((.-)%)")

	if alt_text and image_url then
		return string.format("<img src=\"%s\" alt=\"%s\" />\n", image_url, alt_text)
	end

	-- images in html format
	-- e.g.: "<img src="image.png" alt="alt text" />" will match and return
	image_url, alt_text = line:match("^<img src=\"(.-)\" alt=\"(.-)\" />")
	if alt_text and image_url then
		return string.format("<img src=\"%s\" alt=\"%s\" />\n", image_url, alt_text)
	end

	return nil
end

-- TODO: create a different module for parsing
function MarkdownParser:parse_line(line)
	-- this represents: 1 or more #, followed by 1 or more spaces, followed by 1 or more characters
	-- e.g.: "### Header" will match and return "###" and "Header"
	local header_level, header_text = line:match("^(#+)%s+(.+)")

	if header_level then
		return string.format("<h%d>%s</h%d>\n", #header_level, header_text, #header_level)
	end

	local image = self:parse_image(line)

	if image then
		return image
	end

	-- e.g.: "- Item 1" will match and return "Item 1"
	if line:match("^%s*-%s+") then
		return string.format("<li>%s</li>\n", line:match("^%s*-%s+(.+)"))
	end

	line = self:parse_inline(line)

	return string.format("<p>%s</p>\n", line)
end

function MarkdownParser:parse_inline(text)
	-- Bold
	text = text:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")

	-- Italic
	text = text:gsub("%*(.-)%*", "<em>%1</em>")

	-- Links
	text = text:gsub("%[(.-)%]%((.-)%)", "<a href=\"%2\">%1</a>")

	-- Images
	local image = self:parse_image(text)

	if image then
		return image
	end

	return text
end

function MarkdownParser:strip_frontmatter(markdown_text)
	if markdown_text:sub(1, 3) == "---" then
		local _, end_index = markdown_text:find("\n%-%-%-\n", 4)
		if end_index then
			return markdown_text:sub(end_index + 1)
		end
	end
	return markdown_text
end

function MarkdownParser:get_frontmatter(file_name, markdown_text)
	local frontmatter_text = ""

	if markdown_text:sub(1, 3) == "---" then
		local _, end_index = markdown_text:find("\n%-%-%-\n", 4)

		if end_index then
			frontmatter_text = markdown_text:sub(1, end_index)
			return self:parse_frontmatter(frontmatter_text)
		end
	end

	error("Frontmatter not found in file: " .. file_name)
end

--[[
	`frontmatter`
	---
	title: My First Post
	date: 2021-01-01
	description: This is my first post
	---

	@return {
		title = "My First Post",
		date = "2021-01-01"
	}
]]
function MarkdownParser:parse_frontmatter(frontmatter)
	local metadata = {}

	for line in frontmatter:gmatch("[^\r\n]+") do
		if line ~= "---" then
			local key, value = line:match("([^:]+):%s*(.+)")

			if key and value then
				local trimmed_key = key:gsub("^%s*(.-)%s*$", "%1")
				local trimmed_value = value:gsub("^%s*(.-)%s*$", "%1")

				if key == 'title' then
					metadata.slug = trimmed_value:gsub("%s+", "-"):lower()
				end

				metadata[trimmed_key] = trimmed_value
			end
		end
	end

	return metadata
end

return MarkdownParser
