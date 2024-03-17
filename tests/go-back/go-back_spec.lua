local plugin = require("go-back")

vim.api.nvim_create_augroup("TestingGroup", { clear = true })
vim.api.nvim_create_autocmd("TestingHook", {
	group = "TestingGroup",
})

local function assert_top(buf, file)
	local history_top = plugin.config.past_stack.top()
	assert(history_top.buf == buf)
	assert(history_top.file == file)
end

local function assert_current_buffer(buf, file)
	local current_buffer = vim.api.nvim_get_current_buf()
	assert(current_buffer == buf)
	assert(vim.api.nvim_buf_get_name(current_buffer) == file)
end

local function assert_empty()

end

describe("standard", function()
	local history = plugin.config.past_stack
	local future = plugin.config.future_stack

  it("should trigger correct event", function()
		plugin.setup({
			default_mappings = false,
			-- hook_events = { "TestingHook" },
			excesive_logging = true
		})
		-- setup two file
		local file1 = "file1"
		local file2 = "file2"

		-- edit one of them to start scenario and save file1 buffer id
		vim.api.nvim_command("edit " .. file1)
		vim.api.nvim_command("sleep 100m")
		local file1buf = vim.api.nvim_get_current_buf()

		-- edit second file, and save file2 buffer id
		vim.api.nvim_command("edit " .. file2)
		vim.api.nvim_command("sleep 100m")
		local file2buf = vim.api.nvim_get_current_buf()

		-- and first file should be registered on the history stack
		assert_top(file1buf, file1)

		-- edit first file again and 
		vim.api.nvim_command("edit " .. file1)
		vim.api.nvim_command("sleep 100m")

		-- second filed should be registered in history top
		assert_top(file2buf, file2)

		-- trigger GoBack command and confirm its effects
		plugin.go_back()
		vim.api.nvim_command("sleep 100m")
		assert_current_buffer(file2buf, file2)

		-- trigger GoBack command again and again confirm its effects
		plugin.go_back()
		vim.api.nvim_command("sleep 100m")
		assert_current_buffer(file2buf, file2)

		-- confirm history stack is empty
		assert_empty()
  end)

  it("should not insert buffer already on top onto stack", function()
		plugin.setup({
			default_mappings = false,
			hook_events = { "TestingHook" },
			excesive_logging = true
		})
		local file1 = "file1"
		-- local file2 = "file2"

		-- edit one of them to start scenario and save file1 buffer id
		vim.api.nvim_command("edit " .. file1)
		vim.api.nvim_command("sleep 100m")
		local file1buf = vim.api.nvim_get_current_buf()

		vim.api.nvim_command("doautocmd TestingHook")
		vim.api.nvim_command("sleep 100m")
		assert_top(file1buf, file1)

		vim.api.nvim_command("doautocmd TestingHook")
		vim.api.nvim_command("sleep 100m")
		assert_top(file1buf, file1)

		plugin.go_back()
		vim.api.nvim_command("sleep 100m")
		assert_empty()
	end)
end)
