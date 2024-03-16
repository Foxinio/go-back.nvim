-- main module file
local stack = require("go-back.stack")

---@class Config
---@field opt table
---@field __history_stack_instance Stack
---@field __future_stack_instance Stack
---@field __temporary_disable boolean
local config = {
  opt = {
		reuse_win = true,
		hook_events = { "BufHidden" },
		-- hook_events = { "BufHidden", "TabLeave" },
	},
	__history_stack_instance = nil,
	__future_stack_instance = nil,
	__temporary_disable = false,
}

---@class GoBackModule
local M = {}

---@type Config
M.config = config

local function callback(opts)
	if ! M.config.__temporary_disable then
		local buf = opts.buf
		local file = opts.file
		local str = "{ " .. buf .. ", " .. file .. "}"

		local left_buffer = { buf, file }
		if M.config.__history_stack_instance:top() ~= left_buffer then
			vim.api.nvim_echo({
				{ "Storing buffer:" },
				{ "buf: " .. buf },
				{ "file: " .. file },
			}, true, {})

			M.config.__future_stack_instance = stack:new()
			M.config.__history_stack_instance.push({ buf, file, str })
		else
			vim.api.nvim_echo({
				{ "Buffer already on top of stack:" },
				{ "buf: " .. buf },
				{ "file: " .. file },
			}, true, {})
		end
	end
end

---@param args Config
M.setup = function(args)
	-- create stack instance 
	local nessesary_config = {
		__history_stack_instance = stack:new(),
		__future_stack_instance = stack:new(),
		__temporary_disable = false,
	}

	-- here insert any default setting

  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  M.config = vim.tbl_deep_extend("force", M.config, nessesary_config)

	vim.api.nvim_create_augroup("GoBackPlugin", { clear = true })
	vim.api.nvim_create_autocmd(M.config.opt.hook_events, {
		group = "GoBackPlugin",
		desc = "Callback to store visited buffers as visited.",
		callback = callback,
	})
end

function change_buffer(buf)
 if M.config.opt.reuse_win then
		
	else

	end
end

M.go_back = function()
	local to_jump_to = M.config.__history_stack_instance:top()
	M.config.__temporary_disable = true
	change_buffer(to_jump_to)
	M.config.__future_stack_instance:push(to_jump_to)
	M.config.__history_stack_instance:pop()
	M.config.__temporary_disable = false
end

M.go_forward = function()
	local to_jump_to = M.config.__future_stack_instance:top()
	M.config.__temporary_disable = true
	change_buffer(to_jump_to)
	M.config.__history_stack_instance:push(to_jump_to)
	M.config.__future_stack_instance:pop()
	M.config.__temporary_disable = false
end

return M
