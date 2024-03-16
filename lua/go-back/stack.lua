---@class Stack
local Stack = {}
Stack.__index = Stack


---Returns new instance of Stack container
---@return Stack
function Stack:new()
		local ret = {
			root = {
				prev = nil,
				value = nil,
			}
		}
		setmetatable(ret, self)
		self.__index = self
		return ret
end

---Pushes new element on top of the stack
function Stack:push(to_push)
	local node = {
		prev = self.root,
		value = to_push,
		}
	self.root = node
end

---Returns value on top of the stack
---@generic T
---@return T
function Stack:top()
	return self.root.value
end

---Removes value from the stack and returns it
---@generic T
---@return T
function Stack:pop()
	local ret = self.root.value
	self.root = self.root.prev
	return ret
end

function Stack:to_string()
	local iter = self.root
	local s = "["
	while iter ~= nil do
		--if iter is table use printTable otherwise use print
		s = s .. vim.inspect(iter.value) .. "\n"
		iter = iter.prev
	end
	return s .. "]"
end


return Stack
