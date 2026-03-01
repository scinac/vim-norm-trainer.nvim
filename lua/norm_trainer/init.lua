local M = {}
local ns_id = vim.api.nvim_create_namespace("NormTrainer")

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
	{
		msg = "Goal: Turn this list into a JSON-style array (add quotes and a comma).",
		start = { "id", "name", "email" },
		win = { '"id",', '"name",', '"email",' },
	},
	{
		msg = "Goal: Comment out only the lines containing 'TODO'. (Hint: :g/pattern/norm)",
		start = { "var x = 10", "TODO: fix bug", "var y = 20", "TODO: add tests" },
		win = { "var x = 10", "// TODO: fix bug", "var y = 20", "// TODO: add tests" },
	},
	{
		msg = "Goal: Convert Markdown list to a task list (Change '*' to '* [ ]').",
		start = { "* Buy milk", "* Clean room", "* Code plugin" },
		win = { "* [ ] Buy milk", "* [ ] Clean room", "* [ ] Code plugin" },
	},
	{
		msg = "Goal: Delete the first word on every line.",
		start = { "Error: System crash", "Info: All good", "Warn: Low battery" },
		win = { "System crash", "All good", "Low battery" },
	},
	{
		msg = "Goal: Capitalize the first letter and add a period at the end.",
		start = { "hello", "vim", "norm" },
		win = { "Hello.", "Vim.", "Norm." },
	},
	{
		msg = "Goal: Swap 'true' to 'false' on every line.",
		start = { "is_active = true", "is_admin = true", "is_valid = true" },
		win = { "is_active = false", "is_admin = false", "is_valid = false" },
	},
	{
		msg = "Goal: Delete everything after the first word.",
		start = { "Key: Value", "User: scinac", "Repo: vim-norm" },
		win = { "Key:", "User:", "Repo:" },
	},
	{
		msg = "Goal: Duplicate every line.",
		start = { "repeat", "me" },
		win = { "repeat", "repeat", "me", "me" },
	},
	{
		msg = "Goal: Turn these into HTML tags.",
		start = { "Home", "About", "Contact" },
		win = { "<li>Home</li>", "<li>About</li>", "<li>Contact</li>" },
	},
	{
		msg = 'Goal: Turn each fruit into a fruits.add("fruit") call.',
		start = { "apple", "banana", "cherry" },
		win = { 'fruits.add("apple")', 'fruits.add("banana")', 'fruits.add("cherry")' },
	},
}

local current_level = 1

function M.start_game()
	local level = levels[current_level]
	local buf = vim.api.nvim_create_buf(false, true)

	local header = {
		"--- LEVEL " .. current_level .. " ---",
		level.msg,
		"",
		"EDIT BELOW:",
		"--------------------",
	}
	local footer = {
		"--------------------",
		"GOAL:",
	}

	for _, line in ipairs(level.win) do
		table.insert(footer, line) -- appending the winning state to footer
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, header)
	vim.api.nvim_buf_set_lines(buf, #header, #header, false, level.start)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, footer)

	vim.api.nvim_buf_add_highlight(buf, ns_id, "Comment", 0, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns_id, "Special", 1, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns_id, "NonText", #header + #level.start, 0, -1)

	vim.api.nvim_set_current_buf(buf)
	print(level.msg)

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		buffer = buf,
		callback = function()
			vim.defer_fn(function()
				local start_line = #header
				local end_line = #header + #level.start
				local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false) -- just the edited part not the header footer stuff

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
