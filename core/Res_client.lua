Res = {}
resources = {}

local joined = false

function Res.new(name, serverRoot)
	local self = setmetatable({}, {__index = Res})
	self.name = name
	self.client = {}
	self.showCursor = false
	self.files = {}
	self.scripts = {}
	self.root = serverRoot
	self.globals = {}
	--self.globals.root = serverRoot
	self.loaded = false
	setmetatable(self.globals, {__index = _G})

	resources[name] = self
	return self
end

function Res.start(resName, serverRoot, files, tempResourceRoot)
	-- create res instance (we don't start it yet)
	local res = Res.new(resName, serverRoot)
	-- handle scripts
	local resScripts = files[1]
	if resScripts then
		for i=1, #resScripts do
			res.client[resScripts[i]] = true
		end
	else
		resScripts = {}
	end

	-- handle files
	local resFiles = files[2]
	if resFiles then
		for i=1, #resFiles do
			res.files[resFiles[i]] = true
		end
	else
		resFiles = {}
	end

	-- check file downloads
	if not tempResourceRoot then
		resources[resName].loaded = true
		triggerServerEvent('getClientScriptsBuffer', root, resName)
	else
		local downloadedFiles = {}

		local onDownloadComplete = function(filename, success, resource)
			print('['..resName..']: Downloaded: '..filename..' Success: '..tostring(success))

			if not success then
				error(('Error downloading file %s in %s'):format(filename, resName), 0)
			end

			if res.files[filename] then
				table.insert(downloadedFiles, filename)

				if #downloadedFiles == #resFiles then
					print('All client files downloaded')
					resources[resName].loaded = true
					triggerServerEvent('getClientScriptsBuffer', root, resName)
				end

				if File.exists('resources/'..resName..'/'..filename) then
					File.delete('resources/'..resName..'/'..filename)
				end
				File.copy(':CORE_'..resName..'/'..filename, 'resources/'..resName..'/'..filename)
			end
		end

		addEventHandler('onClientFileDownloadComplete', tempResourceRoot, onDownloadComplete)
		res.downloadEvent = {'onClientFileDownloadComplete', tempResourceRoot, onDownloadComplete}
	end
end
addEvent('onResPreStart', true)
addEventHandler('onResPreStart', root, Res.start)

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

function Res.inspect(name)
	local name = name
	local res = resources[name]
	if res then
		iprint('client', res)
	end
end

function Res.getRoot(name)
	return resources[name].resourceRoot, resources[name].globals
end

function Res.get(name)
	return resources[name]
end

function Res.getAll()
	return resources
end

function Res:unload()
	for i=1, #self.scripts do
		self.scripts[i]:unload()
	end
	print('[Client] unloading scripts')
end

function Res:areAllClientFilesLoaded()
	for key, file in pairs(self.files) do
		if not file then
			return false
		end
	end
	return true
end

function areAllResourcesLoaded()
	for k, v in pairs(resources) do
		if not v.loaded then
			return false
		end
	end
	return true
end

function import(name)
	return resources[name] and setmetatable({}, {
		__index = function(self, key)
			return resources[name].globals[key]
		end,
		__newindex = function(self, key, val)
			resources[name].globals[key] = val
		end,
		__call = function(self, key, ...)
			return resources[name].globals[key](...)
		end
	}) or error("Can't import resource '"..name.."', make sure it's started.", 2)
end

addEvent('loadClientScripts', true)
addEventHandler('loadClientScripts', root, function(resourceName, scripts)
	local res = resources[resourceName]

	for i=1, #scripts do
		local scriptLoader = Script.create(res.name, scripts[i].name, base64Decode(scripts[i].buffer)) --[client] does parsing and Script stuff

		if not scriptLoader then error('[Client] error loading file', scripts[i].name) end

		local testScript, script = scriptLoader()
		res.scripts[#res.scripts+1] = script

		print('[Client] '..scripts[i].name..' loaded ('..i..'/'..#scripts..')')
	end
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
	triggerServerEvent('clientRequestStart', resourceRoot) --[client] Tells server to start tasks for this client.
end)

function checkCursor()
	local r = Res.getAll()
	for name, resor in pairs(r) do
		if resor.showCursor == true then
			return false
		end
	end
	showCursor(false)
end
setTimer(checkCursor, 50, 0) --bad practice..

addCommandHandler('inspectres', function(...) if not arg[2] then return end Res.inspect(arg[2]) end)


