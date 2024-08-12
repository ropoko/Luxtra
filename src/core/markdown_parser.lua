local MarkdownParser = {}

function MarkdownParser:parse(markdown_text)
	local html = ""

	-- TODO: handle frontmatter

	local lines = self:split_lines(markdown_text)

	for _, line in pairs(lines) do
		html = html .. self:parse_line(line)
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

-- TODO: create a different module for parsing
function MarkdownParser:parse_line(line)
	-- this represents: 1 or more #, followed by 1 or more spaces, followed by 1 or more characters
	-- e.g.: "### Header" will match and return "###" and "Header"
	local header_level, header_text = line:match("^(#+)%s+(.+)")

	if header_level then
		return string.format("<h%d>%s</h%d>\n", #header_level, header_text, #header_level)
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

	return text
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
