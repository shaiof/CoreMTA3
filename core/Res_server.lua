if not isObjectInACLGroup('resource.'..getResourceName(getThisResource()), aclGetGroup('Admin')) then error(getResourceName(getThisResource())..' needs to be added to admin acl before it can run!', 3) end
addEvent('onResPreStart', true)
addEvent('onResStart', true)
addEvent('onClientResPreStart', true)
addEvent('onClientResStart', true)

Res = {}
resources = {}
Settings = {}

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
    setmetatable(self.globals, {__index = _G})
    return self
end


function Res.start(resName)
    if resources[resName] then
        return print('[Server] '.."resource '"..resName.."' already started")
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

    -- local serverScripts, clientScripts, serverFiles, clientFiles = {}, {}, {}, {}
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
        for r, t in pairs(meta.client) do
            if t:match('%.lua$') then
                res.client[#res.client+1] = t
            else
                res.clientFiles[#res.clientFiles+1] = t
            end
        end
    end

    for e=1, #res.serverFiles do
        res.files[res.serverFiles[e]] = true
    end

    Res.loadServer(resName, res.server)

    -- create Temp resource for clientfiles
    if #res.clientFiles > 0 then
        res.tempResource = res:createTempResource()
        local suc = res.tempResource:start()
        print('[Server] started temp resource', res.tempResource.name, suc)
    end

    triggerClientEvent('onResPreStart', root, resName, res.root, {res.client, res.clientFiles}, res.tempResource and res.tempResource.rootElement)

    updateResourcesList(resName)

    print('[Server] '..resName..' started')
end

function Res:createTempResource()
    local tempResName = 'CORE_'..self.name
    local tempResource = getResourceFromName(tempResName) or Resource(tempResName, '[temp]')

    local cfContent = 'addEventHandler("onClientResourceStart", resourceRoot, function()\n'
    cfContent = cfContent..'Timer(function()'
    local mfContent = '<meta>\n    <oop>true</oop>\n    <script src="client.lua" type="client" cache="false"/>\n'
    for i=1, #self.clientFiles do
        cfContent = cfContent..'    downloadFile("'..self.clientFiles[i]..'")\n'
        mfContent = mfContent..'    <file src="'..self.clientFiles[i]..'" download="false"/>\n'
        File.copy('resources/'..self.name..'/'..self.clientFiles[i], ':'..tempResName..'/'..self.clientFiles[i], true)
    end
    cfContent = cfContent..'end, 0, 1)\n'
    cfContent = cfContent..'end)'
    mfContent = mfContent..'</meta>'


    if File.exists(':'..tempResName..'/client.lua') then
        File.delete(':'..tempResName..'/client.lua')
    end
    local cf = File(':'..tempResName..'/client.lua')
    cf:write(cfContent)
    cf:close()

    if File.exists(':'..tempResName..'/meta.lua') then
        File.delete(':'..tempResName..'/meta.lua')
    end
    local mf = File(':'..tempResName..'/meta.xml')
    mf:write(mfContent)
    mf:close()

    refreshResources(false, tempResource)

    return tempResource
end

function Res.stop(name)
    local name = name
    local res = resources[name]
    if not res then return end

    res:unload()

    if #res.client > 0 then
        triggerClientEvent(root, 'onResStop', root, name)
    end

    -- stop tempResource
    if res.tempResource and res.tempResource.state == 'running' then
        Resource.stop(res.tempResource)
        print('[server] stopping tempResource')
    end

    -- clean up
    resources[name] = nil
    for _=1, 2 do collectgarbage() end
    print('[Server] '..name..' has been stopped.')
end

function Res.restart(name)
    local name = name
    if resources[name] then
        Res.stop(name)
        -- Timer(Res.start, 1500, 1, name)
        Res.start(name) --> won't start sometimes when there's a tempResource (timer fixes a bit but not enough, need to use onResourceStop event?)
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
                    meta.server[#meta.server+1] = attr.src
                end
            end
        end
        xmlUnloadFile(node)

        -- local f = File(json)
        -- f:write(toJSON(meta):sub(3,-3))
        -- f:close()
        -- fileDelete(xml)

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

function updateResourcesList(name)
    local path = 'resources/resources.json'
    local f = File(path)
    local list = fromJSON(f:read(f.size)) or {}

    if not list[name] then
        list[name] = {}
    end

    f:setPos(0)
    f:write(toJSON(list))
    f:close()
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

addEvent('onClientReady', true)
addEventHandler('onClientReady', root, function(resourceName)
    triggerClientEvent(client, 'executeResource', root, resourceName) --[client] tells client to start the resource
end)

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
end, 255, 1)

