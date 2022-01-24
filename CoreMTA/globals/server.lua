executeSQLQuery ('CREATE TABLE IF NOT EXISTS Table_System (ID, myTable)')
function setTableToSql( id, theTable )
    local Results = executeSQLQuery("SELECT myTable FROM `Table_System` WHERE ID=?", id ) 
     if ( type ( Results ) == "table" and #Results == 0 or not Results ) then 
		executeSQLQuery ( "INSERT INTO `Table_System` ( ID, myTable ) VALUES(?, ?)",id , toJSON ( theTable ) )
    else 
        executeSQLQuery('UPDATE `Table_System` SET myTable =? WHERE ID =?',toJSON ( theTable ),id ) 
    end  
end

function getTableFromSql ( id )
	local aRow = executeSQLQuery( "SELECT myTable FROM `Table_System` WHERE ID=?",id )
	if ( type ( aRow ) == "table" and #aRow == 0 ) or not aRow then return {""} end	
	return fromJSON ( aRow [1] [ "myTable" ] )
end

function aclGroupClone( clonedGroup, groupName, aclsClone, objectsClone )
	if ( type( clonedGroup ) ~= 'string' ) then 
		error( "Bad argument @ 'aclGroupClone' [Expected string at argument 1, got " .. tostring( clonedGroup ) .. "]" ) return false end
			if ( aclsClone == true or aclsClone == false ) then 
				if ( objectsClone == true or objectsClone == false ) then 
					local cloned = aclGetGroup( clonedGroup )
						if ( cloned == false or not cloned ) then
							outputDebugString( "Bad argument @ 'aclGroupClone' [Expected acl-group at argument 1, got string '" .. tostring( clonedGroup ) .. "']", 2 ) return false end
								local newGroup = aclCreateGroup( groupName )
									if ( newGroup == false or not newGroup ) then
										outputDebugString( "Bad argument @ 'aclGroupClone' [Expected acl-group at argument 2, got string '" .. tostring( groupName ) .. "']", 2 ) return false end
											if ( aclsClone == true ) then
												for index, value in ipairs( aclGroupListACL( cloned ) ) do
											aclGroupAddACL( newGroup, value )
										end
									end
								if ( objectsClone == true ) then
							for index, value in ipairs( aclGroupListObjects( cloned ) ) do
						aclGroupAddObject( newGroup, value )
					end
				end
			outputDebugString( "'aclGroupClone' [The group '"..clonedGroup.."' has been cloned successfully to '"..groupName.."' .", 3 ) return true
		else error( "Bad argument @ 'aclGroupClone' [Expected boolean at argument 4, got " .. tostring( objectsClone ) .. "]" ) return false
	end
	else error( "Bad argument @ 'aclGroupClone' [Expected boolean at argument 3, got " .. tostring( aclsClone ) .. "]" ) return false
	end
end

function getPlayersInACLGroup ( GroupName )
    local aTable = {}
    assert ( tostring ( GroupName ) , "Bad Argument At Argument #1 Group Moust String" )
    assert ( aclGetGroup ( tostring ( GroupName ) ) , "Bad Argument At Argument #1 Group not Found "  )
    
    for i , player_ in ipairs ( getElementsByType ( "player" ) ) do
        local TheAcc =  getPlayerAccount ( player_ )
        if not isGuestAccount ( TheAcc ) then
            if isObjectInACLGroup ( "user." ..getAccountName ( TheAcc ) , aclGetGroup ( tostring ( GroupName ) ) ) then
                table.insert ( aTable , player_ )
            end
        end
    end
    return aTable
end

function getPlayerAcls(player)
    local acls = {}
    local account = getPlayerAccount(player)
    if not account or isGuestAccount(account) then
        return acls
    end

    local accountName = getAccountName(account)
    for _, group in ipairs(aclGroupList()) do
        if isObjectInACLGroup("user." .. accountName, group) then
            local groupName = aclGroupGetName(group)
            table.insert(acls, groupName)
        end
    end
    return acls
end

function renameAclGroup(old,new)
	if (old and new and (type(old) == 'string') and (type(new) == 'string')) then
		local oldACLGroup = aclGetGroup(old)
		local newACLGroup = aclGetGroup(new)
		if oldACLGroup and not newACLGroup then
			local newACLGroup = aclCreateGroup(new)
			
			for _,acl in pairs(aclGroupListACL(oldACLGroup)) do
				aclGroupAddACL(newACLGroup,acl)
			end
			
			for _,object in pairs(aclGroupListObjects(oldACLGroup)) do
				aclGroupAddObject(newACLGroup,object)
			end
			
			aclDestroyGroup(oldACLGroup)
			aclSave()
			aclReload()
			
			return newACLGroup
		end
	end
	return false
end

function getAccountRanks( accName,thePlayer )
    local groups = aclGroupList()
    for i,v in ipairs(groups) do
        if isObjectInACLGroup("user."..accName,v) then
            outputChatBox( " there are "..aclGroupGetName(v).." group for the account ("..accName..") ",thePlayer)
        end
    end
end

function getPlayerFromAccountName(name) 
    local acc = getAccount(name)
    if not acc or isGuestAccount(acc) then
        return false
    end
    return getAccountPlayer(acc)
end

function isPlayerInACL(player, acl)
	if isElement(player) and getElementType(player) == "player" and aclGetGroup(acl or "") and not isGuestAccount(getPlayerAccount(player)) then
		local account = getPlayerAccount(player)
		
		return isObjectInACLGroup( "user.".. getAccountName(account), aclGetGroup(acl) )
	end
	return false
end

function isElementWithinAColShape(element)
	if element or isElement(element)then
		for _,colshape in ipairs(getElementsByType("colshape"))do
			if isElementWithinColShape(element,colshape) then
				return colshape
			end
		end
	end
	outputDebugString("isElementWithinAColShape - Invalid arguments or element does not exist",1)
	return false
end

armedVehicles = {[425]=true, [520]=true, [476]=true, [447]=true, [430]=true, [432]=true, [464]=true, [407]=true, [601]=true}
function vehicleWeaponFire(thePresser, key, keyState, vehicleFireType)
	local vehModel = getElementModel(getPedOccupiedVehicle(thePresser))
	if (armedVehicles[vehModel]) then
		triggerEvent("onVehicleWeaponFire", thePresser, vehicleFireType, vehModel)
	end
end

function bindOnJoin()
	bindKey(source, "vehicle_fire", "down", vehicleWeaponFire, "primary")
	bindKey(source, "vehicle_secondary_fire", "down", vehicleWeaponFire, "secondary")
end
addEventHandler("onPlayerJoin", root, bindOnJoin)

function bindOnStart()
	for index, thePlayer in pairs(getElementsByType("player")) do
		bindKey(thePlayer, "vehicle_fire", "down", vehicleWeaponFire, "primary")
		bindKey(thePlayer, "vehicle_secondary_fire", "down", vehicleWeaponFire, "secondary")
	end
end
addEventHandler("onResourceStart", resourceRoot, bindOnStart)

function assignLOD(element)
    local lod = createObject(getElementModel(element),0, 0 ,0, 0, 0, 0, true)
    setElementDimension(lod,getElementDimension(element))
    setElementPosition(lod, getElementPosition(element))
    setElementRotation(lod, getElementRotation(element))
    setElementCollisionsEnabled(lod,false)
    setLowLODElement(element,lod)
    return lod
end

function getAlivePlayersInTeam(theTeam)
    local theTable = { }
    local players = getPlayersInTeam(theTeam)

    for i,v in pairs(players) do
      if not isPedDead(v) then
        theTable[#theTable+1]=v
      end
    end
  
    return theTable
end

function getGuestPlayers (  )
local Guest = { }
	for _ , players_ in ipairs ( getElementsByType ( "player" ) ) do
		local playerAcc = getPlayerAccount ( players_ )
		if isGuestAccount ( playerAcc ) then
			table.insert ( Guest , players_ )
		end
	end
	return Guest
end

function getOnlineAdmins()
	local t = {}
	for k,v in ipairs ( getElementsByType("player") ) do
		local acc = getPlayerAccount(v)
		if acc and not isGuestAccount(acc) then
			local accName = getAccountName(acc)
			local isAdmin = isObjectInACLGroup("user."..accName,aclGetGroup("Admin"))
			if isAdmin then
				table.insert(t,v)
			end
		end
	end
	return t
end

function getPlayerFromSerial ( serial )
    assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" )
    for index, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( getPlayerSerial ( player ) == serial ) then
            return player
        end
    end
    return false
end

function getResourceScripts(resource)
    local scripts = {}
    local resourceName = getResourceName(resource)
    local theMeta = xmlLoadFile(":"..resourceName.."/meta.xml")
    for i, node in ipairs (xmlNodeGetChildren(theMeta)) do
        if (xmlNodeGetName(node) == "script") then
            local script = xmlNodeGetAttribute(node, "src")
            if (script) then
                table.insert(scripts, script)
            end
        end
    end
    return scripts
end

function getResourceSize(theResource)
    local actLine = tostring(debug.getinfo(2, 'l').currentline)
    assert(theResource and type(theResource) == 'string' or type(theResource) == 'userdata', "@ 'getResourceSize' (Line "..actLine..") Expected 'resource' or 'resource-name', got '"..type(theResource).."'")

    local res = 
    (type(theResource) == 'string' and getResourceFromName(tostring(theResource)))
    or
    (type(theResource) == 'userdata' and getUserdataType(theResource) == 'resource-data' and theResource)
    or false

    if not res then return false end

    local resourceName = getResourceName(res)
    local sizeB = 0
    local metaXML = xmlLoadFile(':'..resourceName..'/meta.xml')

    if (metaXML) then
        for _, v in ipairs(xmlNodeGetChildren(metaXML)) do
            local attribute = xmlNodeGetAttribute(v, 'src')
            if (attribute) then
                local file = fileOpen(':'..resourceName..'/'..attribute)
                if (file) then
                    sizeB = sizeB + fileGetSize(file)
                    fileClose(file)
                end
            end
        end
        return tonumber(string.format('%.3f', sizeB/1024))
    end
    return false
end

function getResourceSettings ( resource )
	if ( not resource ) then
		return false
	end

    local settingsTable = { }
    local name          = getResourceName ( resource )
    local meta          = xmlLoadFile     ( ":".. name .."/meta.xml" )
	if ( not meta ) then
		return false
	end

    local settings      = xmlFindChild    ( meta, "settings", 0 )
    if ( settings ) then
        for _, setting in ipairs ( xmlNodeGetChildren ( settings ) ) do
            local oldName      = xmlNodeGetAttribute ( setting, "name" )
            local temp         = string.gsub ( oldName, '[%*%#%@](.*)','%1' )
            table.insert (
				settingsTable,
					{
						string.gsub ( temp, name ..'%.(.*)','%1' ),
						xmlNodeGetAttribute ( setting, "value" ),
						xmlNodeGetAttribute ( setting, "friendlyname" ),
						xmlNodeGetAttribute ( setting, "accept" ),
						xmlNodeGetAttribute ( setting, "desc" ),
						xmlNodeGetAttribute ( setting, "group" )
					}
				)
        end
    end

    xmlUnloadFile ( meta )
    return settingsTable
end

function setResourcePriority(theResource, priority)
    local resourceName = getResourceName(theResource)
    local theMeta = resourceName and xmlLoadFile(":"..resourceName.."/meta.xml")
    if (theMeta) then
        local node = xmlFindChild(theMeta, "download_priority_group", 0)
        if (node) then 
            xmlNodeSetValue(node, tonumber(priority))
        else
            local newNode = xmlCreateChild(theMeta, "download_priority_group")
            xmlNodeSetValue(newNode, tonumber(priority))
        end
        xmlSaveFile(theMeta)
        xmlUnloadFile(theMeta)
        return true
    end
    return false
end

function getFilesInResourceFolder(path, res)
	if (triggerServerEvent) then error('The @getFilesInResourceFolder function should only be used on server-side', 2) end
	
	if not (type(path) == 'string') then
		error("@getFilesInResourceFolder argument #1. Expected a 'string', got '"..type(path).."'", 2)
	end
	
	if not (tostring(path):find('/$')) then
		error("@getFilesInResourceFolder argument #1. The path must contain '/' at the end to make sure it is a directory.", 2)
	end
	
	res = (res == nil) and getThisResource() or res
	if not (type(res) == 'userdata' and getUserdataType(res) == 'resource-data') then  
		error("@getFilesInResourceFolder argument #2. Expected a 'resource-data', got '"..(type(res) == 'userdata' and getUserdataType(res) or tostring(res)).."' (type: "..type(res)..")", 2)
	end
	
	local files = {}
	local files_onlyname = {}
	local thisResource = res == getThisResource() and res or false
	local charsTypes = '%.%_%w%d%|%\%<%>%:%(%)%&%;%#%?%*'
	local resourceName = getResourceName(res)
	local Meta = xmlLoadFile(':'..resoureName ..'/meta.xml')
	if not Meta then error("(@getFilesInResourceFolder) Could not get the 'meta.xml' for the resource '"..resourceName.."'", 2) end
	for _, nod in ipairs(xmlNodeGetChildren(Meta)) do
		local srcAttribute = xmlNodeGetAttribute(nod, 'src')
		if (srcAttribute) then
			local onlyFileName = tostring(srcAttribute:match('/(['..charsTypes..']+%.['..charsTypes..']+)') or srcAttribute)
			local theFile = fileOpen(thisResource and srcAttribute or ':'..resourceName..'/'..srcAttribute)
			if theFile then
				local filePath = fileGetPath(theFile)
				filePath = filePath:gsub('/['..charsTypes..']+%.['..charsTypes..']+', '/'):gsub(':'..resourceName..'/', '')
				if (filePath == tostring(path)) then
					table.insert(files, srcAttribute)
					table.insert(files_onlyname, onlyFileName)
				end
				fileClose(theFile)
			else
				outputDebugString("(@getFilesInResourceFolder) Could not check file '"..onlyFileName.."' from resource '"..nomeResource.."'", 2)
			end
		end
	end
	xmlUnloadFile(Meta)
	return #files > 0 and files or false, #files_onlyname > 0 and files_onlyname or false
end

function getJetpackWeaponsEnabled()
	local enabled = {}
	for i=0, 46 do
		local wepName = getWeaponNameFromID(i)
		if getJetpackWeaponEnabled(wepName) then
			table.insert(enabled,wepName)
		end
	end
	return enabled
end

function callClientFunction(client, funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerClientEvent(client, "onServerCallsClientFunction", resourceRoot, funcname, unpack(arg or {}))
end

local allowedFunctions = { ["setPlayerTeam"]=true, ["getListOfCheese"]=true }

function callServerFunction(funcname, ...)
    if not allowedFunctions[funcname] then
        outputServerLog( "SECURITY: " .. tostring(getPlayerName(client)) .. " tried to use function " .. tostring(funcname) )
        return
    end

    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onClientCallsServerFunction", true)
addEventHandler("onClientCallsServerFunction", resourceRoot , callServerFunction)

function getBanFromName (name)
    for key, ban in ipairs(getBans()) do -- for every ban do following
        if (getBanNick(ban) == name) then -- if the name of the banned player is equal to our name then
	    return ban -- return the ban
	end
    end
    return false -- else return false
end