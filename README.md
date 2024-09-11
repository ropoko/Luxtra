# Luxtra
A static site generator written in Lua. It processes Markdown files and generates a static blog website.

Inspired by Nextra.

Check a working example [here](https://github.com/ropoko/test-luxtra).

# Install
```bash
luarocks install luxtra
```

# Usage
- generate the placeholder
`luxtra generate`

- build the html files
`luxtra build`

## Configuration
In the file `luxtra.config.json`, you can change the `title` of your blog and change to a different `theme`.

## How it works
- you need to write your posts in the `pages/` folder using markdown
- the `luxtra build` command will generate a folder `docs` (so you can deploy using github pages)

# Themes
Currently there's only one theme (default).

Themes inspired by [dead simple sites](https://deadsimplesites.com/).


## TODO
- [x] read/process markdown files
- [x] define a header model for each file (frontmatter)
- [x] use info from frontmatter to create a index page
- [x] add themes
- - [x] light/dark mode
- [x] add cli tools
- [x] publish on luarocks
- [ ] add code highlight
- [ ] add about page
- [ ] add tags support
