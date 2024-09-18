-- main module file
local stack = require("go-back.stack")

---@class Config
---@field opt table
---@field past_stack Stack
---@field future_stack Stack
local config = {
  opt = {
		reuse_win = true,
		default_mappings = true,
		hook_events = { "BufHidden" },
		excesive_logging = false,
		-- hook_events = { "BufHidden", "TabLeave" },
	},
	past_stack = stack.new(),
	future_stack = stack.new(),
}



---@class GoBackModule
local M = {}

---@type Config
M.config = config

local function log(msg)
	if M.config.opt.excesive_logging then
		vim.api.nvim_echo(msg, true, {})
	end
end

local function do_store_pred(bufid, file)
	local top = M.config.past_stack.top()
	if top and (top.buf == bufid or top.file == file) then
			log({
				{ "Buffer already on top of stack:" },
				{ "buf: " .. bufid .. "\n"},
				{ "file: " .. file .. "\n"},
			})
		return false
	end

	local buftype = vim.api.nvim_get_option_value("buftype", {
		buf = bufid,
	})
	if buftype ~= "" then
		if buftype ~= "popup" and buftype ~= "nofile" then
			log({
				{ "Buffer is not file:" },
				{ "buf: " .. bufid .. "\n" },
				{ "file: " .. file .. "\n" },
				{ "buftype: " .. buftype .. "\n" },
			})
		end
		return false
	end

	log({
		{ "Storing buffer:\n" },
		{ "buf: " .. bufid .. "\n"},
		{ "file: " .. file .. "\n"},
	})

	return true
end


local function callback(opts)
	local buf = opts.buf
	local file = opts.file
	local str = "{ " .. buf .. ", " .. file .. "}"

	if do_store_pred(buf, file) then
		M.config.future_stack = stack:new()
		M.config.past_stack.push({ buf=buf, file=file, str=str })
	end
end

---@param args Config
M.setup = function(args)
	-- create stack instance 
	local nessesary_config = {
		past_stack = stack:new(),
		future_stack = stack:new(),
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

	vim.api.nvim_create_user_command("GoBack", M.go_back,
			{ desc = "Go back in buffere history" })
	vim.api.nvim_create_user_command("GoForward", M.go_forward,
			{ desc = "Go forward in buffere history" })
	vim.api.nvim_create_user_command("GoBackPrintHistories", M.print_stacks,
			{ desc = "Print stacks of go-back plugin (for debugging)" })

	if M.config.opt.default_mappings then
		vim.keymap.set("n", "<M-Left>", M.go_back,
			{ desc = "Go back in buffere history" })
		vim.keymap.set("n", "<M-Right>", M.go_forward,
			{ desc = "Go forward in buffere history" })
	end
end

local function change_buffer(buf)
	if buf == nil then
		log({{ "Nil buf detected" }})
		return false
	end
	if buf.buf == nil then
		log({{ "Nil buf.buf detected\n" },
				 { vim.inspect(buf)}})
		return false
	end

	if vim.api.nvim_buf_is_valid(buf.buf) then
		log({
			{ "Jumping to buffer:\n" },
			{ "buf: " .. buf.buf .. "\n" },
			{ "file: " .. buf.file .. "\n" },
		 })
		local winid = vim.fn.bufwinid(buf.buf)
		if M.config.opt.reuse_win and winid ~= -1 then
			vim.api.nvim_set_current_win(winid)
		else
			vim.api.nvim_set_current_buf(buf.buf)
		end
		return true
	else
		log({
			{ "Cannot jump to buffer:\n" },
			{ "buf: " .. buf.buf .. "\n" },
			{ "file: " .. buf.file .. "\n" },
			{ "Buffer invalid" }
			})
	end
	return false
end

M.go_back = function()
	local current_buf = {
		buf = vim.api.nvim_get_current_buf(),
		file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	}

	change_buffer(M.config.past_stack.top())
	M.config.past_stack.pop()

	if current_buf.buf ~= vim.api.nvim_get_current_buf() then
		M.config.future_stack.try_push(current_buf)
	end
end

M.go_forward = function()
	local current_buf = {
		buf = vim.api.nvim_get_current_buf(),
		file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	}

	change_buffer(M.config.future_stack.pop())

	if current_buf.buf ~= vim.api.nvim_get_current_buf() then
		M.config.past_stack.try_push(current_buf)
	end
end

M.print_stacks = function()
	vim.api.nvim_echo({
		{ "History stack: " },
		{ M.config.past_stack.to_string() },
		{ "Future stack: " },
		{ M.config.future_stack.to_string() },
	}, true, {})

end

return M
