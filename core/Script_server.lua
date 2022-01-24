Script = {}

function Script.new(name, filename)
	local self = setmetatable({}, {__index = Script})
	self.name = name
	self.parent = resources[name]
	self.filename = filename
	self.events = {}
	self.cmds = {}
	self.timers = {}
	-- self.globals = {}
	self.keyBinds = {}
	replaceFuncs(self)
	return self
end

addEventHandler('onDebugMessage', resourceRoot, function(msg, type, file, lineNum)
	if msg:lower():match('%[server%]') then
		cancelEvent()
		outputDebugString(msg, 4, 155, 255, 255)
	end
	if type == 1 and file then
		local resName = file:match('%("(.*)",')
		local filename = file:match(', "(.*)"%)')
		if resName and filename then
			cancelEvent()
			outputDebugString(('ERROR: CoreMTA | %s/%s:%s: | %s'):format(resName, filename:gsub('\\', '/'), lineNum, msg), 4, 255, 0, 0)
		end
	end
end)

function Script.create(resName, filename, buffer)
	buffer = ([[local _S = Script.new("%s", "%s") local f = function() %s return _S end
	f()
	return _testScript, _S]]):format(resName, filename, buffer, '%d+', '%s', '%s', '%s', '%s', resName, filename)

	f = fileCreate('temp.lua')
	f:write(buffer, f.size)
	f:close()

	local scriptLoader, err = loadstring(buffer)
	if err then
		error(err, 0)
	end

	setfenv(scriptLoader, resources[resName].globals)

	return scriptLoader
end

function Script.get(resName, filename)
	return resources[resName].server[filename]
end

function Script:unload()
	for i=1, #self.events do
		removeEventHandler(unpack(self.events[i]))
		self.events[i] = nil
	end

	for i=1, #self.cmds do
		removeCommandHandler(unpack(self.cmds[i]))
		self.cmds[i] = nil
	end

	for i=1, #self.keyBinds do
		unbindKey(unpack(self.keyBinds[i]))
		self.keyBinds[i] = nil
	end

	for i=1, #self.timers do
		if isTimer(self.timers[i]) then
			self.timers[i]:destroy()
		end
		self.timers[i] = nil
	end

	setmetatable(self, nil)
end