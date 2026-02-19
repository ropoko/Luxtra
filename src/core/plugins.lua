local Plugins = {
	loaded = {},
	config = {}
}

function Plugins.load(config)
	Plugins.loaded = {}
	Plugins.config = config.plugins or {}

	for name, opts in pairs(Plugins.config) do
		local ok, plugin = pcall(require, 'luxtra.plugins.' .. name)

		if not ok then
			print(string.format('[luxtra] Warning: failed to load plugin "%s": %s', name, plugin))
		else
			plugin.opts = type(opts) == 'table' and opts or {}
			plugin.name = plugin.name or name
			table.insert(Plugins.loaded, plugin)
		end
	end
end

local RESULT_INDEX = {
	before_page = 3,       -- frontmatter
	transform_markdown = 2, -- raw_markdown
	transform_html = 2,    -- html
}

function Plugins.emit(hook_name, ...)
	local args = { ... }
	local result_idx = RESULT_INDEX[hook_name]

	for _, plugin in ipairs(Plugins.loaded) do
		local fn = plugin[hook_name]

		if type(fn) == 'function' then
			local ok, result = pcall(fn, plugin, table.unpack(args))

			if not ok then
				print(string.format('[luxtra] Plugin "%s" error in %s: %s', plugin.name, hook_name, result))
			elseif result ~= nil and result_idx then
				args[result_idx] = result
			end
		end
	end

	return result_idx and args[result_idx] or args[1]
end

function Plugins.emit_merge(hook_name, initial, ...)
	local result = initial
	local args = { ... }

	for _, plugin in ipairs(Plugins.loaded) do
		local fn = plugin[hook_name]

		if type(fn) == 'function' then
			local ok, extra = pcall(fn, plugin, table.unpack(args))

			if not ok then
				print(string.format('[luxtra] Plugin "%s" error in %s: %s', plugin.name, hook_name, extra))
			elseif type(extra) == 'table' then
				for k, v in pairs(extra) do
					result[k] = v
				end
			end
		end
	end

	return result
end

function Plugins.emit_collect(hook_name, ...)
	local collected = { css = {}, js = {}, inline_js = {} }
	local args = { ... }

	for _, plugin in ipairs(Plugins.loaded) do
		local fn = plugin[hook_name]

		if type(fn) == 'function' then
			local ok, injections = pcall(fn, plugin, table.unpack(args))

			if not ok then
				print(string.format('[luxtra] Plugin "%s" error in %s: %s', plugin.name, hook_name, injections))
			elseif type(injections) == 'table' then
				for _, href in ipairs(injections.css or {}) do
					table.insert(collected.css, href)
				end
				for _, src in ipairs(injections.js or {}) do
					table.insert(collected.js, src)
				end
				for _, code in ipairs(injections.inline_js or {}) do
					table.insert(collected.inline_js, code)
				end
			end
		end
	end

	return collected
end

function Plugins.render_head_injections(injections)
	local parts = {}
	for _, href in ipairs(injections.css or {}) do
		table.insert(parts, string.format('<link rel="stylesheet" href="%s">', href))
	end
	for _, src in ipairs(injections.js or {}) do
		table.insert(parts, string.format('<script src="%s"></script>', src))
	end
	for _, code in ipairs(injections.inline_js or {}) do
		table.insert(parts, string.format('<script>%s</script>', code))
	end
	return table.concat(parts, "\n\t")
end

return Plugins
