function isValueInTable(theTable,value,columnID)
    assert(theTable, "Bad argument 1 @ isValueInTable (table expected, got " .. type(theTable) .. ")")
    local checkIsTable = type(theTable)
    assert(checkIsTable == "table", "Invalid value type @ isValueInTable (table expected, got " .. checkIsTable .. ")")
    assert(value, "Bad argument 2 @ isValueInTable (value expected, got " .. type(value) .. ")")
    assert(columnID, "Bad argument 3 @ isValueInTable (number expected, got " .. type(columnID) .. ")")
    local checkIsID = type(columnID)
    assert(checkIsID == "number", "Invalid value type @ isValueInTable (number expected, got " ..checkIsID .. ")")
    for i,v in ipairs (theTable) do
        if v[columnID] == value then
            return true,i
        end
    end
    return false
end

function rangeToTable( range )
    assert(range, type(range)=="string", "Bad argument @ rangeToTable. Expected 'string', got '"..type(range).."'")
    local numbers = split(range, ",")
    local output = {}
    for k, v in ipairs(numbers) do
        if tonumber(v) then
            table.insert(output, tonumber(v))
        else
            local st,en = tonumber(gettok(v, 1, "-")), tonumber(gettok(v, 2, "-"))
            if st and en then
                for i = st, en, (st<en and 1 or -1) do
                    table.insert(output, tonumber(i))
                end
            end
        end
    end
    return output
end

function setTableProtected (tbl)
  return setmetatable ({}, 
    {
    __index = tbl,  -- read access gets original table item
    __newindex = function (t, n, v)
       error ("attempting to change constant " .. 
             tostring (n) .. " to " .. tostring (v), 2)
      end -- __newindex, error protects from editing
    })
end

function insertSortingByIndex(array, e)
	local data = array
	for i = 2, #data do
		local j = i - 1
		local ass = data[i]
		while j > 0 and data[j][e] > ass[e] do
			data[j + 1] = data[j]
			j = j - 1
		end
		data[j + 1] = ass
	end
	return data
end

function fixedBubbleSortingByIndex(array, e)
	local data = array
	local i = #data
	while i >= 2 do
		local idx = 0
		for j = 1, (i - 1) do
			if data[j][e] > data[j + 1][e] then
				local holder = data[j][e]
				data[j][e] = data[j + 1][e]
				data[j + 1][e] = holder
				idx = j
			end
		end
		i = idx
	end
	return data
end

function table.compare( a1, a2 )
	if 
		type( a1 ) == 'table' and
		type( a2 ) == 'table'
	then
	
		local function size( t )
			if type( t ) ~= 'table' then
				return false 
			end
			local n = 0
			for _ in pairs( t ) do
				n = n + 1
			end
			return n
		end

		if size( a1 ) == 0 and size( a2 ) == 0 then
			return true
		elseif size( a1 ) ~= size( a2 ) then
			return false
		end
		
		for _, v in pairs( a1 ) do
			local v2 = a2[ _ ]
			if type( v ) == type( v2 ) then
				if type( v ) == 'table' and type( v2 ) == 'table' then
					if size( v ) ~= size( v2 ) then
						return false
					end
					if size( v ) > 0 and size( v2 ) > 0 then
						if not table.compare( v, v2 ) then 
							return false 
						end
					end	
				elseif 
					type( v ) == 'string' or type( v ) == 'number' and
					type( v2 ) == 'string' or type( v2 ) == 'number'
				then
					if v ~= v2 then
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end
		return true
	end
	return false
end

function table.copy(tab, recursive)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
    end
    return ret
end

function table.empty( a )
    if type( a ) ~= "table" then
        return false
    end
    
    return next(a) == nil
end

function table.map(tab, depth, func, ...)
    for key, value in pairs(tab) do
        if (type(value) == "table" and depth ~= 0) then tab[key] = table.map(value, depth - 1, func, ...)
        else tab[key] = func(value, ...) end
    end
    return tab
end

function table.merge(table1,...)
    for _,table2 in ipairs({...}) do
        for key,value in pairs(table2) do
            if (type(key) == "number") then
                table.insert(table1,value)
            else
                table1[key] = value
            end
        end
    end
    return table1
end

function table.random ( theTable )
    return theTable[math.random ( #theTable )]
end

function table.removeValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            table.remove(tab, index)
            return index
        end
    end
    return false
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function table.getRandomRows(table, rowsCount)
	if( #table > rowsCount )then
		local t = {}
		local random
		while(rowsCount > 0)do
			random = math.random(#table)
			if(not t[random] )then
				t[random] = random
				rowsCount = rowsCount - 1
			end
		end
		local rows = {}
		for i,v in pairs(t)do
			rows[#rows + 1] = v
		end
		return rows
	else
		return table
	end
end

function pairsByKeys (t)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function ()
		i = i + 1
		if a[i] == nil then 
			return nil
		else 
			return a[i], t[a[i]]
		end
	end
	return iter
end

function table.element(t, elemType, _aux)
	local elem = _aux or {}
	for k, v in pairs(t) do
		if (type(v) == "table") then
			table.element(v, elemType, elem)
		else
			if (type(v) == "userdata") then
				if elemType then
					if (getElementType(v) == elemType) then
						table.insert(elem, v)
					end
				else
					table.insert(elem, v)
				end
			end
		end	
	end
	return elem
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function getElementsInDimension(theType,dimension)
    local elementsInDimension = { }
	for key, value in ipairs(getElementsByType(theType)) do
		if getElementDimension(value)==dimension then
			table.insert(elementsInDimension,value)
		end
	end
	return elementsInDimension
end

function getElementsWithinMarker(marker)
	if (not isElement(marker) or getElementType(marker) ~= "marker") then
		return false
	end
	local markerColShape = getElementColShape(marker)
	local elements = getElementsWithinColShape(markerColShape)
	return elements
end

function getNearestElement(thePlayer, elementType, distance)
	local lastMinDis = distance-0.0001
	local nearestElement = false
	local px,py,pz = getElementPosition(thePlayer)
	local pInt = getElementInterior(thePlayer)
	local pDim = getElementDimension(thePlayer)
    
	for _,e in pairs(getElementsByType(elementType)) do
		local eInt,eDim = getElementInterior(e),getElementDimension(e)
		if eInt == pInt and eDim == pDim and e ~= thePlayer then
			local ex,ey,ez = getElementPosition(e)
			local dis = getDistanceBetweenPoints3D(px,py,pz,ex,ey,ez)
			if dis < distance then
				if dis < lastMinDis then
					lastMinDis = dis
					nearestElement = e
				end
			end
		end
	end
	return nearestElement
end

function isElementInRange(ele, x, y, z, range)
	if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
	end
	return false
end

function isElementMoving (theElement )
   if isElement ( theElement ) then                                   -- First check if the given argument is an element
      return Vector3( getElementVelocity( theElement ) ).length ~= 0
   end
   return false
end

function multi_check( source, ... )
	local arguments = { ... }

	for _, argument in ipairs( arguments ) do
		if argument == source then
			return true
		end
	end
	return false
end

function setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = getElementSpeed(element, unit)
	if acSpeed and acSpeed~=0 then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		if diff ~= diff then return false end -- if the number is a 'NaN' return false.
        	local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end
	return false
end

function byte2human(bytes, si)
	local threshold = si and 1000 or 1024
	if (math.abs(bytes) < threshold) then
		return bytes .. " B"
	end
	local units = 
	si and {"kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"}
	    or {"KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"}
	local unitIndex = 0
	repeat
		bytes = bytes / threshold
		unitIndex = unitIndex + 1
	until not (math.abs(bytes) >= threshold and unitIndex < #units)
	return math.simpleround(bytes, 2) .. " " .. units[unitIndex]
end

local function doCapitalizing( substring )
    return substring:sub( 1, 1 ):upper( ) .. substring:sub( 2 )
end

function capitalize( text )
    assert( type( text ) == "string", "Bad argument 1 @ capitalize [String expected, got " .. type( text ) .. "]")
    return ( { string.gsub( text, "%a+", doCapitalizing ) } )[1]
end

function convertServerTickToTimeStamp(tick) return getRealTime().timestamp+((getTickCount()*0.001)-(tick*0.001)); end

function convertTextToSpeech(text, broadcastTo, lang)
    -- Ensure first argument is valid
    assert(type(text) == "string", "Bad argument 1 @ convertTextToSpeech [ string expected, got " .. type(text) .. "]")
    assert(#text <= 100, "Bad argument 1 @ convertTextToSpeech [ too long string; 100 characters maximum ]")
    if triggerClientEvent then -- Is this function called serverside?
        -- Ensure second and third arguments are valid
        assert(broadcastTo == nil or type(broadcastTo) == "table" or isElement(broadcastTo), "Bad argument 2 @ convertTextToSpeech [ table/element expected, got " .. type(broadcastTo) .. "]")
        assert(lang == nil or type(lang) == "string", "Bad argument 3 @ convertTextToSpeech [ string expected, got " .. type(lang) .. "]")
        -- Tell the client to play the speech
        return triggerClientEvent(broadcastTo or root, "playTTS", root, text, lang or "en")
    else -- This function is executed clientside
        local lang = broadcastTo
        -- Ensure second argument is valid
        assert(lang == nil or type(lang) == "string", "Bad argument 2 @ convertTextToSpeech [ string expected, got " .. type(lang) .. "]")
        return playTTS(text, lang or "en")
    end
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

local gWeekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
function formatDate(format, escaper, timestamp)
	check("formatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")
	
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false

	time.year = time.year + 1900
	time.month = time.month + 1
	
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
	
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
	
	return formattedDate
end

function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	return tostring(number):reverse():gsub("%d%d%d","%1%"..(sep and #sep>0 and sep or ".")):reverse()
end

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } }
function generateString ( len )
    if tonumber ( len ) then
        math.randomseed ( getTickCount () )
        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.char ( math.random ( charlist[1], charlist[2] ) )
        end
        return str
    end
    return false
end

function generateRandomASCIIString(stringLenght)
    local str = ""
    math.randomseed(getTickCount())
    for i = 1, stringLenght do 
	str = str..(string.format("%c", math.random(32, 126)))
    end

    return str
end

function getDistance(element, other)
	local x, y, z = getElementPosition(element)
	if isElement(element) and isElement(other) then
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(other))
	end
end

function getAge(day, month, year)
	local time = getRealTime();
	time.year = time.year + 1900;
	time.month = time.month + 1;
	
	year = time.year - year;
	month = time.month - month;
	
	if month < 0 then 
		year = year - 1 
	elseif month == 0 then
		if time.monthday < day then
			year = year - 1;
		end
	end
	
	return year;
end

function getDistanceBetweenPointAndSegment2D(pointX, pointY, x1, y1, x2, y2)
	local A = pointX - x1
	local B = pointY - y1
	local C = x2 - x1
	local D = y2 - y1

	local point = A * C + B * D
	local lenSquare = C * C + D * D
	local parameter = point / lenSquare

	local shortestX
	local shortestY

	if parameter < 0 then
		shortestX = x1
    		shortestY = y1
	elseif parameter > 1 then
		shortestX = x2
		shortestY = y2
	else
		shortestX = x1 + parameter * C
		shortestY = y1 + parameter * D
	end

	local distance = getDistanceBetweenPoints2D(pointX, pointY, shortestX, shortestY)

	return distance
end

function getEasterDate(year)
    local y = tonumber(year)
    assert(y, "Bad argument 1 @ getEasterDate [Number expected, got " .. type(year) .. "]")

    local M = 24
    local N = 5
    local a = y%19
    local b = y%4

    local c = y%7 
    local d = (19*a+M)%30 
    local e = (2*b+4*c+6*d+N)%7 
    local dayMar = 22+d+e
    local dayApr = d+e-9

    if dayMar > 31 then
        return dayApr, 4
    else
        return dayMar, 3
    end
end

function getKeyFromValueInTable(a, b)
    for k,v in pairs(a) do
        if v == b then
           return k
        end
    end
    return false
end

function getOffsetFromXYZ( mat, vec )
    mat[1][4] = 0
    mat[2][4] = 0
    mat[3][4] = 0
    mat[4][4] = 1
    mat = matrix.invert( mat )
    local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1] + mat[4][1]
    local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2] + mat[4][2]
    local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3] + mat[4][3]
    return {offX, offY, offZ}
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle)
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
    return x+dx, y+dy
end

monthTable = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

function getRealMonth()
	local time = getRealTime()
	local month = time.month + 1
	return monthTable[month]
end

function getRGColorFromPercentage(percentage)
	if not percentage or
		percentage and type(percentage) ~= "number" or
		percentage > 100 or percentage < 0 then
		outputDebugString( "Invalid argument @ 'getRGColorFromPercentage'", 2 )
		return false
	end

	if percentage > 50 then
		local temp = 100 - percentage
		return temp*5.1, 255
	elseif percentage == 50 then
		return 255, 255
	end
	
	return 255, percentage*5.1
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function isValidMail( mail )
    assert( type( mail ) == "string", "Bad argument @ isValidMail [string expected, got " .. tostring( mail ) .. "]" )
    return mail:match( "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?" ) ~= nil
end

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )
		
		if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " second" or " seconds" ) ) end
		
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return false
end

function string.count (text, search)
	if ( not text or not search ) then return false end
	
	return select ( 2, text:gsub ( search, "" ) );
end

function string.insert(self, str1, str2, pos)
    if (self) then
        return self:sub(1,str2)..str1..self:sub(str2+1)
    else
        return str1:sub(1,pos)..str2..str1:sub(pos+1)
    end
end

function string.explode(self, separator)
    check("string.explode", "string", self, "ensemble", "string", separator, "separator")

    if (#self == 0) then return {} end
    if (#separator == 0) then return { self } end

    return loadstring("return {\""..self:gsub(separator, "\",\"").."\"}")()
end

function switch(arg)
        if(type(arg)~="table")then return switch end
        local switching, default, done; --Default is nil
        if(tostring(arg[1]):len()<=2)and(tostring(arg[2]):len()<=2)then switching=arg[1] end
        table.remove(arg, 1);
        for i=1, #arg do
                if(tostring(arg[i]):len()<=3)and(arg[i]==switching)then
                        if(type(arg[i+1])=="function")then
                                pcall(arg[i+1])
                                done=true;
                                break
                        else
                                break
                        end
                end
                if(arg[i]==nil)and(arg[i]==switching)and(type(arg[i+1])=="function")then pcall(arg[i+1]) end
        end
        if(not done)then print("No action.") end
end

function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil

	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end

			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
						
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end

function toHex ( n )
    local hexnums = {"0","1","2","3","4","5","6","7",
                     "8","9","A","B","C","D","E","F"}
    local str,r = "",n%16
    if n-r == 0 then str = hexnums[r+1]
    else str = toHex((n-r)/16)..hexnums[r+1] end
    return str
end

function wavelengthToRGBA (length)
	local r, g, b, factor
	if (length >= 380 and length < 440) then
		r, g, b = -(length - 440)/(440 - 380), 0, 1
	elseif (length < 489) then
		r, g, b = 0, (length - 440)/(490 - 440), 1
	elseif (length < 510) then
		r, g, b = 0, 1, -(length - 510)/(510 - 490)
	elseif (length < 580) then
		r, g, b = (length - 510)/(580 - 510), 1, 0
	elseif (length < 645) then
		r, g, b = 1, -(length - 645)/(645 - 580), 0
	elseif (length < 780) then
		r, g, b = 1, 0, 0
	else
		r, g, b = 0, 0, 0
	end
	if (length >= 380 and length < 420) then
		factor = 0.3 + 0.7*(length - 380)/(420 - 380)
	elseif (length < 701) then
		factor = 1
	elseif (length < 780) then
		factor = 0.3 + 0.7*(780 - length)/(780 - 700)
	else
		factor = 0
	end
	return r*255, g*255, b*255, factor*255
end

function getDistanceBetweenElements(arg1, arg2)
	local element1 = Vector3(getElementPosition( arg1 ))
	local element2 = Vector3(getElementPosition( arg2 ))
	local distance = getDistanceBetweenPoints3D( element1,element2 )
	return distance
end

function getFreeDimension ()
	local freeDim = nil
	for dim = 1, 60000 do
		if #getElementsInDimension ("player", dim) == 0 then
			freeDim = dim
			break
		end
	end
	return freeDim
end

function createMarkerAttachedTo(element, mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset)
	mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset = mType or "checkpoint", size or 4, r or 0, g or 0, b or 255, a or 255, visibleTo or getRootElement(), xOffset or 0, yOffset or 0, zOffset or 0
	assert(isElement(element), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 1, got " .. type(element) .. "]") assert(type(mType) == "string", "Bad argument @ 'createMarkerAttachedTo' [Expected string at argument 2, got " .. type(mType) .. "]") assert(type(size) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 3, got " .. type(size) .. "]") assert(type(r) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 4, got " .. type(r) .. "]")	assert(type(g) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 5, got " .. type(g) .. "]") assert(type(b) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 6, got " .. type(b) .. "]") assert(type(a) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 7, got " .. type(a) .. "]") assert(isElement(visibleTo), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 8, got " .. type(visibleTo) .. "]") assert(type(xOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 9, got " .. type(xOffset) .. "]") assert(type(yOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 10, got " .. type(yOffset) .. "]") assert(type(zOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 11, got " .. type(zOffset) .. "]")
	local m = createMarker(0, 0, 0, mType, size, r, g, b, a, visibleTo)
	if m then if attachElements(m, element, xOffset, yOffset, zOffset) then return m end end return false
end

function mathNumber ( num, integer, type )
    if not ( num ) or not ( integer ) then return false end

    local function formatNumber( numb )
    if not ( numb ) then return false end
        local fn = string.sub( tostring( numb ), ( #tostring( numb ) -6 ) )
        return tonumber( fn )
    end
	
    if not ( type ) or ( type == "+" ) then
        return tonumber( string.sub( tostring( num ), 1, -8 )..( formatNumber ( num ) ) + integer )
    else
        return tonumber( string.sub( tostring( num ), 1, -8 )..( formatNumber ( num ) ) - integer )
    end
end

function math.hypot( legX, legY )
    return ((legX ^ 2) + (legY ^ 2)) ^ .5
end

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function pointInPolygon( x, y, ...)
	local vertices = {...}
	local points= {}

	for i=1, #vertices-1, 2 do
		points[#points+1] = { x=vertices[i], y=vertices[i+1] }
	end
	
	local i, j = #points, #points
	local inside = false

	for i=1, #points do
		if ((points[i].y < y and points[j].y>=y or points[j].y< y and points[i].y>=y) and (points[i].x<=x or points[j].x<=x)) then
			if (points[i].x+(y-points[i].y)/(points[j].y-points[i].y)*(points[j].x-points[i].x)<x) then
				inside = not inside
			end
		end
		j = i
	end
	return inside
end

function math.polygonArea( ...)
	local vertices = {...}
	local points= {}

	for i=1, #vertices-1, 2 do
		points[#points+1] = { x=vertices[i], y=vertices[i+1] }
	end
	local count = #points

	local area = 0
	local j = count

	for i=1, count do
		area = area +  (points[j].x + points[i].x) * (points[j].y - points[i].y)
		j = i
	end

	return math.abs(area/2)
end

function math.randomDiff (start, finish)
	if start >= finish or not start or not finish then return false end
	if (math.floor(start) ~= start) or (math.floor(finish) ~= finish) then return false end
	local rand = math.random(start, finish)
	while (rand == lastRand) do
		rand = math.random(start, finish)
	end
	lastRand = rand
	return rand
end

function getPlayersInVehicles ( dimension )
	local players = { }
	if ( dimension ) then
		local dimension = tonumber ( dimension )
		if ( type ( dimension ) == "number" ) then
			for _, v in ipairs ( getElementsByType ( "player" ) ) do
				if ( getPedOccupiedVehicle ( v ) and getElementDimension ( v ) == dimension ) then
					table.insert ( players, v )
				end
			end
		else
			outputDebugString ( "Bad argument @ 'getPlayersInVehicles' [Expected number at argument 1, got " .. type ( dimension ) .. "]", 2 )
			return false
		end
	else
		outputDebugString ( "Bad argument @ 'getPlayersInVehicles' [Expected number at argument 1, got " .. type ( dimension ) .. "]", 2 )
		return false
	end
	return players
end

function getPedMaxHealth(ped)
    assert(isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player"), "Bad argument @ 'getPedMaxHealth' [Expected ped/player at argument 1, got " .. tostring(ped) .. "]")
    local stat = getPedStat(ped, 24)
    local maxhealth = 100 + (stat - 569) / 4.31
    return math.max(1, maxhealth)
end

function getPedMaxOxygenLevel(ped)
    assert(isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player"), "Bad argument @ 'getPedMaxOxygenLevel' [Expected ped at argument 1, got " .. tostring(ped) .. "]")
    local underwater_stamina = getPedStat(ped, 225)
    local stamina = getPedStat(ped, 22)
    local maxoxygen = 1000 + underwater_stamina * 1.5 + stamina * 1.5
    return maxoxygen
end

local weaponToPedStat = {[22] = 69, [23] = 70, [24] = 71, [25] = 72, [26] = 73, [27] = 74, [28] = 75, [29] = 76, [30] = 77, [31] = 78, [32] = 75, [33] = 79, [34] = 79}
local weaponSkillLevels = {[22] = 40, [23] = 500, [24] = 200, [25] = 200, [26] = 200, [27] = 200, [28] = 50, [29] = 250, [30] = 200, [31] = 200, [32] = 50, [33] = 300, [34] = 300}

function getPedWeaponSkill(ped, weapon)
    if not isElement(ped) then return false end
    if not(type(weapon) == "string" or type(weapon) == "number") then return false end
    if type(weapon) == "string" then
        weapon = getWeaponIDFromName(weapon)
        if not weapon then return false end
    end
    local pedStat = weaponToPedStat[weapon]
    if not pedStat then return false end
    local weaponSkillLevel = weaponSkillLevels[weapon]
    local pedWeaponSkill = getPedStat(ped, pedStat)
    if pedWeaponSkill<weaponSkillLevel then
        return "poor" --poor
    elseif pedWeaponSkill<999 then
        return "std" --gangster
    else
        return "pro" --hitman
    end
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function getPlayersByData(dataName)
    if dataName and type(dataName) == "string" then
	local playersTable = {}
	for i,v in ipairs(getElementsByType("player")) do
	    if getElementData(v, dataName) then
                table.insert(playersTable, v)
	    end
	end
	if #playersTable == 0 then
	    return false
	end
	return playersTable
    else
        return false
    end
end

function isPedDrivingVehicle(ped)
    assert(isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player"), "Bad argument @ isPedDrivingVehicle [ped/player expected, got " .. tostring(ped) .. "]")
    local isDriving = isPedInVehicle(ped) and getVehicleOccupant(getPedOccupiedVehicle(ped)) == ped
    return isDriving, isDriving and getPedOccupiedVehicle(ped) or nil
end

function isPlayerInTeam(player, team)
    assert(isElement(player) and getElementType(player) == "player", "Bad argument 1 @ isPlayerInTeam [player expected, got " .. tostring(player) .. "]")
    assert((not team) or type(team) == "string" or (isElement(team) and getElementType(team) == "team"), "Bad argument 2 @ isPlayerInTeam [nil/string/team expected, got " .. tostring(team) .. "]")
    return getPlayerTeam(player) == (type(team) == "string" and getTeamFromName(team) or (type(team) == "userdata" and team or (getPlayerTeam(player) or true)))
end

function countPlayersInRange(x, y, z, range)
    if tonumber(x..y..z..range) then
        local add = 0
        for _, v in ipairs(getElementsByType("player")) do
            local px, py, pz = getElementPosition( v )
            if getDistanceBetweenPoints3D(px, py, pz, tonumber(x), tonumber(y), tonumber(z)) <= tonumber(range) then
                add = add + 1
            end
        end
        return add
    else
        return false
    end
end

function isPlayerHitByVehicle (attacker)
	if not attacker then
		return
	end
	if getElementType(attacker) == 'vehicle' then
		cancelEvent()
	end
end

function warpToPlayer(thePlr,plrr)
	if getElementType(plrr) == "player" then
		if isPedInVehicle(plrr) then
			local veh = getPedOccupiedVehicle ( plrr )
			local maxp = getVehicleMaxPassengers ( veh )
			local passengers = getVehicleOccupants ( veh )
			if maxp > 1 and #passengers ~= maxp then
				warpPedIntoVehicle(thePlr,veh, #passengers+1)
			end
		else
			local x,y,z = getElementPosition(plrr)
			setElementPosition(thePlr, x+1,y,z)
		end
	end
end

function getPlayersInRange (playerSource,range)
	local allPlayers = getElementsByType("player")
	local x,y,z = getElementPosition(playerSource)
	local count = 0
	local players = {}
	for k, v in ipairs(allPlayers) do 
		if(v and playerSource)then
			if not(v == playerSource)then
					local Sx,Sy,Sz = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(x,y,z,Sx,Sy,Sz)
					if(distance <= range)then
					count = count +1
					players[v] = v
				end
			end
		end
	end 
	if(count == 0)then
		return false
	else
		return players
	end
end

function getTeamFromColor(r,g,b)
	if 
		not r or type(r)~="number" or r<0 or r>255 or
		not g or type(g)~="number" or g<0 or g>255 or
		not b or type(b)~="number" or b<0 or b>255
	then outputDebugString("getTeamFromColor - Bad Arguments",0) return false end
		
	for _,team in ipairs(getElementsByType("team"))do
		local tR,tG,tB = getTeamColor(team)
		if tR==r and tG==g and tB==b then
			return team
		end
	end
	return false
end

function getTeamsWithFewestPlayers(t)
    if t and type(t)=="table" then -- Do checks for validity
        for i,v in ipairs(t) do
             if (not isElement(v)) or (type(v) ~= "team") then
                 -- Use stacktrace from debug to output a message to parent function
                 return false
             end
        end
    else t = getElementsByType("team") end
    local lowestScorers, lowestCount = {}, math.huge
    for i,v in ipairs(t) do
        local count = countPlayersInTeam(v)
        if count < lowestCount then
            lowestScorers = {v}
            lowestCount = count
        elseif count == lowestCount then
            table.insert(lowestScorers, v)
        end
    end
    return lowestScorers
end

function findEmptyCarSeat(vehicle)
    local max = getVehicleMaxPassengers(vehicle)
    local pas = getVehicleOccupants(vehicle)
    for i=1, max do
        if not pas[i] then
            return i
        end
    end
    return false
end

function getNearestVehicle(player,distance)
	local lastMinDis = distance-0.0001
	local nearestVeh = false
	local px,py,pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)

	for _,v in pairs(getElementsByType("vehicle")) do
		local vint,vdim = getElementInterior(v),getElementDimension(v)
		if vint == pint and vdim == pdim then
			local vx,vy,vz = getElementPosition(v)
			local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
			if dis < distance then
				if dis < lastMinDis then 
					lastMinDis = dis
					nearestVeh = v
				end
			end
		end
	end
	return nearestVeh
end

function getRandomVehicle( )
    local vehicles = getElementsByType("vehicle")
    local numberOfVehs = #vehicles

    if numberOfVehs == 0 then
        return false
    end

    return vehicles[ math.random( 1, numberOfVehs ) ]
end

function getValidVehicleModels ( )
	local validVehicles = { }
	local invalidModels = {
		[435]=true, [449]=true, [450]=true, [537]=true,
		[538]=true, [569]=true, [570]=true, [584]=true,
		[590]=true, [591]=true, [606]=true, [607]=true, 
		[608]=true
	}
	for i=400, 609 do
		if ( not invalidModels[i] ) then
			table.insert ( validVehicles, i )
		end
	end
	return validVehicles
end

function getVehiclesCountByType(vehicleType)
    assert(type(vehicleType) == "string", "expected string at argument 1, got ".. type(vehicleType))

    local getVehicleType = getVehicleType -- Localize
    local vehicleList = getElementsByType("vehicle")
    local vehicleCount = #vehicleList
    local typeCount = 0

    for index = 1, vehicleCount do
        if getVehicleType(vehicleList[index]) == vehicleType then
            typeCount = typeCount + 1
        end
    end

    return typeCount
end

function isVehicleEmpty( vehicle )
	if not isElement( vehicle ) or getElementType( vehicle ) ~= "vehicle" then
		return true
	end

	local passengers = getVehicleMaxPassengers( vehicle )
	if type( passengers ) == 'number' then
		for seat = 0, passengers do
			if getVehicleOccupant( vehicle, seat ) then
				return false
			end
		end
	end
	return true
end

function isVehicleOccupied(vehicle)
    assert(isElement(vehicle) and getElementType(vehicle) == "vehicle", "Bad argument @ isVehicleOccupied [expected vehicle, got " .. tostring(vehicle) .. "]")
    local _, occupant = next(getVehicleOccupants(vehicle))
    return occupant and true, occupant
end

function isVehicleOnRoof(vehicle)
	local rx,ry=getElementRotation(vehicle)
	if (rx>90 and rx<270) or (ry>90 and ry<270) then
			return true
	end
	return false
end

function isVehicleReversing(theVehicle)
    local getMatrix = getElementMatrix (theVehicle)
    local getVelocity = Vector3 (getElementVelocity(theVehicle))
    local getVectorDirection = (getVelocity.x * getMatrix[2][1]) + (getVelocity.y * getMatrix[2][2]) + (getVelocity.z * getMatrix[2][3]) 
    if (getVectorDirection >= 0) then
        return false
    end
    return true
end

function isVehicleUpgraded(theVehicle, upgrade)
	if not (isElement(theVehicle) and getElementType(theVehicle) == "vehicle") then return end
	if not (upgrade and type(upgrade) == "number") then return end
	for slot=0, 16 do
		local upgradeSlot = getVehicleUpgradeOnSlot(theVehicle, slot)
		if (upgradeSlot) and (upgradeSlot == upgrade) then
			return true
		end
	end
	return false
end

function getPreviousAndNextWeapon( player )
	assert( isElement( player ) and getElementType( player ) == "player", "@getPreviousAndNextWeapon, expected player at argument '1', received " .. tostring(player) .. "." )

	local weapons = { }
	for i=0, 12 do
		weapons[ i ] = getPedWeapon( player, i )
	end

	local maxId = 0
	local minId = 12

	while weapons[ maxId ] == 0 do
		maxId = maxId + 1
	end

	while weapons[ minId ] == 0 do
		minId = minId - 1
	end

	return getPedWeapon( player ) == 0 and weapons[ minId ] or weapons[ getPedWeaponSlot( player ) - 1 ] or 0, getPedWeapon( player ) == 0 and weapons[ maxId ] or weapons[ getPedWeaponSlot( player ) + 1 ] or 0;
end

function getXMLNodes(xmlfile,nodename)
	local xml = xmlLoadFile(xmlfile)
	if xml then
		local ntable={}
		local a = 0
		while xmlFindChild(xml,nodename,a) do
			table.insert(ntable,a+1)
			ntable[a+1]={}
			local attrs = xmlNodeGetAttributes ( xmlFindChild(xml,nodename,a) )
			for name,value in pairs ( attrs ) do
				table.insert(ntable[a+1],name)
				ntable[a+1][name]=value
			end

			ntable[a+1]["nodevalue"]=xmlNodeGetValue(xmlFindChild(xml,nodename,a))

			a=a+1
		end

		xmlUnloadFile(xml)
		return ntable
	else
		return {}
	end
end

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

local passiveTimerGroups = {}
local cleanUpInterval = 240000
local nextCleanUpCycle = getTickCount() + cleanUpInterval

local onElementDestroyEventName = triggerServerEvent and "onClientElementDestroy" or "onElementDestroy"

local function isEventHandlerAdded( eventName, elementAttachedTo, func ) -- https://wiki.multitheftauto.com/wiki/GetEventHandlers
	local attachedFunctions = getEventHandlers( eventName, elementAttachedTo )
	if #attachedFunctions > 0 then
		for i=1, #attachedFunctions do
			if attachedFunctions[i] == func then
				return true
			end
		end
	end
	return false
end

local function removeDeletedElementTimer ()
	for timerName, passiveTimers in pairs(passiveTimerGroups) do
		if passiveTimers[this] then
			passiveTimers[this] = nil
			if not next(passiveTimers) then
				passiveTimerGroups[timerName] = nil
			end
		end
	end
	removeEventHandler(onElementDestroyEventName, this, removeDeletedElementTimer)
end

local function checkCleanUpCycle (timeNow)
	if timeNow > nextCleanUpCycle then
		nextCleanUpCycle = timeNow + cleanUpInterval
		local maxExecutionTime = timeNow + 3
		for timerName, passiveTimers in pairs(passiveTimerGroups) do
			for key, executionTime in pairs(passiveTimers) do
				if timeNow > executionTime then
					if isElement(key) and isEventHandlerAdded(onElementDestroyEventName, key, removeDeletedElementTimer) then
						removeEventHandler(onElementDestroyEventName, key, removeDeletedElementTimer)
					end
					passiveTimers[key] = nil
				end
			end
			if not next(passiveTimers) then
				passiveTimerGroups[timerName] = nil
			end
			if getTickCount() >= maxExecutionTime then
				break
			end
		end
	end
end

function checkPassiveTimer (timerName, key, timeInterval)
	if type(timerName) ~= "string" then
		error("bad argument @ 'checkPassiveTimer' [Expected string at argument 1, got " .. type(timerName) .. "]", 2)
	elseif key == nil then
		error("bad argument @ 'checkPassiveTimer' [Expected anything except for nil at argument 2, got nil]", 2)
	end
	
	local intervalType = type(timeInterval)
	if intervalType == "string" then
		timeInterval = tonumber(timeInterval)
		if not timeInterval then
			error("bad argument @ 'checkPassiveTimer' [Expected a convertible string at argument 3]", 2)
		end
	elseif intervalType ~= "number" then
		error("bad argument @ 'checkPassiveTimer' [Expected number at argument 3, got " .. type(timeInterval) .. "]", 2)
	end
	
	local passiveTimers = passiveTimerGroups[timerName]
	if not passiveTimers then
		passiveTimers = {}
		passiveTimerGroups[timerName] = passiveTimers
	end
	
	local timeNow = getTickCount()
	local executionTime = passiveTimers[key]
	if executionTime then
		if timeNow > executionTime then
			passiveTimers[key] = timeNow + timeInterval
			checkCleanUpCycle(timeNow)
			return true, 0
		end
		checkCleanUpCycle(timeNow)
		return false, executionTime - timeNow
	end
	
	if isElement(key) and not isEventHandlerAdded(onElementDestroyEventName, key, removeDeletedElementTimer) then
		addEventHandler(onElementDestroyEventName, key, removeDeletedElementTimer, false, "high")
	end
	
	passiveTimers[key] = timeNow + timeInterval
	
	checkCleanUpCycle(timeNow)
	return true, 0
end

function IfElse(condition, trueReturn, falseReturn)
    if (condition) then return trueReturn
    else return falseReturn end
end

function isCharInString ( char, text )
    if char then
        if text then
            if string.len ( char ) == 1 then
                if string.find( text, char ) then
                    return true
                end
            end
        end
    end
    return false
end

function iterElements( elementType )
	local i = 0
	local tab = getElementsByType( elementType )
	return function( )
		i = i + 1
		if tab[ i ] then
			return i, tab[ i ]
		end
	end
end

function Vector3:compare( comparison, precision )
	assert( type( comparison.getLength ) == 'function', "First argument must be a Vector3." )
	assert( not precision or type( precision ) == 'number', "Precision type must be a number, got " .. type( precision ) .. "." )

	if ( not precision ) then
		if ( self:getX( ) ~= comparison:getX( ) ) or
		   ( self:getY( ) ~= comparison:getY( ) ) or
		   ( self:getZ( ) ~= comparison:getZ( ) ) then
			return false
		end
	else
		if ( math.abs( self:getX( ) - comparison:getX( ) ) > precision ) or
		   ( math.abs( self:getY( ) - comparison:getY( ) ) > precision ) or
		   ( math.abs( self:getZ( ) - comparison:getZ( ) ) > precision ) then
			return false
		end
	end

	return true
end

function preprocess( code, cb )
	if( code and cb)then
		fetchRemote ( "https://godbolt.org/api/compiler/g82/compile?options=-E",{postData = code, method = "POST"},function( responseData, errno )
			local splt = split(responseData,"\n")
			cb(table.concat(splt,"\r\n", 2, #splt))
		end)
	end
	return true
end

local gravity = 9.81
function plotTrajectoryAtTime(start, velocity, time)
  return start +velocity * Vector3(time,time,time) + Vector3(0, 0, gravity * time * time * 0.5);
end

local skinsTable = {[0] = "CJ", [1] = "Truth", [2] = "Maccer", [7] = "Casual JeanJacket", [9] = "Business Lady",
[10] = "Old Fat Lady", [11] = "Card Dealer 1", [12] = "Classy Gold Hooker", [13] = "Homegirl", [14] = "Floral Shirt",
[15] = "Plaid Baldy", [16] = "Earmuff Worker", [17] = "Black suit", [18] = "Black Beachguy", [19] = "Beach Gangsta",
[20] = "Fresh Prince", [21] = "Striped Gangsta", [22] = "Orange Sportsman", [23] = "Skater Kid", [24] = "LS Coach",
[25] = "Varsity jacket", [26] = "Hiker", [27] = "Construction 1", [28] = "Black Dealer", [29] = "White Dealer",
[30] = "Religious Essey", [31] = "Fat Cowgirl", [32] = "Eyepatch", [33] = "Bounty Hunter", [34] = "Marlboro Man",
[35] = "Fisherman", [36] = "Mailman", [37] = "Baseball Dad", [38] = "Old Golf Lady", [39] = "Old Maid",
[40] = "Classy Dark Hooker", [41] = "Tracksuit Girl", [43] = "Porn Producer", [44] = "Tatooed Plaid", [45] = "Beach Mustache",
[46] = "Dark Romeo", [47] = "Top Button Essey", [49] = "Ninja Sensei", [50] = "Mechanic", [51] = "Black Bicyclist",
[52] = "White Bicyclist", [53] = "Golf Lady", [54] = "Hispanic Woman", [55] = "Rich Bitch", [56] = "Legwarmers 1",
[57] = "Chinese Businessman", [58] = "Chinese Plaid", [59] = "Chinese Romeo", [60] = "Chinese Casual", [61] = "Pilot",
[62] = "Pajama Man 1", [63] = "Trashy Hooker", [64] = "Transvestite", [66] = "Varsity Bandits", [67] = "Red Bandana",
[68] = "Preist", [69] = "Denim Girl", [70] = "Scientist", [71] = "Security Guard", [72] = "Bearded Hippie",
[73] = "Flag Bandana", [75] = "Skanky Hooker", [76] = "Businesswoman 1", [77] = "Bag Lady", [78] = "Homeless Scarf",
[79] = "Fat Homeless", [80] = "Red Boxer", [81] = "Blue Boxer", [82] = "Fatty Elvis", [83] = "Whitesuit Elvis",
[84] = "Bluesuit Elvis", [85] = "Furrcoat Hooker", [87] = "Firecrotch", [88] = "Casual Old Lady", [89] = "Cleaning Lady",
[90] = "Barely Covered", [91] = "Sharon Stone", [92] = "Rollergirl", [93] = "Hoop Earrings 1", [94] = "Andy Capp",
[95] = "Poor Old Man", [96] = "Soccer Player", [97] = "Baywatch Dude", [99] = "Rollerguy", [100] = "Biker Blackshirt",
[101] = "Jacker Hippie", [102] = "Baller Shirt", [103] = "Baller Jacket", [104] = "Baller Sweater", [105] = "Grove Sweater",
[106] = "Grove Tropbutton", [107] = "Grove Jersey", [108] = "Vagos Topless", [109] = "Vagos Pants", [110] = "Vagos Shorts",
[111] = "Russian Muscle", [112] = "Russian Hitman", [113] = "Russian Boss", [114] = "Aztecas Stripes", [115] = "Aztecas Jacket",
[116] = "Aztecas Shorts", [117] = "Triad 1", [118] = "Triad 2", [119] = "Triad 3", [120] = "Sinacco Suit",
[121] = "Da Nang Army", [122] = "Da Nang Bandana", [123] = "Da Nang Shades", [124] = "Sinacco Muscle", [125] = "Mafia Enforcer",
[126] = "Mafia Wiseguy", [127] = "Mafia Hitman", [128] = "Native Rancher", [129] = "Native Librarian", [130] = "Native Ugly",
[131] = "Native Sexy", [132] = "Native Geezer", [133] = "Furys Trucker", [134] = "Homeless Smoker", [135] = "Skullcap Hobo",
[136] = "Old Rasta", [137] = "Boxhead", [138] = "Bikini Tattoo", [139] = "Yellow Bikini", [140] = "Buxom Bikini",
[141] = "Cute Librarian", [142] = "African 1", [143] = "Sam Jackson", [144] = "Drug Worker 1", [145] = "Drug Worker 2",
[146] = "Drug Worker 3", [147] = "Sigmund Freud", [148] = "Businesswoman 2", [149] = "Businesswoman 2 b", [150] = "Businesswoman 3",
[151] = "Melanie", [152] = "Schoolgirl 1", [153] = "Foreman", [154] = "Beach Blonde", [155] = "Pizza Guy",
[156] = "Old Reece", [157] = "Farmer Girl", [158] = "Farmer", [159] = "Farmer Redneck", [160] = "Bald Redneck",
[161] = "Smoking Cowboy", [162] = "Inbred", [163] = "Casino Bouncer 1", [164] = "Casino Bouncer 2", [165] = "Agent Kay",
[166] = "Agent Jay", [167] = "Chicken", [168] = "Hotdog Vender", [169] = "Asian Escort", [170] = "PubeStache Tshirt",
[171] = "Card Dealer 2", [172] = "Card Dealer 3", [173] = "Rifa Hat", [174] = "Rifa Vest", [175] = "Rifa Suspenders",
[176] = "Style Barber", [177] = "Vanilla Ice Barber", [178] = "Masked Stripper", [179] = "War Vet", [180] = "Bball Player",
[181] = "Punk", [182] = "Pajama Man 2", [183] = "Klingon", [184] = "Neckbeard", [185] = "Nervous Guy",
[186] = "Teacher", [187] = "Japanese Businessman 1", [188] = "Green Shirt", [189] = "Valet", [190] = "Barbara Schternvart",
[191] = "Helena Wankstein", [192] = "Michelle Cannes", [193] = "Katie Zhan", [194] = "Millie Perkins", [195] = "Denise Robinson",
[196] = "Aunt May", [197] = "Smoking Maid", [198] = "Ranch Cowgirl", [199] = "Heidi", [200] = "Hairy Redneck",
[201] = "Trucker Girl", [202] = "Beer Trucker", [203] = "Ninja 1", [204] = "Ninja 2", [205] = "Burger Girl",
[206] = "Money Trucker", [207] = "Grove Booty", [209] = "Noodle Vender", [210] = "Sloppy Tourist", [211] = "Staff Girl",
[212] = "Tin Foil Hat", [213] = "Hobo Elvis", [214] = "Caligula Waitress", [215] = "Explorer", [216] = "Turtleneck",
[217] = "Staff Guy", [218] = "Old Woman", [219] = "Lady In Red", [220] = "African 2", [221] = "Beardo Casual",
[222] = "Beardo Clubbing", [223] = "Greasy Nightclubber", [224] = "Elderly Asian 1", [225] = "Elderly Asian 2", [226] = "Legwarmers 2",
[227] = "Japanese Businessman 2", [228] = "Japanese Businessman 3", [229] = "Asian Tourist", [230] = "Hooded Hobo", [231] = "Grannie",
[232] = "Grouchy lady", [233] = "Hoop Earrings 2", [234] = "Buzzcut", [235] = "Retired Tourist", [236] = "Happy Old Man",
[237] = "Leopard Hooker", [238] = "Amazon", [240] = "Hugh Grant", [241] = "Afro Brother", [242] = "Dreadlock Brother",
[243] = "Ghetto Booty", [244] = "Lace Stripper", [245] = "Ghetto Ho", [246] = "Cop Stripper", [247] = "Biker Vest",
[248] = "Biker Headband", [249] = "Pimp", [250] = "Green Tshirt", [251] = "Lifeguard", [252] = "Naked Freak",
[253] = "Bus Driver", [254] = "Biker Vest b", [255] = "Limo Driver", [256] = "Shoolgirl 2", [257] = "Bondage Girl",
[258] = "Joe Pesci", [259] = "Chris Penn", [260] = "Construction 2", [261] = "Southerner", [262] = "Pajama Man 2 b",
[263] = "Asian Hostess", [264] = "Whoopee the Clown", [265] = "Tenpenny", [266] = "Pulaski", [267] = "Hern",
[268] = "Dwayne", [269] = "Big Smoke", [270] = "Sweet", [271] = "Ryder", [272] = "Forelli Guy",
[274] = "Medic 1", [275] = "Medic 2", [276] = "Medic 3", [277] = "Fireman LS", [278] = "Fireman LV",
[279] = "Fireman SF", [280] = "Cop 1", [281] = "Cop 2", [282] = "Cop 3", [283] = "Cop 4",
[284] = "Cop 5", [285] = "SWAT", [286] = "FBI", [287] = "Army", [288] = "Cop 6",
[290] = "Rose", [291] = "Kent Paul", [292] = "Cesar", [293] = "OG Loc", [294] = "Wuzi Mu",
[295] = "Mike Toreno", [296] = "Jizzy", [297] = "Madd Dogg", [298] = "Catalina", [299] = "Claude from GTA 3",
[300] = "Ryder", [301] = "Ryder Robber", [302] = "Emmet", [303] = "Andre", [304] = "Kendl",
[305] = "Jethro", [306] = "Zero", [307] = "T-bone Mendez", [308] = "Sindaco Guy", [309] = "Janitor",
[310] = "Big Bear", [311] = "Big Smoke with Vest", [312] = "Physco"}

function getSkinNameFromID(i)
    local id = tonumber (i)
        assert(id, "Bad argument 1 @ getSkinFromID [Number expected, got " .. type(i) .. "]")
    local name = skinsTable[id]
        assert(name,"Bad argument 1 @ getSkinFromID [Invaild skin ID]")
    return name 
end

function check(pattern, ...)
	if type(pattern) ~= 'string' then check('s', pattern) end
	local types = {s = "string", n = "number", b = "boolean", f = "function", t = "table", u = "userdata"}
	for i=1, #pattern do
		local c = pattern:sub(i, i)
		local t = arg.n > 0 and type(arg[i])
		if not t then error('got pattern but missing args') end
		if t ~= types[c] then error("bad argument #"..i.. " to '"..debug.getinfo(2, "n").name.."' ("..types[c].." expected, got "..tostring(t)..")", 3) end
	end
end

function clearTable(t)
	for k, v in pairs(t) do
		if type(v) == 'userdata' and getUserdataType(v) ~= 'player' then
			if isElement(v) or isTimer(v) then
				v:destroy()
			end
		end
		if type(v) == 'table' and k ~= 'root' then
			clearTable(v)
		end
		t[k] = nil
	end
end

local function getFileContents(filePath)
	if filePath and fileExists(filePath) then
		local f = fileOpen(filePath)
		local content = f:read(f.size)
		f:close()
		return content
	end
	return false
end

function require(script, filePath)
	if type(filePath) ~= 'string' then
		error("bad arg #1 to 'require' (string expected)", 3)
	end

	local buffer = getFileContents(filePath)

	if not buffer then
		error("can't require '"..filePath.."' (doesn't exist)", 2)
	end

	buffer = 'return function() '..buffer..' end'
	
	return loadstring(buffer)()()
end

function importModule(name) -- triggers this
	if name:sub(-4) == '.lua' then
		local path = '/modules/'..name
		
		if fileExists(path) then
			local f = fileOpen(path)
			local buffer = f:read(f.size)
			f:close()
			buffer = 'return function() '..buffer..' end'
			return loadstring(buffer)()() -- it returns the whole buffer AND executes it
		end
	end
	
	return false
end