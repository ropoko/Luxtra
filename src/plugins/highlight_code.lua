local HIGHLIGHT_JS_VERSION = "11.11.1"
local CDN_BASE = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/" .. HIGHLIGHT_JS_VERSION

return {
	name = "highlight_code",

	head_injections = function(self, ctx, frontmatter)
		local theme = self.opts.theme or "default"
		return {
			css = { CDN_BASE .. "/styles/" .. theme .. ".min.css" },
			js = { CDN_BASE .. "/highlight.min.js" },
			inline_js = { "hljs.highlightAll();" }
		}
	end
}
