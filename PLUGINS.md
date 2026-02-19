# Plugins

Plugins extend Luxtra with additional features. Configure them in `luxtra.config.json` under the `plugins` key.

## Configuration

```json
{
	"title": "My Blog",
	"theme": "default",
	"plugins": {
		"highlight_code": { "theme": "github" },
		"another_plugin": { "option": "value" }
	}
}
```

Only plugins set on the config file are enabled.

## Plugin lifecycle hooks

| Hook                 | Args                                 | Return                                  | Description                                                     |
| -------------------- | ------------------------------------ | --------------------------------------- | --------------------------------------------------------------- |
| `before_build`       | `(ctx)`                              | -                                       | Called once at the start of the build                           |
| `after_build`        | `(ctx)`                              | -                                       | Called once at the end of the build                             |
| `before_page`        | `(ctx, file_path, frontmatter)`      | `frontmatter` or `false`                | Modify frontmatter or return `false` to skip the page           |
| `transform_markdown` | `(ctx, raw_markdown, frontmatter)`   | `raw_markdown`                          | Transform markdown before parsing                               |
| `transform_html`     | `(ctx, html, frontmatter)`           | `html`                                  | Transform HTML after parsing                                    |
| `template_context`   | `(ctx, frontmatter, parsed_content)` | `table`                                 | Add/override template variables (merged into the final context) |
| `head_injections`    | `(ctx, frontmatter)`                 | `{ css = {}, js = {}, inline_js = {} }` | Inject CSS/JS into the page `<head>`                            |

### Context object (`ctx`)

- `ctx.config` — full config from `luxtra.config.json`
- `ctx.theme` — theme name
- `ctx.docs_dir` — output directory (e.g. `docs`)
- `ctx.pages_dir` — pages directory (e.g. `pages`)

## Writing a plugin

Create a file in `src/plugins/<name>.lua` that returns a table:

```lua
return {
	name = "my_plugin",

	before_build = function(self, ctx)
		-- runs once at build start
	end,

	transform_html = function(self, ctx, html, frontmatter)
		return html  -- return modified HTML
	end,

	head_injections = function(self, ctx, frontmatter)
		return {
			css = { "https://example.com/style.css" },
			js = { "https://example.com/script.js" },
			inline_js = { "console.log('hi');" }
		}
	end,

	...
}
```

- `self` is the plugin table; use `self.opts` for plugin-specific options from config
- All hooks are optional; implement only what you need
