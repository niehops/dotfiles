vim.pack.add({
	{
		src = "https://github.com/catppuccin/nvim",
		name = "catppuccin",
	},
})

require("catppuccin").setup({
	flavour = "auto",
	transparent_background = true,
	float = { transparent = true },
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
	},
})

vim.cmd.colorscheme("catppuccin-nvim")
