local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function prioritize_filetypes(fts, current)
	local pri, mid, rest = {}, {}, {}
	local m = {}
	for _, filetype in ipairs(require("ftconfig").filetypes) do
		m[filetype] = true
	end
	for _, ft in ipairs(fts) do
		if ft == current then
			table.insert(pri, { display = "󰓎 " .. ft, value = ft })
		elseif m[ft] then
			table.insert(mid, { display = " " .. ft, value = ft })
		else
			table.insert(rest, { display = "󰙴 " .. ft, value = ft })
		end
	end
	vim.list_extend(pri, mid)
	vim.list_extend(pri, rest)
	return pri
end

local function filetype_picker(opts)
	opts = opts or {}
	local current = vim.bo.filetype
	local filetypes = vim.fn.getcompletion("", "filetype")
	filetypes = prioritize_filetypes(filetypes, current)

	pickers
		.new(opts, {
			prompt_title = "FTConfig",
			finder = finders.new_table({
				results = filetypes,
				entry_maker = function(entry)
					return {
						value = entry.value,
						display = entry.display,
						ordinal = entry.value,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						require("ftconfig").edit_filetype(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

return require("telescope").register_extension({
	exports = {
		ftconfig = filetype_picker,
	},
})
