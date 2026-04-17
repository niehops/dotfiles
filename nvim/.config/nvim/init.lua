vim.opt.termguicolors = true

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type

vim.opt.signcolumn = "yes" -- always show a sign column
vim.opt.colorcolumn = "100" -- show a column at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- single line command line
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 0 -- do not hide markup
vim.opt.concealcursor = "" -- do not hide cursorline in markup
vim.opt.lazyredraw = true -- do not redraw during macros
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.vim/undodir")
if
	vim.fn.isdirectory(undodir) == 0 -- create undodir if nonexistent
then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- do create an undo file
vim.opt.undodir = undodir -- set the undo directory
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 900 -- timeout duration
vim.opt.ttimeoutlen = 50 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if outside of neovim
vim.opt.autowrite = false -- do not auto-save

vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- no error sounds
vim.opt.backspace = "indent,eol,start" -- better backspace behaviour
vim.opt.autochdir = false -- do not autochange directories
vim.opt.iskeyword:append("-") -- include - in words
vim.opt.path:append("**") -- include subdirs in search
vim.opt.selection = "inclusive" -- include last char in selection
vim.opt.mouse = "" -- disable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "utf-8" -- set encoding

-- vim.opt.guicursor =
-- "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"  -- cursor blinking and settings

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

-- ============================================================================
-- AUTOCMD
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- STATUSLINE (Custom DevOps Design)
-- ============================================================================

local function sl_branch()
	local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
	if branch ~= "" then
		return "  " .. branch .. " " -- nf-dev-git_branch
	end
	return ""
end

local function sl_diagnostics()
	local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local out = ""
	if err > 0 then
		out = out .. " " .. err .. " " -- fa-times-circle
	end
	if warn > 0 then
		out = out .. " " .. warn .. " " -- fa-exclamation-triangle
	end
	return out
end

local function sl_filetype()
	local ft = vim.bo.filetype
	-- Explicitly targeting ONLY the requested DevOps stack languages
	local icons = {
		bash = "", -- terminal
		lua = "", -- lua
		yaml = "", -- file alt
		json = "", -- json
		toml = "", -- settings
		terraform = "󱁢", -- terraform
		hcl = "󱁢", -- terraform
		dockerfile = "", -- docker
		markdown = "", -- markdown
		html = "", -- html
		css = "", -- css
		javascript = "", -- js
		typescript = "", -- ts
		python = "", -- python
		java = "", -- java
		awk = "", -- terminal
		go = "", -- go
		ruby = "", -- ruby
		bicep = "", -- cloud
		helm = "", -- ship
		sh = "", -- terminal
		zsh = "", -- terminal
	}

	if ft == "" then
		return ""
	end

	return (icons[ft] or "") .. " " .. string.upper(ft)
end

local function sl_mode()
	local mode = vim.fn.mode()
	local modes = {
		n = "   NORMAL",
		i = "   INSERT",
		v = "  VISUAL",
		V = "  V-LINE",
		["\22"] = "  V-BLOCK",
		c = "  COMMAND",
		s = "  SELECT",
		S = "  S-LINE",
		["\19"] = "  S-BLOCK",
		R = "  REPLACE",
		r = "  REPLACE",
		["!"] = "  SHELL",
		t = "  TERMINAL",
	}
	return " " .. (modes[mode] or mode) .. " "
end

_G.sl_branch = sl_branch
_G.sl_diagnostics = sl_diagnostics
_G.sl_filetype = sl_filetype
_G.sl_mode = sl_mode

vim.cmd([[
  highlight StatusLineMode gui=bold,reverse cterm=bold,reverse
]])

local function setup_custom_statusline()
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		callback = function()
			-- Active window layout: Mode | Git Branch | Path === Diagnostics | FileType | Pos
			vim.opt_local.statusline = table.concat({
				"%#StatusLineMode#",
				"%{v:lua.sl_mode()}",
				"%#StatusLine#",
				" ", -- explicit space between mode block and git branch
				"%{v:lua.sl_branch()}",
				"  %f ",
				"%=", -- Align right boundary
				"%{v:lua.sl_diagnostics()}",
				" %{v:lua.sl_filetype()} ",
				" %l:%c ",
			})
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			-- Inactive window layout: Path === FileType | Pos
			vim.opt_local.statusline = " %f %= %{v:lua.sl_filetype()}  %l:%c "
		end,
	})
end

setup_custom_statusline()

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================
vim.pack.add({
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/which-key.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end
packadd("nvim-treesitter")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("gitsigns.nvim")
packadd("which-key.nvim")
-- LSP
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

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

require("which-key").setup({})
require("which-key").add({
	{ "<leader>f", group = "FZF" },
	{ "<leader>h", group = "Git Hunks" },
	{ "<leader>c", group = "Clear" },
	{ "<leader>p", group = "Path" },
	{ "<leader>t", group = "Toggle" },
	{ "<leader>r", group = "Refactor" },
})

require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

-- ============================================================================
-- GITSIGNS
-- ============================================================================
require("gitsigns").setup({
	signs = {
		add = { text = "▏" }, -- ▏
		change = { text = "▐" }, -- ▐
		delete = { text = "◦" }, -- ◦
		topdelete = { text = "◦" }, -- ◦
		changedelete = { text = "●" }, -- ●
		untracked = { text = "○" }, -- ○
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl` (Highlights the line number gently)
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl` (Highlights entire line background)
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff` (Highlights exact inner-line changes)
	current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local opts = function(desc)
			return { buffer = bufnr, desc = desc }
		end

		-- Navigation between hunks
		vim.keymap.set("n", "]h", gs.next_hunk, opts("Next hunk"))
		vim.keymap.set("n", "[h", gs.prev_hunk, opts("Prev hunk"))

		-- Stage / Reset
		vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts("Stage hunk"))
		vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts("Reset hunk"))
		vim.keymap.set("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, opts("Stage selected hunk"))
		vim.keymap.set("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, opts("Reset selected hunk"))
		vim.keymap.set("n", "<leader>hS", gs.stage_buffer, opts("Stage buffer"))
		vim.keymap.set("n", "<leader>hR", gs.reset_buffer, opts("Reset buffer"))

		-- Undo stage & Preview
		vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, opts("Undo stage hunk"))
		vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts("Preview hunk"))

		-- Blame
		vim.keymap.set("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, opts("Blame line (full)"))

		-- Diff
		vim.keymap.set("n", "<leader>hd", gs.diffthis, opts("Diff this"))
	end,
})

-- ============================================================================
-- DIAGNOSTIC_SIGNS
-- ============================================================================
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	---@diagnostic disable-next-line: duplicate-set-field
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- ============================================================================
-- TREESITTER
-- ============================================================================
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
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
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
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

pcall(setup_treesitter)

-- ============================================================================
-- MASON
-- ============================================================================
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- ============================================================================
-- BLINK.CMP (Completion)
-- ============================================================================
require("blink.cmp").setup({
	keymap = {
		preset = "super-tab",
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<C-space>"] = { "show", "hide" },
		["<C-e>"] = { "cancel", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	signature = { enabled = true },
})

-- ============================================================================
-- LSP CONFIG
-- ============================================================================
local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Setup basic DevOps LSPs
local servers = {
	ansiblels = {},
	terraformls = {},
	yamlls = {
		settings = {
			yaml = {
				keyOrdering = false,
			},
		},
	},
	jsonls = {},
	taplo = {},
	html = {},
	cssls = {},
	ts_ls = {},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
	pyright = {},
	jdtls = {},
	awk_ls = {},
	gopls = {},
	bashls = {},
	helm_ls = {},
	docker_compose_language_service = {},
	marksman = {},
	bicep = {},
	solargraph = {},
}

for server, config in pairs(servers) do
	config.capabilities = capabilities
	if vim.lsp.config then
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	else
		lspconfig[server].setup(config)
	end
end

-- ============================================================================
-- EFM (Formatting & Linting)
-- ============================================================================
local ansible_lint = require("efmls-configs.linters.ansible_lint")
local yamllint = require("efmls-configs.linters.yamllint")
local prettier = require("efmls-configs.formatters.prettier")
local terraform_fmt = require("efmls-configs.formatters.terraform_fmt")
local eslint = require("efmls-configs.linters.eslint")
local stylua = require("efmls-configs.formatters.stylua")
local black = require("efmls-configs.formatters.black")
local flake8 = require("efmls-configs.linters.flake8")
local goimports = require("efmls-configs.formatters.goimports")
local shellcheck = require("efmls-configs.linters.shellcheck")
local shfmt = require("efmls-configs.formatters.shfmt")
local markdownlint = require("efmls-configs.linters.markdownlint")
local rubocop = require("efmls-configs.linters.rubocop")

local languages = {
	yaml = { yamllint, prettier },
	ansible = { ansible_lint },
	json = { prettier },
	terraform = { terraform_fmt },
	html = { prettier },
	css = { prettier },
	javascript = { eslint, prettier },
	javascriptreact = { eslint, prettier },
	typescript = { eslint, prettier },
	typescriptreact = { eslint, prettier },
	lua = { stylua },
	python = { flake8, black },
	go = { goimports },
	sh = { shellcheck, shfmt },
	bash = { shellcheck, shfmt },
	zsh = { shellcheck, shfmt },
	markdown = { markdownlint, prettier },
	ruby = { rubocop },
}

local efmls_config = {
	filetypes = vim.tbl_keys(languages),
	settings = {
		rootMarkers = { ".git/" },
		languages = languages,
	},
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
	capabilities = capabilities,
}

if vim.lsp.config then
	vim.lsp.config("efm", efmls_config)
	vim.lsp.enable("efm")
else
	lspconfig.efm.setup(efmls_config)
end

-- LSP Keymaps attached to active buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

-- Autoformat on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("AutoFormat", {}),
	callback = function(args)
		vim.lsp.buf.format({ bufnr = args.buf, async = false })
	end,
})
