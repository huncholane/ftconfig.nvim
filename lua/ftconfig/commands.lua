vim.api.nvim_create_user_command("FT", function(args)
	require("ftconfig").edit_filetype(args.fargs[1])
end, {
	nargs = 1,
	desc = "Edit or create config for given filetype",
	complete = function(lead, _, _)
		local options = vim.fn.getcompletion("", "filetype")
		return vim.tbl_filter(function(item)
			return vim.startswith(item, lead)
		end, options)
	end,
})
