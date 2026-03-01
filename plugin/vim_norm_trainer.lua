vim.api.nvim_create_user_command("NormGame", function()
	require("norm_trainer").start_game()
end, {})
