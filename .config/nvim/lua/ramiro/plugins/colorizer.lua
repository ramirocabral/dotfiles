local setup, colorizer = pcall(require, "colorizer")

if not setup then
	return
end

-- configure colorizer
colorizer.setup({
	"html",
	"css",
	html = { names = false }, -- Disable all nameless colors in html and css.
	css = { rgb_fn = true, names = false }, -- Enable parsing rgb(...) functions in css and disable all named colors.
})
