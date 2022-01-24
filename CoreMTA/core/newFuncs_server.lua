-- -- Classes
-- new_File = File
-- new_FileClass = getmetatable(File)

-- function new_File.new(_, resName, otherResName, fileName)
--     -- iprint(resName, otherResName, fileName)
--     local self = setmetatable({}, {__index = new_FileClass})
--     local path
--     if otherResName and fileName then
--         path = 'resources/'..otherResName..'/'..fileName
--     elseif otherResName and not fileName then
--         path = 'resources/'..resName..'/'..otherResName
--     end

--     if path then
--         self.file = File(path)
-- 		return self.file
--     end

--     return false
-- end
-- new_FileClass.__call = new_File.new
-- setmetatable(new_File, new_FileClass)



-- this is serverside, you should go to newFuncs_client to run gui stuff

-- local newClassFuncs = {
--     new_File = {
--         __call = new_File.new,
--         class = new_File,
--         oldClass = File,
--         metatable = new_FileClass,
--         methodsNoArgs = {'close', 'flush', 'getPos', 'getSize', 'isEOF'},
--         methodsOptionalArgs = {'read'},
--         methodsRequiredArgs = {'setPos', 'write'},
--         staticFunctions = {'copy', 'delete', 'exists', 'rename'}
--     }
-- }

-- for class, data in pairs(newClassFuncs) do
--     if class == 'new_File' then
--         local selfData = 'file'
--     end

--     for i=1, #data.methodsNoArgs do
--         local method = data.methodsNoArgs[i]
--         data.metatable[method] = function(self, ...) self[selfData][method](self, ...) end
--     end

--     for j=1, #data.methodsOptionalArgs do
--         local method = data.methodsOptionalArgs[j]
--         data.metatable[method] = function(self, ...) if arg[1] then self[selfData][method](self, ...) else self[selfData][method](self) end end
--     end

--     for l=1, #data.methodsRequiredArgs do
--         local method = data.methodsRequiredArgs[l]
--         data.metatable[method] = function(self, ...) if arg[1] then self[selfData][method](self, ...) end end
--     end

--     for u=1, #data.staticFunctions do
--         local func = data.staticFunctions[u]
--         data.class[func] = data.oldClass[func]
--     end

--     data.metatable.__call = data.__call

--     setmetatable(data.class, data.metatable)
-- end

-- Functions
-- function Script:fileGetPath(file)
--     local path = fileGetPath(file)
--     path:gsub('resources/', '')
--     return path
-- end

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