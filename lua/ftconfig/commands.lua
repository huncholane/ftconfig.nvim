vim.api.nvim_create_user_command("FT", function(args)
	if args.fargs[1] then
		require("ftconfig").edit_filetype(args.fargs[1])
	else
		require("ftconfig").edit_filetype(vim.bo.filetype)
	end
end, {
	nargs = "*",
	desc = "Edit or create config for given filetype",
	complete = function(lead, _, _)
		local options = vim.fn.getcompletion("", "filetype")
		return vim.tbl_filter(function(item)
			return vim.startswith(item, lead)
		end, options)
	end,
})
