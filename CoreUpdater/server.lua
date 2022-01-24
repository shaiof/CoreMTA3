
function checkFiles(files, newVersion)
    fetchRemote('https://raw.githubusercontent.com/shaiof/CoreMTA/master/core/files.json', function(data, info)
        data = fromJSON(data)
        local localHashes = {}
        for i=1, #files do
            if fileExists(files[i]) then
                local f = fileOpen(files[i])
                local buffer = f:read(f.size)
                local hashCode = hash('md5', buffer)
                f:close()
                localHashes[files[i]] = hashCode
            end
        end

        local meta = xmlLoadFile('meta.xml')
        local info = meta:findChild('info', 0)
        local currentVer = info:getAttribute('version')
        meta:unload()

        for k=1, #data.currentVer do
            local officialHash = data.currentVer[k][2]
            if officialHash ~= localHashes[data.currentVer[k][1]] then
                --update
            end
        end
    end)
end

function update()
	if Settings.autoUpdate then
		fetchRemote('https://raw.githubusercontent.com/shaiof/CoreMTA/master/meta.xml', function(data, info)-- get list of files from the latest meta.
            local files = {}
			if data and info.success then
				local meta = xmlLoadString(data)
                for i=1, #meta.children do
                    local name = meta.children[i].name
                    if name == 'file' or name == 'script' then
                        files[#files+1] = meta.children[i]:getAttribute('src')
                    end
                end
                local info = meta:findChild('info', 0)
                local newVersion = info:getAttribute('version')
                meta:unload()
                checkFiles(files, newVersion)
			end
		end)
	end
end