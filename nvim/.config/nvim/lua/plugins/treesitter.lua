vim.pack.add({
	-- { src = "https://github.com/reybits/ts-forge.nvim" },
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
})

-- require("ts-forge").setup({
-- 	auto_install = false,
-- 	ensure_installed = {
-- 		"bash",
--     "terraform",
--     "hcl",
--     "python",
--     "awk",
--     "bicep",
--     "helm",
-- 		"c",
-- 		"css",
-- 		"diff",
-- 		"go",
-- 		"gomod",
-- 		"gowork",
-- 		"gosum",
-- 		"graphql",
-- 		"html",
-- 		"javascript",
-- 		"jsdoc",
-- 		"json",
-- 		"json5",
-- 		"lua",
-- 		"luadoc",
-- 		"luap",
-- 		"markdown",
-- 		"markdown_inline",
-- 		"query",
-- 		"regex",
-- 		"toml",
-- 		"tsx",
-- 		"typescript",
-- 		"vim",
-- 		"vimdoc",
-- 		"yaml",
-- 	},
-- })
--
-- vim.api.nvim_create_autocmd("FileType", {
-- 	callback = function()
-- 		pcall(vim.treesitter.start)
-- 	end,
-- })

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"bash",
		"lua",
		"yaml",
		"json",
		"toml",
		"terraform",
		"hcl",
		"dockerfile",
		"markdown",
		"markdown_inline",
		"html",
		"css",
		"javascript",
		"typescript",
		"python",
		"java",
		"awk",
		"go",
		"regex",
		"ruby",
		"bicep",
		"helm",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local installed_set = {}
	for _, parser in ipairs(already_installed) do
		installed_set[parser] = true
	end
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not installed_set[parser] then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			pcall(vim.treesitter.start, args.buf)
		end,
	})
end

pcall(setup_treesitter)
