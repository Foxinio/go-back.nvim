---@class Stack
---@field push function
---@field pop function
---@field top function
---@field to_string function
---@field try_push function
local Stack = {}
Stack.__index = Stack


---Returns new instance of Stack container
---@return Stack
function Stack.new()
	local ret = {
		len = 0,
		[0] = {"guardian"}
	}

	---Pushes new element on top of the stack
	ret.push = function(to_push)
		ret[ret.len+1] = {
			value = to_push
		}
		ret.len = ret.len+1
	end

	ret.try_push = function(to_push)
		if ret.len == 0 or not vim.deep_equal(ret.top(), to_push) then
			ret.push(to_push)
		end
	end

	---Returns value on top of the stack
	---@generic T
	---@return T
	ret.top = function()
		if ret[ret.len] then
			return ret[ret.len].value
		end
		return nil
	end

	---Removes value from the stack and returns it
	---@generic T
	---@return T
	ret.pop = function()
		if ret.len > 0 then
			local poped = ret[ret.len]
			ret[ret.len] = nil
			ret.len = ret.len-1
			return poped.value
		else
			return nil
		end
	end

	ret.to_string = function()
		local iter = ret.len
		local s = "[\n"
		while iter > 0 do
			s = s .. vim.inspect(ret[iter].value) .. "\n"
			iter = iter - 1
		end
		return s .. "]\n"
	end

	ret.is_empty = function()
		return ret.len == 0
	end

	return ret
end


return Stack
