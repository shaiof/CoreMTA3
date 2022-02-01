if not isObjectInACLGroup('resource.'..getResourceName(getThisResource()), aclGetGroup('Admin')) then error(getResourceName(getThisResource())..' needs to be added to admin acl before it can run!', 3) end
addEvent('onResPreStart', true)
addEvent('onResStart', true)
addEvent('onClientResPreStart', true)
addEvent('onClientResStart', true)

Res = {}
resources = {}
Settings = {}
startQueue = {}

function Res.new(name)
    local self = setmetatable({}, {__index = Res})
    self.name = name
    self.client = {}
    self.clientFiles = {}
    self.server = {}
    self.serverFiles = {}
    self.serverScripts = {}
    self.meta = {}
    self.globals = {}
    self.elements = {}
    self.files = {}
    self.root = Element('resource', name)
    self.globals.resourceRoot = self.root
    setmetatable(self.globals, {__index = _G})
    return self
end

function Res.start(resName, addToQueue)
    if resources[resName] then
        if addToQueue then
            startQueue[resName] = true
            return true
        end
        return print('[Server] (!) '.."resource '"..resName.."' already started.")
    end

    local meta = Res.getMeta(resName)

    if not meta then
        return print('[Server] '.."no meta found for resource '"..resName.."'")
    end

    local res = Res.new(resName)
    resources[resName] = res

    res.meta = meta
    res.info = meta.info or {}

    res.info.name, res.info.author, res.info.version, res.info.description, res.info.type, res.info.gamemodes = res.info.name or resName, res.info.author or 'CoreMTA', res.info.version or '0.1', res.info.description or '', res.info.type or '', res.info.gamemodes or ''

    if meta.server then
        for i, v in pairs(meta.server) do
            if v:match('%.lua$') then
                res.server[#res.server+1] = v
            else
                res.serverFiles[#res.serverFiles+1] = v
            end
        end
    end

    if meta.client then
        for i, v in pairs(meta.client) do
            if v:match('%.lua$') then
                res.client[#res.client+1] = v
            else
                res.clientFiles[#res.clientFiles+1] = v
            end
        end
    end

    for i=1, #res.serverFiles do
        res.files[res.serverFiles[i]] = true
    end

    Res.loadServer(resName, res.server)

    -- create Temp resource for clientfiles
    if #res.clientFiles > 0 then
        res.tempResource = res:createTempResource()
        local suc = startResource(res.tempResource)
        
        if not suc then
            error('Error loading tempResource: '..resName..' Reason: '..getResourceLoadFailureReason(res.tempResource))
        end

        print('[Server] started temp resource', res.tempResource.name, suc)
    end

    triggerClientEvent('onResPreStart', root, resName, res.root, {res.client, res.clientFiles}, res.tempResource and res.tempResource.rootElement)

    updateResourcesList(resName, res.clientFiles)

    print('[Server] '..resName..' started')
    return true
end

addEventHandler('onResourceStop', root, function(res)
    if res.name:find('CORE_') then
        local resName = res.name:sub(6)

        -- clean up
        resources[resName] = nil
        for _=1, 2 do collectgarbage() end
        print('[Server] '..resName..' has been stopped.')

        if startQueue[resName] then
            Timer(function()
                startQueue[resName] = nil
                Res.start(resName) --? should we make a start queue?
            end, 100, 1)            
        end
    else -- if CoreMTA stops
        if res == getThisResource() then
            for name in pairs(resources) do
                Res.stop(name, true) -- true to prevent client events being triggered
            end
        end
    end
end)

function Res:createTempResource()
    local tempResName = 'CORE_'..self.name

    local tempResource = getResourceFromName(tempResName)

    if tempResource then
        local cachedFilelist = getResourceCachedFilelist(self.name)
        for i=1, #cachedFilelist do
            if fileExists('resources/'..tempResName..'/'..cachedFilelist[i]) then
                fileDelete('resources/'..tempResName..'/'..cachedFilelist[i])
            end
        end
        if fileExists('resources/'..tempResName..'/client.lua') then
            fileDelete('resources/'..tempResName..'/client.lua')
        end
    else
        tempResource = Resource(tempResName, '[temp]')
        refreshResources(true)
    end

    local cfContent = 'addEventHandler("onClientResourceStart", resourceRoot, function()\n'
    cfContent = cfContent..'Timer(function()'
    local mfContent = '<meta>\n    <oop>true</oop>\n    <script src="client.lua" type="client" cache="true"/>\n'
    for i=1, #self.clientFiles do
        cfContent = cfContent..'    downloadFile("'..self.clientFiles[i]..'")\n'
        mfContent = mfContent..'    <file src="'..self.clientFiles[i]..'" download="false"/>\n'
        fileCopy('resources/'..self.name..'/'..self.clientFiles[i], ':'..tempResName..'/'..self.clientFiles[i], true)
    end
    cfContent = cfContent..'end, 1, 1)\n'
    cfContent = cfContent..'end)'
    mfContent = mfContent..'</meta>'

    local cf = fileCreate(':'..tempResName..'/client.lua')
    cf:write(cfContent)
    cf:close()

    local mf = fileCreate(':'..tempResName..'/meta.xml')
    mf:write(mfContent)
    mf:close()

    refreshResources(false, tempResource)

    return tempResource
end

function Res.stop(name, coreStop)
    local name = name
    local res = resources[name]
    if not res then return end

    res:unload()

    if #res.client > 0 and not coreStop then
        triggerClientEvent(root, 'onResStop', root, name)
    end

    -- stop tempResource
    if res.tempResource and res.tempResource.state == 'running' then
        stopResource(res.tempResource)
        print('[server] stopping tempResource')
    else
        -- clean up
        resources[name] = nil
        for _=1, 2 do collectgarbage() end
        print('[Server] '..name..' has been stopped.')
    end
end

function Res.restart(name)
    local name = name
    if resources[name] then
        Res.stop(name)
        Res.start(name, true) -- true = (queue up and start when res stops)
    end
end

function Res.getMeta(name)
    local json = 'resources/'..name..'/meta.json'
    local xml = 'resources/'..name..'/meta.xml'

    if fileExists(json) then
        local f = File(json)
        local meta = fromJSON(f:read(f.size))
        f:close()
        return meta
    elseif fileExists(xml) then
        local meta = {info = {}, server = {}, client = {}}
        local node = xmlLoadFile(xml)
        local info = xmlFindChild(node, 'info', 0)

        if info then
            for k, v in pairs(xmlNodeGetAttributes(info)) do
                meta.info[k] = v
            end
        end

        local others = xmlNodeGetChildren(node)
        for i, o in pairs(others) do
            if xmlNodeGetName(o) == 'script' or xmlNodeGetName(o) == 'file' then
                local attr = xmlNodeGetAttributes(o)
                if attr.type == 'client' then
                    meta.client[#meta.client+1] = attr.src
                elseif attr.type == 'shared' then
                    meta.client[#meta.client+1] = attr.src
                    meta.server[#meta.server+1] = attr.src
                else
                    meta.client[#meta.client+1] = attr.src
                end
            end
        end
        xmlUnloadFile(node)

        return meta
    end
    return false
end

function Res.inspect(name)
    local res = resources[name]
    if res then
        iprint('server', res)
        local f = fileCreate('temp.txt')
        f:write(inspect(res))
        f:close()
    end
end

function Res.get(name)
    return resources[name]
end

function Res.getAll()
    return resources
end

function Res.loadServer(name, scripts) -- used to be Script.loadServer (??)
    for i=1, #scripts do
        local filename = scripts[i]
        local path = 'resources/'..name..'/'..filename
        if File.exists(path) then
            local f = File(path)
            local b = f:read(f.size)
            f:close()
            resources[name]:loadServerScript(filename, b)
            print('[Server] '..filename..' loaded ('..i..'/'..#scripts..')')
        end
    end

    -- trigger resourcestart events
    local res = resources[name]
    if res then
        for i=1, #res.serverScripts do
            for j=1, #res.serverScripts[i].events do
                if res.serverScripts[i].events[j][1] == 'onResourceStart' then
                    res.serverScripts[i].events[j][3](res)
                end
            end
        end
    end
end

function Res:loadServerScript(filename, buffer)
    local scriptLoader = Script.create(self.name, filename, buffer)
    if not scriptLoader then error('[Server] error loading file '..filename, 0) end

    local _, script = scriptLoader()
    self.serverScripts[filename] = script

    triggerEvent('onResStart', root)

    return true, nil
end

function Res:unload()
    for _, script in pairs(self.serverScripts) do
        script:unload()
    end
    self.root:destroy()
    print('[Server] unloading scripts')
end

function getResourceCachedFilelist(resName)
    local f = fileOpen('resources/resources.json')
    if f then
        local c = f:read(f.size)
        f:close()
        if #c > 0 then
            local list = fromJSON(c)
            if type(list) == 'table' then
                return list[resName]
            end
        end
    end
    return false
end

function updateResourcesList(name, clientFiles)
    local path = 'resources/resources.json'
    local list

    local oldFile = fileOpen(path)
    if oldFile then
        list = fromJSON(oldFile:read(oldFile.size)) or {}
        oldFile:close()
    end

    for resName in pairs(list) do
        if not fileExists('resources/'..resName..'/meta.xml') and
           not fileExists('resources/'..resName..'/meta.json') then
            list[resName] = nil
        end
    end

    list[name] = clientFiles
    
    fileDelete(path)
    local newFile = File(path)
    newFile:write(toJSON(list))
    newFile:close()
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

addEvent('getClientScriptsBuffer', true)
addEventHandler('getClientScriptsBuffer', root, function(resourceName)
    local res = resources[resourceName]

    if not res then
        error('No resource found '..resourceName)
    end

    local clientScripts = {}
    for i=1, #res.client do
        local path = 'resources/'..res.name..'/'..res.client[i]
        if fileExists(path) then
            local f = fileOpen(path)
            local buffer = f:read(f.size)
            clientScripts[i] = {name = res.client[i], buffer = base64Encode(buffer)} --[client] get each script files buffer, store it in a table, send it to client all at once
            f:close()
        end
    end
    triggerClientEvent(client, 'loadClientScripts', root, resourceName, clientScripts) --[client] sends client scripts buffers
end)

-- addEvent('onClientReady', true)
-- addEventHandler('onClientReady', root, function(resourceName)
--     triggerClientEvent(client, 'executeResource', root, resourceName) --[client] tells client to start the resource
-- end)

addEvent('clientRequestStart', true)
addEventHandler('clientRequestStart', root, function(resourceName)
    for name, res in pairs(resources) do
        if resourceName then
            if name == resourceName then
                triggerClientEvent(client, 'onResPreStart', root, name, res.root, {res.client, res.clientFiles}, res.tempResource and res.tempResource.rootElement)
                return
            end
        else
            triggerClientEvent(client, 'onResPreStart', root, name, res.root, {res.client, res.clientFiles}, res.tempResource and res.tempResource.rootElement)
        end
    end
end)

addCommandHandler('startres', function(...) if not arg[3] then return end Res.start(arg[3]) end)
addCommandHandler('stopres', function(...) if not arg[3] then return end Res.stop(arg[3]) end)
addCommandHandler('restartres', function(...) if not arg[3] then return end Res.restart(arg[3]) end)
addCommandHandler('inspectres', function(...) if not arg[3] then return end Res.inspect(arg[3]) end)

-- autostart
Timer(function()
    local f = fileOpen('settings.json')
    local buffer = fromJSON(f:read(f.size))
    f:close()
    Settings = buffer.settings
    for i=1, #buffer.autostart do
        Res.start(buffer.autostart[i])
    end
end, 200, 1)

