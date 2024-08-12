local io = require('io')

local FileUtils = {}

function FileUtils.file_exists(path)
	local file = io.open(path, 'r')
	return file ~= nil and io.close(file)
end

function FileUtils.get_file_content(file_name)
	local content = ""
	local file = io.open(file_name, 'r')

	if file then
		content = file:read('*a')
		io.close(file)
	end

	return content
end

function FileUtils.save_html_file(file_name, content)
	local new_filename = file_name:gsub('%.md$', '')

	local file = io.open(new_filename..'.html', 'w')

	if file then
		file:write(content)
		io.close(file)
	end
end

return FileUtils