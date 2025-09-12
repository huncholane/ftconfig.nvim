local M = {}

M.ftdir = vim.fn.stdpath("config") .. "/lua/ftconfig"
M.filetypes = {}

if vim.fn.isdirectory(M.ftdir) == 0 then
	vim.fn.mkdir(M.ftdir, "p")
end

local augroup = vim.api.nvim_create_augroup("ftconfig", { clear = true })

---@class FTConformSpec
---@field use string[]
---@field formatters? conform.FileFormatterConfig[]

---@class FTSpec
---@field indent? integer
---@field conform? FTConformSpec
---@field lsp? table<LSPName, any>

---Loads the config for the given filename
---@param filename string
function M.load_file(filename)
	local ft = vim.fn.fnamemodify(filename, ":r")
	table.insert(M.filetypes, ft)
	local mod = "ftconfig." .. ft
	local ok, spec = pcall(require, mod)
	if not ok then
		return
	end
	---@cast spec FTSpec?
	if not spec then
		return
	end
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

	if spec.conform then
		local conform_opts = { formatters_by_ft = { [ft] = spec.conform.use }, formatters = spec.conform.formatters }
		require("conform").setup(conform_opts)
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
