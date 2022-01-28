function Script:addEventHandler(name, root, func, ...)
	local added = addEventHandler(name, root, func, ...)
	table.insert(self.events, {name, root, func})
    return added
end

function Script:setTimer(...)
	local timer = setTimer(...)
	table.insert(self.timers, timer)
	return timer
end

function Script:addCommandHandler(cmd, callback, restricted)
	local added = addCommandHandler(cmd, callback, restricted or false, false)
	table.insert(self.cmds, {cmd, callback})
    return added
end

function Script:bindKey(...)
	local bound = bindKey(...)
	table.insert(self.keyBinds, arg)
    return bound
end

function Script:fetchRemote(...)
    local request = fetchRemote(...)
    table.insert(self.remoteRequests, request)
    return request
end

function Script:callRemote(...)
    local request = callRemote(...)
    table.insert(self.remoteRequests, request)
    return request
end

function Script:getResourceRootElement(resourceOrName)
	local res
	if type(resourceOrName) == 'string' then
		res = resources[resourceOrName]
	elseif type(resource) == 'table' then
		res = resourceOrName
	end
	return res or self.parent.root
end

function Script:getRootElement()
	return root
end

function Script:getThisResource()
   return self.parent
end

function Script:showCursor(bool)
	if type(bool) == 'boolean' then
		if bool then
			resources[self.name].showCursor = bool
			return showCursor(bool)
		end
	end
end