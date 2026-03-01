local M = {}

local levels = {
	{
		msg = "Goal: Add '- ' to the start of every line.",
		start = { "apple", "banana", "cherry" },
		win = { "- apple", "- banana", "- cherry" },
	},
	{
		msg = "Goal: Wrap each word in double quotes.",
		start = { "one", "two", "three" },
		win = { '"one"', '"two"', '"three"' },
	},
}

local current_level = 1

function M.start_game()
	local level = levels[current_level]

	local buf = vim.api.nvim_create_buf(false, true) -- create empty for now may include level message at the start

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, level.start)
	vim.api.nvim_set_current_buf(buf)

	print(level.msg)

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		buffer = buf,
		callback = function()
			vim.defer_fn(function()
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

				if vim.deep_equal(lines, level.win) then
					print("Level " .. current_level .. " cleared!")
					current_level = current_level + 1

					if levels[current_level] then
						M.start_game()
					else
						print("You finished all Levels!")
					end
				end
			end, 10)
		end,
	})
end

return M
