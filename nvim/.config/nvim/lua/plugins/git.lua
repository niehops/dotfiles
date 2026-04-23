vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/tpope/vim-fugitive" },
})

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
