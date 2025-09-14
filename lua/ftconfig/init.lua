local M = {}
M.filetypes = {}
M.ftdir = vim.fn.stdpath("config") .. "/lua/ftconfig"

if vim.fn.isdirectory(M.ftdir) == 0 then
	vim.fn.mkdir(M.ftdir, "p")
end

local augroup = vim.api.nvim_create_augroup("ftconfig", { clear = true })

---@class FTConformSpec
---@field use string[]
---@field formatters? table<string, conform.FileFormatterConfig>

---@class FTKeymapOptions
---@field [1] string # mode
---@field [2] string # lhs
---@field [3] string|fun(args:vim.api.keyset.create_autocmd.callback_args) # rhs
---@field [4]? vim.keymap.set.Opts

---@class FTSpec
---@field indent? integer
---@field conform? FTConformSpec
---@field keymaps? FTKeymapOptions[]
---@field lsp? table<LSPName, any>

---Loads the config for the given filename
---@param filename string
function M.load_file(filename)
	local ft = vim.fn.fnamemodify(filename, ":r")
	table.insert(M.filetypes, ft)
	local mod = "ftconfig." .. ft
	---@type FTSpec?
	local spec = require(mod)
	if spec == nil or type(spec) == "boolean" then
		return
	end
	local ok, err = pcall(function()
		local indent = spec.indent or 4
		vim.api.nvim_create_autocmd("FileType", {
			group = augroup,
			pattern = ft,
			callback = function()
				vim.opt_local.shiftwidth = indent
				vim.opt_local.tabstop = indent
				vim.opt_local.softtabstop = indent
			end,
		})
		for _, k in ipairs(spec.keymaps or {}) do
			vim.api.nvim_create_autocmd("FileType", {
				pattern = ft,
				callback = function(args)
					local opts = k[4] or {}
					opts.buffer = args.buf
					vim.keymap.set(k[1], k[2], k[3], opts)
				end,
			})
		end
		if spec.conform then
			local conform_opts =
				{ formatters_by_ft = { [ft] = spec.conform.use }, formatters = spec.conform.formatters }
			require("conform").setup(conform_opts)
		end
	end)
	if not ok then
		local msg = string.format("%s ftconfig error: %s", ft, err)
		vim.notify(msg, vim.log.levels.ERROR)
	end
end

---creates a new filetype and begins to edit it
---@param ft string
function M.edit_filetype(ft)
	local filename = M.ftdir .. "/" .. ft .. ".lua"
	if vim.fn.filereadable(filename) == 0 then
		table.insert(M.filetypes, ft)
	end
	vim.cmd("edit " .. M.ftdir .. "/" .. ft .. ".lua")
end

function M.setup()
	for _, file in ipairs(vim.fn.readdir(M.ftdir)) do
		if file:match("%.lua") then
			M.load_file(file)
		end
	end
	require("ftconfig.commands")
end

return M
