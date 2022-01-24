function Script:addEventHandler(name, root, func, ...)
	addEventHandler(name, root, func, ...)
	table.insert(self.events, {name, root, func})
end

function Script:setTimer(...)
	local timer = setTimer(...)
	table.insert(self.timers, timer)
	return timer
end

function Script:addCommandHandler(cmd, callback, restricted)
	addCommandHandler(cmd, callback, restricted or false, false)
	table.insert(self.cmds, {cmd, callback})
end

function Script:bindKey(...)
	bindKey(...)
	table.insert(self.keyBinds, arg)
end

function Script:getResourceRootElement(resource)
	local res
	if type(resource) == 'string' then
		res = resources[resource]
	elseif type(resource) == 'table' then
		res = resource
	end
	return res.root
end

function Script:getRootElement()
	return self.parent.root
end

function Script:getThisResource()
   return self.parent
end