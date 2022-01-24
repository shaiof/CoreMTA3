-- Classes

-- Functions
function Script:addEventHandler(name, eventRoot, func, ...)
	addEventHandler(name, eventRoot, func, ...)
	table.insert(self.events, {name, eventRoot, func})
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

function Script:engineReplaceCOL(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local col = engineLoadCOL(path)
		if col then
			self.cols[#self.cols+1] = col
			engineReplaceCOL(col, arg[1])
		end
	end
end

function Script:engineReplaceModel(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local dff = engineLoadDFF(path)
		if dff then
			self.dffs[#self.dffs+1] = dff
			engineReplaceModel(dff, arg[1])
		end
	end
end

function Script:engineImportTXD(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local txd = engineLoadTXD(path)
		if txd then
			self.txds[#self.txds+1] = txd
			engineImportTXD(txd, arg[1])
		end
	end
end

function Script:showCursor(bool)
	if type(bool) == 'boolean' then
		if bool then
			resources[self.name].showCursor = bool
			return showCursor(bool)
		end
	end
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