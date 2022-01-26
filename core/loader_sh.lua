local elemFuncs = {'Ped', 'createPed', 'Vehicle', 'createVehicle', 'Object', 'createObject', 'Marker', 'createMarker', 'Sound', 'playSound', 'playSound3D', 'Pickup', 'createPickup', 'createColCircle', 'ColShape.Circle', 
'createColCuboid', 'ColShape.Cuboid', 'createColPolygon', 'ColShape.Polygon', 'createColRectangle', 'ColShape.Rectangle', 'createColSphere', 'ColShape.Sphere', 'createColTube', 'ColShape.Tube', 'createBlip', 'Blip', 
'createBlipAttachedTo', 'Blip.createAttachedTo', 'createRadarArea', 'RadarArea', 'Sound', 'Sound3D', 'playSFX', 'playSFX3D', 'createProjectile', 'Projectile', 'createTeam', 'Team.create', 'guiCreateFont', 'GuiFont', 
'guiCreateBrowser', 'GuiBrowser', 'guiCreateButton', 'GuiButton', 'guiCreateCheckBox', 'GuiCheckBox', 'guiCreateComboBox', 'GuiComboBox', 'guiCreateEdit', 'GuiEdit', 'guiCreateGridList', 'GuiGridList', 'guiCreateMemo', 
'GuiMemo', 'guiCreateProgressBar', 'GuiProgressBar', 'guiCreateRadioButton', 'GuiRadioButton', 'guiCreateScrollBar', 'GuiScrollBar', 'guiCreateScrollPane', 'GuiScrollPane', 'guiCreateStaticImage', 'GuiStaticImage', 
'guiCreateTabPanel', 'GuiTabPanel', 'guiCreateTab', 'GuiTab', 'guiCreateLabel', 'GuiLabel', 'guiCreateWindow', 'GuiWindow', 'dxCreateTexture', 'DxTexture', 'dxCreateRenderTarget', 'DxRenderTarget', 'dxCreateScreenSource', 
'DxScreenSource', 'dxCreateShader', 'DxShader', 'dxCreateFont', 'DxFont', 'createWeapon', 'Weapon', 'createEffect', 'Effect', 'Browser', 'createBrowser', 'createLight', 'Light', 'createSearchLight', 'SearchLight', 
'createWater', 'Water'}

function replaceFuncs(script)
    local newFuncs = {
        {'engineLoadCOL', function(...) return script:engineReplaceCOL(...) end},
        {'engineLoadModel', function(...) return script:engineReplaceModel(...) end},
        {'EngineCOL', function(...) return script:engineReplaceCOL(...) end},
        {'EngineDFF', function(...) return script:engineReplaceModel(...) end},
        {'engineReplaceCOL', function(...) return script:engineReplaceCOL(...) end},
        {'engineReplaceModel', function(...) return script:engineReplaceModel(...) end},
        {'engineLoadTXD', function(...) return script:engineImportTXD(...) end},
        {'engineImportTXD', function(...) return script:engineImportTXD(...) end},
        {'EngineTXD', function(...) return script:engineImportTXD(...) end},

        {'callRemote', function(...) return script:callRemote(...) end},
        {'fetchRemote', function(...) return script:fetchRemote(...) end},
        {'bindKey', function(...) return script:bindKey(...) end},
        {'addEventHandler', function(...) return script:addEventHandler(...) end},
        {'addCommandHandler', function(...) return script:addCommandHandler(...) end},
        {'setTimer', function(...) return script:setTimer(...) end},
        {'showCursor', function(...) return script:showCursor(...) end},
        {'getResourceRootElement', function(...) return script:getResourceRootElement(...) end},
        {'getRootElement', function(...) return script:getRootElement(...) end},
        {'getThisResource', function(...) return script:getThisResource(...) end},
        {'Resource.getThis', function(...) return script:getThisResource(...) end},
        {'fileGetPath', function(...) return script:fileGetPath(...) end}
    }

    for i=1, #elemFuncs do
		local origFunc = script.parent.globals[elemFuncs[i]]

        if getmetatable(origFunc) then
            script.parent.globals[elemFuncs[i]] = setmetatable({}, {
                __index = function(self, key)
                    return origFunc[key]
                end,
                __newindex = function(self, key, val)
                    origFunc[key] = val
                end,
                __call = function(self, ...)
                    local element = origFunc(...)

                    if isElement(element) then
                        element:setParent(script.parent.root)
                    end

                    return element
                end
            })
        else
            script.parent.globals[elemFuncs[i]] = function(...)
                local element = origFunc(...)

                if isElement(element) then
                    if isElement(script.parent.clientRoot) then
                        -- element:setParent(script.parent.clientRoot)
                        if elemFuncs[i]:find('gui') then
                            table.insert(script.elements, element)
                        end
                    end

                    element:setParent(script.parent.root)
                end

                return element
            end
        end
	end

    for i=1, #newFuncs do
        script.parent.globals[newFuncs[i][1]] = newFuncs[i][2]
    end
end