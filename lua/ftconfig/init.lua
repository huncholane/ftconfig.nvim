local M = {}

M.ftdir = vim.fn.stdpath("config") .. "/lua/ftconfig"

if vim.fn.isdirectory(M.ftdir) == 0 then
	vim.fn.mkdir(M.ftdir, "p")
end

local augroup = vim.api.nvim_create_augroup("ftconfig", { clear = true })

function M.files()
	return vim.fn.readdir(M.ftdir, function(file)
		return file:match("%.lua$") and 1 or 0
	end)
end

---@class FTConformSpec
---@field use string[]
---@field formatters? conform.FileFormatterConfig[]

---@class FTSpec
---@field indent? integer
---@field conform? FTConformSpec
---@field lsp? table<LSPName, any>

---builds config for filetype
---@param ft string
function M.setup_ft(ft)
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

function M.setup()
	for _, file in ipairs(M.files()) do
		M.setup_ft(vim.fn.fnamemodify(file, ":r"))
	end
end

return M
