-- vim.pack.add({
-- 	"https://github.com/creativenull/efmls-configs-nvim",
-- })
--
-- local f = setmetatable({}, {
-- 	__index = function(_, k)
-- 		return (require("efmls-configs.formatters." .. k))
-- 	end,
-- })
-- local l = setmetatable({}, {
-- 	__index = function(_, k)
-- 		return (require("efmls-configs.linters." .. k))
-- 	end,
-- })
--
-- local languages = {
-- 	yaml = { l.yamllint, f.prettier },
-- 	ansible = { l.ansible_lint },
-- 	json = { f.prettier },
-- 	terraform = { f.terraform_fmt },
-- 	html = { f.prettier },
-- 	css = { f.prettier },
-- 	javascript = { l.eslint, f.prettier },
-- 	javascriptreact = { l.eslint, f.prettier },
-- 	typescript = { l.eslint, f.prettier },
-- 	typescriptreact = { l.eslint, f.prettier },
-- 	lua = { f.stylua },
-- 	python = { l.flake8, f.black },
-- 	go = { f.goimports },
-- 	sh = { l.shellcheck, f.shfmt },
-- 	bash = { l.shellcheck, f.shfmt },
-- 	zsh = { l.shellcheck, f.shfmt },
-- 	markdown = { l.markdownlint, f.prettier },
-- 	ruby = { l.rubocop },
-- }
--
-- local efmls_config = {
-- 	filetypes = vim.tbl_keys(languages),
-- 	settings = { rootMarkers = { ".git/" }, languages = languages },
-- 	init_options = { documentFormatting = true, documentRangeFormatting = true },
-- }
--
-- setup_lsp("efm", efmls_config)
--
-- -- LSP Keymaps attached to active buffer
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
-- 	callback = function(ev)
-- 		local opts = { buffer = ev.buf }
-- 		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
-- 		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
-- 		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
-- 		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
-- 		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
-- 		vim.keymap.set("n", "<leader>f", function()
-- 			vim.lsp.buf.format({ async = true })
-- 		end, opts)
-- 	end,
-- })
--
-- -- Autoformat on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	group = vim.api.nvim_create_augroup("AutoFormat", { clear = true }),
-- 	callback = function(args)
-- 		vim.lsp.buf.format({ bufnr = args.buf, async = false })
-- 	end,
-- })

vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
})

require("conform").setup({
	format_on_save = {
		timeout_ms = 8000,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		graphql = { "prettierd" },
		go = { "goimports", "gofmt" },
		json = { "prettierd" },
		sql = { "sql_formatter" },
	},
	formatters = {
		sql_formatter = {
			prepend_args = { "--language", "postgresql" },
		},
	},
})

require("nvim-ts-autotag").setup()
