local M = {}
local ns_id = vim.api.nvim_create_namespace("NormTrainer")

local levels = {
	{
		msg = "Goal: Append a semicolon to the end of every line.",
		start = { "const x = 1", "let y = 2", "var z = 3" },
		win = { "const x = 1;", "let y = 2;", "var z = 3;" },
	},
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
		msg = "Goal: Convert each variable name to uppercase.",
		start = { "username", "password", "token" },
		win = { "USERNAME", "PASSWORD", "TOKEN" },
	},
	{
		msg = "Goal: Turn every line that is a TODO into an empty one.",
		start = { "apple", "//TODO add error_log", "banana", "//TODO glaze vim", "cherry" },
		win = { "apple", "", "banana", "", "cherry" },
	},
	{
		msg = "Goal: Capitalize the first letter and add a period at the end.",
		start = { "hello", "vim", "norm" },
		win = { "Hello.", "Vim.", "Norm." },
	},
	{
		msg = 'Goal: Turn each name into a print("name") statement.',
		start = { "Alice", "Bob", "Charlie" },
		win = { 'print("Alice")', 'print("Bob")', 'print("Charlie")' },
	},
	{
		msg = "Goal: Transform list to 'Self-Assignment' (x = x).",
		start = { "width", "height", "depth" },
		win = { "width = width", "height = height", "depth = depth" },
	},
	{
		msg = "Goal: Remove the file extension from each filename.",
		start = { "report.pdf", "image.png", "data.csv" },
		win = { "report", "image", "data" },
	},
	{
		msg = "Goal: The 'Incognito' level. Replace every character with a '*'.",
		start = { "password123", "secret_key", "admin_login" },
		win = { "***********", "**********", "***********" },
	},
	{
		msg = "Goal: Clean up this messy list by removing the trailing whitespace.",
		start = { "item1   ", "item2 ", "item3      " },
		win = { "item1", "item2", "item3" },
	},
	{
		msg = "Goal: Swap 'true' to 'false' on every line.",
		start = { "is_active = true", "is_admin = true", "is_valid = true" },
		win = { "is_active = false", "is_admin = false", "is_valid = false" },
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
	{
		msg = "Goal: Surround numbers with square brackets.",
		start = { "x = 10", "y = 42", "z = 7" },
		win = { "x = [10]", "y = [42]", "z = [7]" },
	},
	{
		msg = "Goal: The 'JSON-ify' level. Turn 'key=value' into '\"key\": \"value\"'.",
		start = { "id=101", "name=admin", "role=user" },
		win = { '"id": "101"', '"name": "admin"', '"role": "user"' },
	},
	{
		msg = "Goal: Swap the order of these CSV values (first,last -> last,first).",
		start = { "John,Doe", "Jane,Smith", "Bob,Vance" },
		win = { "Doe,John", "Smith,Jane", "Vance,Bob" },
	},
	{
		msg = 'Goal: Wrap each key-value pair as setOption("key", "value") call.',
		start = { "theme=dark", "lang=en", "mode=auto" },
		win = { 'setOption("theme", "dark")', 'setOption("lang", "en")', 'setOption("mode", "auto")' },
	},
}

local current_level = 1

local function checkWinCondition(buf, header_height, level)
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		buffer = buf,
		callback = function()
			vim.defer_fn(function()
				local start_line = header_height
				local end_line = header_height + #level.start
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

local function setUpBuffer(buf, level)
	local header = {
		"--- LEVEL " .. current_level .. " ---",
		"--- Press enter on this line to [SKIP] this level ---",
		"--- Press enter on this line to [GOBACK] one level ---",
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
	vim.api.nvim_buf_add_highlight(buf, ns_id, "Special", 1, 0, -1) -- skip
	vim.api.nvim_buf_add_highlight(buf, ns_id, "Special", 2, 0, -1) -- go back
	vim.api.nvim_buf_add_highlight(buf, ns_id, "NonText", #header + #level.start, 0, -1)

	return #header
end

local function handle_navigation(buf)
	vim.keymap.set("n", "<CR>", function()
		local line = vim.api.nvim_get_current_line()

		if line:find("%[SKIP%]") then
			if current_level < #levels then
				current_level = current_level + 1
				vim.schedule(M.start_game)
			else
				print("You are already at the last level.")
			end
		elseif line:find("%[GOBACK%]") then
			if current_level > 1 then
				current_level = current_level - 1
				vim.schedule(M.start_game)
			else
				print("You are already at the first level.")
			end
		end
	end, { buffer = buf, silent = true })
end

function M.start_game()
	local level = levels[current_level]
	if not level then
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)

	local header_height = setUpBuffer(buf, level) -- for checking just specific part in winCondition

	handle_navigation(buf) -- for skipping and going back levels

	checkWinCondition(buf, header_height, level)

	vim.api.nvim_set_current_buf(buf)
	print(level.msg)
end

return M
