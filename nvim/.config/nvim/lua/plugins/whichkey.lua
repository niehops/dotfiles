vim.pack.add({
	"https://github.com/folke/which-key.nvim",
})

require("which-key").setup({})
require("which-key").add({
	{ "<leader>f", group = "Telescope" },
	{ "<leader>h", group = "Git Hunks" },
	{ "<leader>c", group = "Clear" },
	{ "<leader>p", group = "Path" },
	{ "<leader>t", group = "Toggle" },
	{ "<leader>r", group = "Refactor" },
})
