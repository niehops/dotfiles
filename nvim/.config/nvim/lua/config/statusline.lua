local branch_cache = ""
local function refresh_branch_cache()
	local cwd = (vim.uv and vim.uv.cwd()) or vim.fn.getcwd()
	local out = vim.fn.systemlist({ "git", "-C", cwd, "branch", "--show-current" })
	if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
		branch_cache = out[1]
	else
		branch_cache = ""
	end
end

local function sl_branch()
	if branch_cache ~= "" then
		return "  " .. branch_cache .. " " -- nf-dev-git_branch
	end
	return ""
end

local diagnostics_cache = {}
local function refresh_diagnostics_cache(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local err, warn = 0, 0
	for _, d in ipairs(vim.diagnostic.get(bufnr)) do
		if d.severity == vim.diagnostic.severity.ERROR then
			err = err + 1
		elseif d.severity == vim.diagnostic.severity.WARN then
			warn = warn + 1
		end
	end

	local out = ""
	if err > 0 then
		out = out .. " " .. err .. " " -- fa-times-circle
	end
	if warn > 0 then
		out = out .. " " .. warn .. " " -- fa-exclamation-triangle
	end
	diagnostics_cache[bufnr] = out
end

local function sl_diagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	return diagnostics_cache[bufnr] or ""
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

refresh_branch_cache()
refresh_diagnostics_cache(vim.api.nvim_get_current_buf())

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained", "ShellCmdPost" }, {
	group = augroup,
	desc = "Refresh git branch cache for statusline",
	callback = refresh_branch_cache,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter" }, {
	group = augroup,
	desc = "Refresh diagnostics cache for statusline",
	callback = function(args)
		refresh_diagnostics_cache(args.buf)
	end,
})

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
