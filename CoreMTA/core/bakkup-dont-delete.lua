addEvent('onResPreStart', true)
addEvent('onResStart', true)
addEvent('onClientResPreStart', true)
addEvent('onClientResStart', true)
addEvent('sendFile', true)
addEvent('sendScript', true)

Res = {}
local resources = {}

function Res.new(name, serverRoot)
	local self = setmetatable({}, {__index = Res})
	self.name = name
	self.client = {}
	self.showCursor = false
	self.globals = {}
	self.elements = {}
	self.files = {}
	self.resourceRoot = serverRoot
	self.globals['resourceRoot'] = self.resourceRoot
	setmetatable(self.globals, {__index = _G})
	return self
end

function Res:loadClientScript(fileName, buffer)
	local script, err = Script.create(self.name, fileName, buffer)
	print(err)
	-- local suc = pcall(fnc)
	local suc, script = pcall(function()
		return script()()
	end)
	print(suc)

	if not suc then
		local _, lastChar, lineNum = err:find(':(%d+):')
		err = err:sub(lastChar+2)
		error(('%s/%s:%s: %s'):format(name, fileName, lineNum, err), 0)
	else
		-- return script
		-- return type(fnc) == 'function' and fnc()
	end

	if not script then error('error loading file', fileName, 'in', self.name) end
	setfenv(script, self.globals)
	script = script
	script.globals = globals
	
	triggerEvent('onClientResStart', root)
	triggerServerEvent('onResStart', root)
	self.client[fileName] = script
end

function Res:unload()
	for fileName, script in pairs(self.client) do
		script:unload()
	end
	iprint('[client] deleting elements in resource: ', self.name, self.elements)
	for i=1, #self.elements do
		self.elements[i]:destroy()
	end
end

addEventHandler('sendFile', root, function(file)
	local res = resources[file.resourceName]

	if not file.url then
		local f = File(file.path)
		f:write(file.buf)
		f:close()
		res.files[file.path] = true
	else
		Script.download(file.url, function(data, err)
			if err > 0 then return end
			local path = split(file.path, '/')
			local f = File('scripts/'..file.resourceName..'/'..path[#path])
			f:write(data)
			f:close()
			res.files[file.path] = true
		end)
	end		
end)

addEventHandler('sendScript', root, function(script)
	local res = resources[script.resourceName]
	if script.buf then
		res:loadClientScript(script.path, script.buf)
	end
end)

function Res.start(name, serverRoot, files)
	local res = Res.new(name, serverRoot)
	resources[name] = res
	if files[2] then
		for i=1, #files[2] do
			resources[name].files[files[2][i]] = true
		end
	else
		files[2] = {}
	end
	triggerEvent('onClientResPreStart', root, res)
	triggerServerEvent('onClientResPreStart', root, name, files)
end
addEvent('onResPreStart', true)
addEventHandler('onResPreStart', root, Res.start)

function onResStart()
	triggerServerEvent('onClientJoin', resourceRoot)
end
addEventHandler('onClientResourceStart', resourceRoot, onResStart)

function Res.stop(name)
	local res = resources[name]
	if res then
		res:unload()
		resources[name] = nil
		for i=1, 2 do collectgarbage() end
	end
end
addEvent('onResStop', true)
addEventHandler('onResStop', root, Res.stop)

function Res.downloadScripts(urls, callback)
	local progress = {}
    local completed = {}

    for i=1, #urls do
		local url = urls[i]		
        Script.download(url, function(data, err)
            progress[i] = {url=url, data=data, filename=filename, err=err}

            for j=1, #urls do
                local prog = progress[j]
                if prog then
                    completed[j] = progress[j]
                end
            end

            if #completed == #urls then
                callback(completed)
            end
        end)
    end
end

function checkCursor()
	local r = Res.getAll()
	for name, resor in pairs(r) do
		if resor.showCursor == true then
			return false
		end
	end
	showCursor(false)
end
setTimer(checkCursor, 50, 0)

function Res.inspect(name)
	local name = name
	local res = resources[name]
	if res then
		iprint('client', res)
	end
end

function Res.getRoot(name)
	return resources[name].globals
end

function Res.getAll()
	return resources
end

Script = {}

function Script.new(name, fileName)
	local self = setmetatable({}, {__index = Script})
	self.name = name
	self.root = resources[name]
	self.fileName = fileName
	self.events = {}
	self.cmds = {}
	self.timers = {}
	self.dffs = {}
	self.cols = {}
	self.globals = {}
	return self
end

function Script:event(name, root, func, ...)
	addEventHandler(name, root, func, ...)
	table.insert(self.events, {name, root, func})
end

function Script:timer(callback, interval, times, ...)
	local timer = setTimer(callback, interval, times, ...)
	table.insert(self.timers, timer)
	return timer
end

function Script:cmd(cmd, callback, restricted)
	addCommandHandler(cmd, callback, restricted or false, false)
	table.insert(self.cmds, {cmd, callback})
end

function Script:loadCOL(...)
	local col = engineLoadCOL(arg[2])
	if col then
		engineReplaceCOL(col, arg[1])
		table.insert(self.cols, {id = arg[1], col = col})
	end
end

function Script:loadDFF(...)
	local dff = engineLoadDFF(arg[2])
	if dff then
		engineReplaceModel(dff, arg[1])
		table.insert(self.dffs, {id = arg[1], dff = dff})
	end
end

function Script:cursor(bool)
	if type(bool) == 'boolean' then
		if bool then
			resources[self.name].showCursor = bool
			return showCursor(bool)
		end
	end
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
	
	for i=1, #self.cols do
		engineRestoreCOL(self.cols[i].id)
		self.cols[i] = nil
	end
	
	for i=1, #self.dffs do
		engineRestoreModel(self.dffs[i].id)
		self.dffs[i] = nil
	end

	clearTable(self)
end

function Script.download(url, callback)
	if not url then return end
	requestBrowserDomains({url}, true, function()
		if isBrowserDomainBlocked(url, true) then
			Script.download(url, callback)
		else
			fetchRemote(url, callback)
		end
	end)
end

function Script:replaceFuncs()
	local elemFuncs = {'Ped', 'createPed', 'Vehicle', 'createVehicle', 'Object', 'createObject', 'Marker', 'createMarker', 'Sound', 'playSound', 'playSound3D', 'Pickup', 'createPickup', 'createColCircle', 'ColShape.Circle', 'createColCuboid', 'ColShape.Cuboid', 'createColPolygon', 'ColShape.Polygon', 'createColRectangle', 'ColShape.Rectangle', 'createColSphere', 'ColShape.Sphere', 'createColTube', 'ColShape.Tube', 'createBlip', 'Blip', 'createBlipAttachedTo', 'Blip.createAttachedTo', 'createRadarArea', 'RadarArea', 'Sound', 'Sound3D', 'playSFX', 'playSFX3D', 'createProjectile', 'Projectile', 'createTeam', 'Team.create', 'guiCreateFont', 'GuiFont', 'guiCreateBrowser', 'GuiBrowser', 'guiCreateButton', 'GuiButton', 'guiCreateCheckBox', 'GuiCheckBox', 'guiCreateComboBox', 'GuiComboBox', 'guiCreateEdit', 'GuiEdit', 'guiCreateGridList', 'GuiGridList', 'guiCreateMemo', 'GuiMemo', 'guiCreateProgressBar', 'GuiProgressBar', 'guiCreateRadioButton', 'GuiRadioButton', 'guiCreateScrollBar', 'GuiScrollBar', 'guiCreateScrollPane', 'GuiScrollPane', 'guiCreateStaticImage', 'GuiStaticImage', 'guiCreateTabPanel', 'GuiTabPanel', 'guiCreateTab', 'GuiTab', 'guiCreateLabel', 'GuiLabel', 'guiCreateWindow', 'GuiWindow', 'dxCreateTexture', 'DxTexture', 'dxCreateRenderTarget', 'DxRenderTarget', 'dxCreateScreenSource', 'DxScreenSource', 'dxCreateShader', 'DxShader', 'dxCreateFont', 'DxFont', 'createWeapon', 'Weapon', 'createEffect', 'Effect', 'Browser', 'createBrowser', 'createLight', 'Light', 'createSearchLight', 'SearchLight', 'createWater', 'Water'}
	for i=1, #elemFuncs do
		local origFunc = self.root.globals[elemFuncs[i]]
		self.root.globals[elemFuncs[i]] = function(...)
			local elem = origFunc(...)
			elem:setParent(self.root.resourceRoot)
			table.insert(self.root.elements, elem)
			return elem
		end
	end
end

function Script.create(name, fileName, buffer)
	local gt = {
		{'addCommandHandler', '_S:cmd'},
		{'addEventHandler', '_S:event'},
		{'setTimer', '_S:timer'},
		{'Timer', '_S:timer'},
		{'engineLoadCOL', 'engineReplaceCOL'},
		{'engineLoadModel', 'engineReplaceModel'},
		{'EngineCOL', 'engineReplaceCOL'},
		{'EngineDFF', 'engineReplaceModel'},
		{'col:replace', 'engineReplaceCOL'},
		{'dff:replace', 'engineReplaceModel'},
		{'engineReplaceCOL', '_S:loadCOL'},
		{'engineReplaceModel', '_S:loadDFF'},
		{'showCursor', '_S:cursor'},
		{'onClientResourceStart', 'onClientResStart'}
	}

	for i=1, #gt do
		buffer = buffer:gsub(unpack(gt[i]))
	end

	-- buffer = ([[
	-- 	local _main = function()
	-- 		local _S = Script.new("%s", "%s"); _S:replaceFuncs();
	-- 		local _content = function()
	-- 			%s
	-- 		end
	-- 		local suc = pcall()
	-- 		print(suc)
			
	-- 		return _S
	-- 	end
	-- 	return _main
	-- ]]):format(name, fileName, buffer)

	buffer = ('return function() local _S = Script.new("%s", "%s"); _S:replaceFuncs();\n %s\nreturn _S end'):format(name, fileName, buffer)

	local f = File('test.lua')
	f:write(buffer)
	f:close()

	local script, err = loadstring(buffer)
	print(script,err)
	return script, err
end

-- function Script.create(name, fileName, buffer)
-- 	local gt = {
-- 		{'addCommandHandler', '_S:cmd'},
-- 		{'addEventHandler', '_S:event'},
-- 		{'setTimer', '_S:timer'},
-- 		{'Timer', '_S:timer'},
-- 		{'engineLoadCOL', 'engineReplaceCOL'},
-- 		{'engineLoadModel', 'engineReplaceModel'},
-- 		{'EngineCOL', 'engineReplaceCOL'},
-- 		{'EngineDFF', 'engineReplaceModel'},
-- 		{'col:replace', 'engineReplaceCOL'},
-- 		{'dff:replace', 'engineReplaceModel'},
-- 		{'engineReplaceCOL', '_S:loadCOL'},
-- 		{'engineReplaceModel', '_S:loadDFF'},
-- 		{'showCursor', '_S:cursor'},
-- 		{'onClientResourceStart', 'onClientResStart'}
-- 	}
	
-- 	for fileName, loaded in pairs(resources[name].files) do
-- 		if loaded then
-- 			buffer = buffer:gsub(buffer, 'scripts/'..name..'/'..fileName)
-- 		end
-- 	end
	
-- 	for i=1, #gt do
-- 		buffer = buffer:gsub(unpack(gt[i]))
-- 	end
	
-- 	buffer = ('return function() local _S = Script.new("%s", "%s"); _S:replaceFuncs();\n %s\nreturn _S end'):format(name, fileName, buffer)
-- 	local f = File('test.txt')
-- 	f:write(buffer)
-- 	f:close()
-- 	local fnc, err = loadstring(buffer)
	
-- 	local status = testBuffer(fileName, fnc)

-- 	if status then
-- 		return fnc()
-- 	end
-- end

addCommandHandler('inspectres', function(...) if not arg[2] then return end Res.inspect(arg[2]) end)