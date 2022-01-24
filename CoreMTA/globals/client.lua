local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
        setElementCollisionsEnabled (sm.object1,false) 
	setElementCollisionsEnabled (sm.object2,false) 
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end

local cP = {
    x = 0,
    y = 0,
    move = "nil",
    timer = false,
}

function getCursorMovedOn()
    return cP.move
end

function onClientCursorMoved(cursorX, cursorY)
    if not isCursorShowing() then return end

	if cursorX > cP.x then
            cP.move = "right"
	elseif cursorX < cP.x then
	    cP.move = "left"
	elseif cursorY > cP.y then
	    cP.move = "up"
	elseif cursorY < cP.y then
	    cP.move = "down"
        end
	
	cP.x = cursorX
	cP.y = cursorY
	
	
	if isTimer(cP.timer) then
	    killTimer(cP.timer)
	end
	
	cP.timer = setTimer(function ()
		cP.move = "nil"
	    end, 50, 1
	)
end
addEventHandler("onClientCursorMove",root,onClientCursorMoved)

function dxDrawAnimWindow(text,height,width,color,font,anim)
    local x,y = guiGetScreenSize()
 
    btwidth = width
    btheight = height/20
 
    local now = getTickCount()
    local elapsedTime = now - start
    local endTime = start + 1500
    local duration = endTime - start
    local progress = elapsedTime / duration
    local x1, y1, z1 = interpolateBetween ( 0, 0, 0, width, height, 255, progress, anim)
    local x2, y2, z2 = interpolateBetween ( 0, 0, 0, btwidth, btheight, btheight/11, progress, anim)
 
    posx = (x/2)-(x1/2)
    posy = (y/2)-(y1/2)
 
    dxDrawRectangle ( posx, posy-y2, x2, y2, color )
    dxDrawRectangle ( posx, posy, x1, y1, tocolor ( 0, 0, 0, 200 ) )
    dxDrawText ( text, 0, -(y1)-y2, x, y, tocolor ( 255, 255, 255, 255 ), z2,font,"center","center")   
end

function DxDrawBorderedRectangle( x, y, width, height, color1, color2, _width, postGUI )
    local _width = _width or 1
    dxDrawRectangle ( x+1, y+1, width-1, height-1, color1, postGUI )
    dxDrawLine ( x, y, x+width, y, color2, _width, postGUI ) -- Top
    dxDrawLine ( x, y, x, y+height, color2, _width, postGUI ) -- Left
    dxDrawLine ( x, y+height, x+width, y+height, color2, _width, postGUI ) -- Bottom
    dxDrawLine ( x+width, y, x+width, y+height, color2, _width, postGUI ) -- Right
end

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    local outline = (scale or 1) * (1.333333333333334 * (outline or 1))
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top - outline, right - outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top - outline, right + outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top + outline, right - outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top + outline, right + outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top, right - outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top, right + outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top - outline, right, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top + outline, right, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end

function dxDrawDashedLine(sX, sY, eX, eY, lengthLine, lengthSpace, color, width, postGUI)
	lengthSpace = lengthSpace or lengthLine;
	color = color or tocolor(255, 255, 255, 255);
	width = width or 1;
	postGUI = postGUI or false;
	local length = getDistanceBetweenPoints2D(sX, sY, eX, eY);
	local linePartLength = lengthLine + lengthSpace;
	local lineParts = length / linePartLength;
	local xToAdd = (eX - sX) / lineParts;
	local yToAdd = (eY - sY) / lineParts;
	local lineRatio = lengthSpace / lengthLine;
	while (length > 0) do
		if (lengthLine > length) then
			dxDrawLine(sX, sY, eX, eY, color, width, postGUI);
			length = 0;
		else
			dxDrawLine(sX, sY, sX + xToAdd - xToAdd * lineRatio, sY + yToAdd - yToAdd * lineRatio, color, width, postGUI);
			sX = sX + xToAdd;
			sY = sY + yToAdd;
			length = length - linePartLength;
		end
	end
end

function dxDrawRing (posX, posY, radius, width, startAngle, amount, color, postGUI, absoluteAmount, anglesPerLine)
	if (type (posX) ~= "number") or (type (posY) ~= "number") or (type (startAngle) ~= "number") or (type (amount) ~= "number") then
		return false
	end
	
	if absoluteAmount then
		stopAngle = amount + startAngle
	else
		stopAngle = (amount * 360) + startAngle
	end
	
	anglesPerLine = type (anglesPerLine) == "number" and anglesPerLine or 1
	radius = type (radius) == "number" and radius or 50
	width = type (width) == "number" and width or 5
	color = color or tocolor (255, 255, 255, 255)
	postGUI = type (postGUI) == "boolean" and postGUI or false
	absoluteAmount = type (absoluteAmount) == "boolean" and absoluteAmount or false
	
	for i = startAngle, stopAngle, anglesPerLine do
		local startX = math.cos (math.rad (i)) * (radius - width)
		local startY = math.sin (math.rad (i)) * (radius - width)
		local endX = math.cos (math.rad (i)) * (radius + width)
		local endY = math.sin (math.rad (i)) * (radius + width)
		dxDrawLine (startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI)
	end
	return math.floor ((stopAngle - startAngle)/anglesPerLine)
end

function dxDrawTextOnRectangle(posX, posY, whidth, height, texto, fuente, cite1, cite2, color, posGui)
	dxDrawRectangle( posX, posY, whidth, height, color, posGui or false )
	dxDrawText(texto, posX, posY, whidth+posX, height+posY, tocolor(255,255,255,255), 1, fuente or "arial", cite1 or "center", cite2 or "center", false, true, posGui or false, false, false)
end

function dxDrawGifImage ( x, y, w, h, path, iStart, iType, effectSpeed )
	local gifElement = createElement ( "dx-gif" )
	if ( gifElement ) then
		setElementData (
			gifElement,
			"gifData",
			{
				x = x,
				y = y,
				w = w,
				h = h,
				imgPath = path,
				startID = iStart,
				imgID = iStart,
				imgType = iType,
				speed = effectSpeed,
				tick = getTickCount ( )
			},
			false
		)
		return gifElement
	else
		return false
	end
end

addEventHandler ( "onClientRender", root, function ( )
	local currentTick = getTickCount ( )
	for index, gif in ipairs ( getElementsByType ( "dx-gif" ) ) do
		local gifData = getElementData ( gif, "gifData" )
		if ( gifData ) then
			if ( currentTick - gifData.tick >= gifData.speed ) then
				gifData.tick = currentTick
				gifData.imgID = ( gifData.imgID + 1 )
				if ( fileExists ( gifData.imgPath .."".. gifData.imgID ..".".. gifData.imgType ) ) then
					gifData.imgID = gifData.imgID
					setElementData ( gif, "gifData", gifData, false )
				else
					gifData.imgID = gifData.startID
					setElementData ( gif, "gifData", gifData, false )
				end
			end
			dxDrawImage ( gifData.x, gifData.y, gifData.w, gifData.h, gifData.imgPath .."".. gifData.imgID ..".".. gifData.imgType )
		end
	end
end)

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x + width, y + height, z + tonumber( rotation or 0 ), material, height, color or 0xFFFFFFFF, ... )
end

local scr = {guiGetScreenSize()}
function dxDrawSprite(x, y, z, size, material, color)
    local s = size/2
    local _xc, _yc, _zc = getWorldFromScreenPosition(scr[1]/2, scr[2]/2, 1)
    local _xu, _yu, _zu = getWorldFromScreenPosition(scr[1]/2, scr[2]/2 - 240, 1)
    local _d = getDistanceBetweenPoints3D(_xc, _yc, _zc, _xu, _yu, _zu)
    local XUP,    YUP,    ZUP    = (_xu - _xc)/_d, (_yu - _yc)/_d, (_zu - _zc)/_d
    dxDrawMaterialLine3D(x+(XUP*s), y+(YUP*s), z+(ZUP*s), x-(XUP*s), y-(YUP*s), z-(ZUP*s), material, size, color)
end

function dxDrawImageOnElement(TheElement,Image,distance,height,width,R,G,B,alpha)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getElementPosition(localPlayer)
	local distance = distance or 20
	local height = height or 1
	local width = width or 1
	local checkBuildings = checkBuildings or true
	local checkVehicles = checkVehicles or false
	local checkPeds = checkPeds or false
	local checkObjects = checkObjects or true
	local checkDummies = checkDummies or true
	local seeThroughStuff = seeThroughStuff or false
	local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
	local ignoredElement = ignoredElement or nil
	if (isLineOfSightClear(x, y, z, x2, y2, z2, checkBuildings, checkVehicles, checkPeds , checkObjects,checkDummies,seeThroughStuff,ignoreSomeObjectsForCamera,ignoredElement)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawMaterialLine3D(x, y, z+1+height-(distanceBetweenPoints/distance), x, y, z+height, Image, width-(distanceBetweenPoints/distance), tocolor(R or 255, G or 255, B or 255, alpha or 255))
			end
		end
	end
end

function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	_width = _width or 1
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end

local start = getTickCount()
function dxDrawLoading (x, y, width, height, x2, y2, size, color, color2, second)
    local now = getTickCount()
    local seconds = second or 5000
	local color = color or tocolor(0,0,0,170)
	local color2 = color2 or tocolor(255,255,0,170)
	local size = size or 1.00
    local with = interpolateBetween(0,0,0,width,0,0, (now - start) / ((start + seconds) - start), "Linear")
    local text = interpolateBetween(0,0,0,100,0,0,(now - start) / ((start + seconds) - start),"Linear")
    dxDrawText ( "Loading ... "..math.floor(text).."%", x2, y2 , width, height, tocolor ( 0, 255, 0, 255 ), size, "pricedown" )
    dxDrawRectangle(x, y ,width ,height -10, color)
    dxDrawRectangle(x, y, with ,height -10, color2)
end
 
function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

function dxDrawPolygon(x, y, radius, sides, color, rotation, width)
   local last = {}
   for i=0, sides do
      local radian = math.rad( (rotation or 0) + i*(360/sides) )
      local lineX, lineY = x + radius * math.cos(radian), y + radius * math.sin(radian)
      if (last[1] and last[2]) then
         dxDrawLine(last[1], last[2], lineX, lineY, color, width or 1)
      end
      last[1], last[2] = lineX, lineY
   end
end

local dot = dxCreateTexture(1,1)
local white = tocolor(255,255,255,255)
function dxDrawRectangle3D(x,y,z,w,h,c,r,...)
        local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, dot, h, c or white, ...)
end

local unlerp = function(from,to,lerp) return (lerp-from)/(to-from) end
 
function dxDrawProgressBar( startX, startY, width, height, progress, color, backColor )
    local progress = math.max( 0, (math.min( 100, progress) ) )
    local wBar = width*.18
    for i = 0, 4 do
        --back
        local startPos = (wBar*i + (width*.025)*i) + startX
        dxDrawRectangle( startPos, startY, wBar, height, backColor )
        --progress
        local eInterval = (i*20)
        local localProgress = math.min( 1, unlerp( eInterval, eInterval + 20, progress ) )
        if localProgress > 0 then
            dxDrawRectangle( startPos, startY, wBar*localProgress, height, color )
        end
    end
end

function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font,...)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or 20
	local height = height or 1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or "arial", "center", "center")
			end
		end
	end
end

function dxDrawTriangle(x, y, width, height, color, _width, postGUI)
	if (type(x) ~= "number") or (type(y) ~= "number") then
		return false
	end

	_width = (type( _width ) == "number" and _width) or 1
	color = color or tocolor( 255, 255, 255, 200 )
	postGUI = (type( postGUI ) == "boolean" and postGUI) or false

	dxDrawLine ( x+width/2, y, x, y+height, color, _width, postGUI ) 
	dxDrawLine ( x+width/2, y, x+width, y+height, color, _width, postGUI )
	return dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI )
end

function dxGetFontSizeFromHeight( height, font )
    if type( height ) ~= "number" then return false end
    font = font or "default"
    local ch = dxGetFontHeight( 1, font )
    return height/ch
end

function dxGetRealFontHeight(font)
    local cap,base = measureGlyph(font, "S")
    local median,decend = measureGlyph(font, "p")
    local ascend,base2 = measureGlyph(font, "h")

    local ascenderSize = median - ascend
    local capsSize = median - cap
    local xHeight = base - median
    local decenderSize = decend - base

    return math.max(capsSize,ascenderSize) + xHeight + decenderSize
end

function measureGlyph(font, character)
    local rt = dxCreateRenderTarget(128,128)
    dxSetRenderTarget(rt,true)
    dxDrawText(character,0,0,0,0,tocolor(255,255,255),1,font)
    dxSetRenderTarget()
    local pixels = dxGetTexturePixels(rt)
    local first,last = 127,0
    for y=0,127 do
        for x=0,127 do
            local r = dxGetPixelColor( pixels,x,y )
            if r > 0 then
                first = math.min( first, y )
                last = math.max( last, y )
                break
            end
        end
        if last > 0 and y > last+2 then break end
    end
    destroyElement(rt)
    return first,last
end

function wordWrap(text, maxwidth, scale, font, colorcoded)
    local lines = {}
    local words = split(text, " ") -- this unfortunately will collapse 2+ spaces in a row into a single space
    local line = 1 -- begin with 1st line
    local word = 1 -- begin on 1st word
    local endlinecolor
    while (words[word]) do -- while there are still words to read
        repeat
            if colorcoded and (not lines[line]) and endlinecolor and (not string.find(words[word], "^#%x%x%x%x%x%x")) then -- if on a new line, and endline color is set and the upcoming word isn't beginning with a colorcode
                lines[line] = endlinecolor -- define this line as beginning with the color code
            end
            lines[line] = lines[line] or "" -- define the line if it doesnt exist

            if colorcoded then
                local rw = string.reverse(words[word]) -- reverse the string
                local x, y = string.find(rw, "%x%x%x%x%x%x#") -- and search for the first (last) occurance of a color code
                if x and y then
                    endlinecolor = string.reverse(string.sub(rw, x, y)) -- stores it for the beginning of the next line
                end
            end
      
            lines[line] = lines[line]..words[word] -- append a new word to the this line
            lines[line] = lines[line] .. " " -- append space to the line

            word = word + 1 -- moves onto the next word (in preparation for checking whether to start a new line (that is, if next word won't fit)
        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font, colorcoded) > maxwidth) -- jumps back to 'repeat' as soon as the code is out of words, or with a new word, it would overflow the maxwidth
    
        lines[line] = string.sub(lines[line], 1, -2) -- removes the final space from this line
        if colorcoded then
            lines[line] = string.gsub(lines[line], "#%x%x%x%x%x%x$", "") -- removes trailing colorcodes
        end
        line = line + 1 -- moves onto the next line
    end -- jumps back to 'while' the a next word exists
    return lines
end

function dxDrawRombo(x,y,w,tocolor)
    local i = 1;
    while (w-i*2) > 0 do
        dxDrawRectangle(x+i,y-i,w-i*2,1,tocolor)
        dxDrawRectangle(x+i,y+i-1,w-i*2,1,tocolor)
        i = i + 1
    end
end

local attachedEffects = {}
function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z  -- Return the transformed point
end

function attachEffect(effect, element, pos)
	attachedEffects[effect] = { effect = effect, element = element, pos = pos }
	addEventHandler("onClientElementDestroy", effect, function() attachedEffects[effect] = nil end)
	addEventHandler("onClientElementDestroy", element, function() attachedEffects[effect] = nil end)
	return true
end

addEventHandler("onClientPreRender", root, 	function()
	for fx, info in pairs(attachedEffects) do
		local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)
		setElementPosition(fx, x, y, z)
	end
end)

function isElementInPhotograph(ele)
	local nx, ny, nz = getPedWeaponMuzzlePosition(localPlayer)
	if (ele ~= localPlayer) and (isElementOnScreen(ele)) then -- Determine whether the element is even on the screen and not the client
		local px, py, pz = getElementPosition(ele)
		local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and the element
		if (hit == ele) then -- If it collides with the element return true
			return true
		end
	end

	return false
end

function isElementWithinAColShape(element)
	local element = element or localPlayer
	if element or isElement(element)then
		for _,colshape in ipairs(getElementsByType("colshape"))do
			if isElementWithinColShape(element,colshape) then
				return colshape
			end
		end
	end
	return false
end

armedVehicles = {[425]=true, [520]=true, [476]=true, [447]=true, [430]=true, [432]=true, [464]=true, [407]=true, [601]=true}
function vehicleWeaponFire(key, keyState, vehicleFireType)
	local vehModel = getElementModel(getPedOccupiedVehicle(localPlayer))
	if (armedVehicles[vehModel]) then
		triggerEvent("onClientVehicleWeaponFire", localPlayer, vehicleFireType, vehModel)
	end
end
bindKey("vehicle_fire", "down", vehicleWeaponFire, "primary")
bindKey("vehicle_secondary_fire", "down", vehicleWeaponFire, "secondary")

local controls = { "fire", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
 "change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "aim_weapon", "conversation_yes", "conversation_no",
 "group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
 "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
 "handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
 "special_control_down", "special_control_up" }

local boundControlsKeys = {}
local bindsData = {}

function unbindControlKeys(control)
    -- Ensure the argument has got the appropiate type
    assert(type(control) == "string", "Bad argument @ unbindControlKeys [string expected, got " .. type(control) .. "]")
    -- Check if we have a valid control
    local validControl
    for _, controlComp in ipairs(controls) do
        if control == controlComp then
            validControl = true
            break
        end
    end
    assert(validControl, "Bad argument @ unbindControlKeys [Invalid control name]")
    -- Have we got a bind on this control?
    assert(boundControlsKeys[control], "Bad argument @ unbindControlKeys [There is no bind on such control]")
    -- Unbind each key of the control
    for _, bindData in pairs(bindsData[control]) do
        unbindKey(unpack(bindData))
    end
    -- Remove references
    boundControlsKeys[control] = nil
    bindsData[control] = nil
    return true
end

function bindControlKeys(control, ...)
    -- Ensure the argument has got the appropiate type
    assert(type(control) == "string", "Bad argument 1 @ bindControlKeys [string expected, got " .. type(control) .. "]")
    -- Check if we have a valid control
    local validControl
    for _, controlComp in ipairs(controls) do
        if control == controlComp then -- Is the specified control in the table?
            validControl = true -- If so, it's a valid control
            break
        end
    end
    assert(validControl, "Bad argument 1 @ bindControlKeys [Invalid control name]")
    -- Do we already have this control bound?
    if boundControlsKeys[control] then
        unbindControlKeys(control) -- Delete the first control keys bind
    end
    boundControlsKeys[control] = getBoundKeys(control) -- Store the keys of that control that will be bound
    bindsData[control] = {} -- Store bind data, so we can unbind each key of the control later
    for key in pairs(boundControlsKeys[control]) do
        -- Can we bind the key with the specified arguments?
        assert(bindKey(key, unpack(arg)), "Bad arguments @ bindControlKeys [Could not create key bind]")
        -- If so, register the bind data and continue
        table.insert(bindsData[control], { key, unpack(arg) })
    end
    return true
end

-- The keys bound to a control can be changed in Settings. The next function updates the binds properly in that case.
-- Also note that the next function IS NOT MEANT to be exported or called by the script.
local function keepControlKeyBindsAccurate()
    if next(boundControlsKeys) then -- Have we got any control keys bound?
        for boundControl, boundKeys in pairs(boundControlsKeys) do
            if toJSON(boundKeys) ~= toJSON(getBoundKeys(boundControl)) then -- Have we changed the keys bound to a control?
                -- Update our custom control bind
                for _, bindData in ipairs(bindsData[boundControl]) do
                    unbindKey(unpack(bindData)) -- Unbind every key of that cotnrol that we have bound before
                    -- Bind again the appropiate keys
                    for key in pairs(getBoundKeys(boundControl)) do
                        local bindDataNoKey = bindData -- Copy bindData into another variable
                        table.remove(bindDataNoKey, 1) -- Ignore the key of our bindData
                        bindKey(key, unpack(bindDataNoKey)) -- Bind again the data, but with the updated key
                        bindData[1] = key -- Update the key in the references
                    end
                end
                boundControlsKeys[boundControl] = getBoundKeys(boundControl) -- Update the control bound keys list
            end
        end
    end
end
addEventHandler("onClientRender", root, keepControlKeyBindsAccurate)

function getBoundControls (key)
    local conts = {}
    for _,control in ipairs(controls) do
        for k in pairs(getBoundKeys(control)) do
            if (k == key) then
                conts[control] = true
            end
        end
    end
    return conts
end

local jsSource = [[
	var inputElement = document.createElement('input');
	document.body.appendChild(inputElement);
	inputElement.focus();
	inputElement.onpaste = function() {
		inputElement.value = '';
		setTimeout(function() {
			mta.triggerEvent('returnClipBoardValue',inputElement.value);
		}, 10);
	};
]];

local browser = createBrowser(1,1,true,false)

addEvent('returnClipBoardValue',false)

addEventHandler('returnClipBoardValue',browser,function (data)
	triggerEvent('returnClipBoard',root,data)
end)

addEventHandler("onClientBrowserCreated",browser,function()
	loadBrowserURL(browser,'http://mta/nothing')
	focusBrowser(browser)
end)

addEventHandler("onClientBrowserDocumentReady",browser,function()
	executeBrowserJavascript(browser, jsSource)
end)

addEventHandler('onClientKey',root,function(key,state)
    if state then
        if (getKeyState('rctrl') or getKeyState('lctrl')) and (getKeyState('v') or getKeyState("V")) then
            cancelEvent()
        end
    end
end)

addEvent("playTTS", true)
local function playTTS(text, lang)
    local URL = "http://translate.google.com/translate_tts?tl="..lang.."&q="..text.."&client=tw-ob"
    return true, playSound(URL), URL
end
addEventHandler("playTTS", root, playTTS)

function getScreenRotationFromWorldPosition( targetX, targetY, targetZ )
    local camX, camY, _, lookAtX, lookAtY = getCameraMatrix()
    local camRotZ = math.atan2 ( ( lookAtX - camX ), ( lookAtY - camY ) )
    local dirX = targetX - camX
    local dirY = targetY - camY
    local dirRotZ = math.atan2(dirX,dirY)
    local relRotZ = dirRotZ - camRotZ
    return math.deg(relRotZ)
end

function centerWindow (center_window)
    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = guiGetSize(center_window, false)
    local x, y = (screenW - windowW) /2,(screenH - windowH) /2
    return guiSetPosition(center_window, x, y, false)
end

local table_ = {}
function guiMoveElement ( element, speed, x, y, type_ )
	local type_ = type_ or "Linear"
	if isElement ( element ) and tonumber ( speed ) and tonumber ( x ) and tonumber ( y ) and tostring ( type_ ) then
		if isElement ( getElementData ( element, "object" ) ) then
			local object = getElementData ( element, "object" )
			moveObject ( object, speed, x, y, -999, 0, 0, 0, type_ )
			local destroy = function ( old_object, old_gui )
				if isElement ( old_object ) then
					destroyElement ( old_object )
				end
				for i, gui_elements in ipairs ( table_ ) do
					if gui_elements[1] == old_gui then
						table.remove ( table_, i )
					end
				end
			end
			setTimer ( destroy, speed, 1, object, gui_element )
		else
			local p = { guiGetPosition ( element, false ) }
			local object = createObject ( 902, p[1], p[2], -999 )
			setElementData ( element, "object", object )
			setElementAlpha ( object, 0 )
			table.insert ( table_, (#table_)+1, { element, object } )
			guiMoveElement ( element, speed, x, y, type_ )
		end
	end
end

local function r ()
	for i, gui_element in ipairs ( table_ ) do
		if isElement (gui_element[1]) and isElement (gui_element[2]) then
			local x, y = getElementPosition ( gui_element[2] )
			guiSetPosition ( gui_element[1], x, y, false )
		end
	end
end
addEventHandler ( "onClientRender", root, r )

function isMouseOnGUICloseButton (guiElement)
	if (isElement (guiElement)) and (getElementType (guiElement) == "gui-window") then
		if (guiGetProperty (guiElement, "CloseButtonEnabled") == "True") and (guiGetProperty (guiElement, "TitlebarEnabled") == "False") then
			local cX, cY = getCursorPosition()
			local sX, sY = guiGetScreenSize ()
			local cX, cY = (cX * sX), (cY * sY)
			local sizeX, sizeY = guiGetSize (guiElement, false)
			local posX, posY = guiGetPosition (guiElement, false)
			if (cX >= (posX + sizeX - 14)) and (cX <= (posX + sizeX - 9)) and (cY >= (posY + 8)) and (cY <= (posY + 15)) then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function guiSetStaticImageMovable(Element,state)
	assert(getElementType(Element) == 'gui-staticimage', "Bad argument 1 @ guiSetStaticImageMovable [gui-staticimage expected, got "..getElementType(Element).."]")
	assert(type(state) == "boolean", "Bad argument 2 @ guiSetStaticImageMovable [boolean expected, got "..type(state).."]")
	if state == true then state = math.random(1,500) else state = false end
	return guiSetProperty(Element,"ID",tostring(state))
end

function Hold( t,x,y )
	if t == "left" and guiGetProperty(source,'ID') ~= '0' then
		local lp = Vector2(guiGetPosition(source,false))
		lx = {x-lp.x,y-lp.y}
		yl = source
	end
end

function Drop( xo, x, y )
	if xo ~= "left" then return end
	yl = nil
end

function Move( _, _, x, y )
	if yl then
		guiSetPosition(yl,x-lx[1],y -lx[2],false)
	end
end
addEventHandler( "onClientGUIMouseDown", root,Hold)
addEventHandler( "onClientGUIMouseUp", root,Drop)
addEventHandler( "onClientCursorMove", root,Move)

function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end

function guiGridListAddPlayers( GridList, Column, Section, Number )
	if ( GridList and getElementType( GridList ) ~= "gui-gridlist" ) then
		error("Bad argument @ 'guiGridListAddPlayers' [Expected gridlist at argument 1, got " .. tostring(GridList) .. "]")
	end
	assert( tonumber( Column ), "Bad argument @ 'guiGridListAddPlayers' [Expected number at argument 2, got " .. tostring(Column) .. "]" )
	if ( type(Section) ~= "boolean" ) then
		error("Bad argument @ 'guiGridListAddPlayers' [Expected boolean at argument 3, got " .. tostring(Section) .. "]")
	end
	if ( type(Number) ~= "boolean" ) then
		error("Bad argument @ 'guiGridListAddPlayers' [Expected boolean at argument 4, got " .. tostring(Number) .. "]")
	end
	guiGridListClear( GridList )
	for _, player in ipairs( getElementsByType('player') ) do
		local Row = guiGridListAddRow( GridList )
		guiGridListSetItemText( GridList, Row, Column, getPlayerName(player), Section, Number )
	end
end

function guiGridListGetColumnIDFromTitle(gridlist, title)
	for id=1, guiGridListGetColumnCount(gridlist) do
		if guiGridListGetColumnTitle(gridlist, id) == title then
			return id
		end
	end
	return false
end

function guiGridListSetColumnNonSortable (guiElement, columnID)
    if (not guiElement) or (getElementType (guiElement) ~= "gui-gridlist") or (not columnID) or (not guiGridListGetColumnWidth (guiElement, columnID, false)) then return false end
    local columns = guiGridListGetColumnCount (guiElement)
    local size = 0
    for i=1, columns do
        if (i == columnID) then
            local guiLock = guiCreateButton (size, 0, guiGridListGetColumnWidth (guiElement, columnID, false), 25, "", false, guiElement)
            guiSetProperty (guiLock, "AlwaysOnTop", "True")
            guiSetAlpha (guiLock, 0)
            return true
        else
            size = size + guiGridListGetColumnWidth (guiElement, i, false)
        end
    end
end

function guiGridListSetColumnsFixedWidth (guiElement)
    if (not guiElement) or (getElementType (guiElement) ~= "gui-gridlist") then return false end
    local columns = guiGridListGetColumnCount (guiElement)
    local guiLocks = {}
    for i=1, columns do
        local size = guiGridListGetColumnWidth (guiElement, i, false)
        if (guiLocks[i-1]) then
            size = size + guiGetPosition (guiLocks[i-1], false)
        end
        guiLocks[i] = guiCreateButton (size, 0, 10, 25, "", false, guiElement)
        guiSetProperty (guiLocks[i], "AlwaysOnTop", "True")
        guiSetAlpha (guiLocks[i], 0)
    end
    return true
end

function guiGridListGetSelectedText(gridList, columnIndex)
    local selectedItem = guiGridListGetSelectedItem(gridList)
    if (selectedItem) and (selectedItem ~= -1) then
        local text = guiGridListGetItemText(gridList, selectedItem, columnIndex or 1)
        if (text) and not (text == "") then
            return text
        end
    end
    return false
end

function getGridListRowIndexFromText(gridList, text, column)
	for i=0, guiGridListGetRowCount(gridList)-1 do
		if (guiGridListGetItemText(gridList, i, column) == text) then
			return i
		end
	end
	return false
end

function isTextInGridList(gridlist, text, column)
    for i=0, guiGridListGetRowCount(gridlist)-1 do
		local t = guiGridListGetItemText(gridlist, i, column)
	    if ( t and t == text ) then
			return true
		end
	end
    return false
end

function convertGridListToText ( gridlist )
	if not gridlist or getElementType ( gridlist ) ~= "gui-gridlist" then return false end
	local colCount, rowCount = guiGridListGetColumnCount ( gridlist ), guiGridListGetRowCount ( gridlist )
	if colCount == 0 or rowCount == 0 then return false end
	local storing = { row = {}, col = {} };
	for i=1, colCount do 
		table.insert ( storing.col, { id = i, text = guiGridListGetColumnTitle ( gridlist, i ) } ) 
	end
	for i=0, rowCount do 
		for index, value in ipairs ( storing.col ) do
			local message = guiGridListGetItemText ( gridlist, i, value.id )
			table.insert ( storing.row, { col = value.id, rows = i, message = message } )
		end
	end	
	for i, v in ipairs ( storing.col ) do
		text = ( ( i > 1 and text ) or "" )..v.text..( ( i < #storing.col and "    |    " ) or "\n" );
	end
	text = text..("-"):rep(colCount*13).."\n"
	for i, v in ipairs ( storing.row ) do
		text = text..( ( v.rows >= rowCount and "" ) or ( v.col > 1 and "    |    " ) or "" )..v.message..( ( v.col >= #storing.col and v.rows < rowCount and "\n" ) or "" )
	end
	return text.."\nColumns: "..colCount.."\nRows: "..rowCount.."\nValues: "..#storing.row
end

function guiLabelAddEffect(label, effect)
	local nlab = {}
	local checkTimer = {}
	if label and getElementType(label) == "gui-label" then
		if effect and tostring(effect) and effect:len() > 3 then
			local position = { guiGetPosition(label, false) }
			local size = { guiGetSize(label, false) }
			if effect:lower() == "shadow" then
				nlab[1] = guiCreateLabel(position[1] + 1, position[2] + 1, size[1] + 1, size[2] + 1, guiGetText(label), false, getElementParent(label) and getElementParent(label) or nil)
				guiLabelSetColor(nlab[1], 0, 0, 0)
			elseif effect:lower() == "outline" then
				for i = 1, 4 do
					x, y, w, h = (i == 1 or i == 2 and 1 or -1), (i == 1 or i == 3 and 1 or -1), (i == 1 or i == 2 and 1 or -1), (i == 1 or i == 3 and 1 or -1)
					nlab[i] = guiCreateLabel(position[1] + x, position[2] + y, size[1] + w, size[2] + h, guiGetText(label), false, getElementParent(label) and getElementParent(label) or nil)
					guiLabelSetColor(nlab[i], 0, 0, 0)
				end
			end
		end
	end
	if #nlab > 0 then
		if label then
			if isTimer(checkTimer[label]) then killTimer(checkTimer[label]) end
			checkTimer[label] = setTimer(function()
				for _,nlabel in ipairs(nlab) do
					guiSetVisible(nlabel, guiGetVisible(label))
				end
				if not isElement(label) then
					killTimer(checkTimer[label])
					for i = 1, #nlab do
						destroyElement(nlab[i])
					end
				end
			end, 100, 0)
		end
		if #nlab == 1 then
			return nlab[1]
		elseif #nlab == 4 then
			return nlab[1], nlab[2], nlab[3], nlab[4]
		end
	else
		return false
	end
end

function getAlivePlayers()
	local alivePlayers = { }
	for i,p in ipairs (getElementsByType("player")) do
		if getElementHealth(p) > 0 then
			table.insert(alivePlayers,p)
		end 
	end
	return alivePlayers
end

function getPedEyesPosition (ped)
	if not ped then return false end
	if not isElement(ped) then return false end 
	if getElementType(ped) ~= "ped" and getElementType(ped) ~= "player" then return false end 
	local x,y,z = getPedBonePosition(ped, 7) -- left eye
	local x2,y2,z2 = getPedBonePosition(ped, 6) -- right eye
	return {{x,y,z},{x2,y2,z2}}
end

function getPlayersInPhotograph()
	local players = {}
	local nx, ny, nz = getPedWeaponMuzzlePosition(localPlayer)
	
	for _, v in ipairs(getElementsByType"player") do
		if (v ~= localPlayer) and (isElementOnScreen(v)) then
			local veh = getPedOccupiedVehicle(v)
			local px, py, pz = getElementPosition(v)
			local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and the player
			local continue = false
			
			if (hit == v) or (hit == veh) or (not veh) then -- If it collides with the player itself, the client or the players vehicle, continue to add player to the list.
				continue = true
			else -- This checks if the player's head is visible, but not the entire body
				local bx, by, bz = getPedBonePosition(v, 8) -- Get the head position of the player
				local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and player head.
				
				if hit == v then
					continue = true
				end
			end
			
			if continue then
				table.insert(players, v)
			end
		end
	end
	
	return players
end

function isPedAiming (thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end

function isPedAimingNearPed ( thePed, theElement, range )
	if isElement(thePed) and isElement(theElement) and type(range) == "number" then
		if (getElementType(thePed) == "player" or getElementType(thePed) == "ped") then
			local x, y, z = getElementPosition(theElement)
			local col = createColTube(x, y, z-1, range, 2)
			attachElements(col, theElement)
			if getPedTask(thePed, "secondary", 0) == "TASK_SIMPLE_USE_GUN" and getPedTarget(thePed) == theElement and isElementWithinColShape(thePed, col) then
				return true
			end
		end
	end
	return false
end

function isSoundFinished(theSound)
    return ( getSoundPosition(theSound) == getSoundLength(theSound) )
end

function stopSoundSlowly (sElement)
    if not isElement(sElement) then return false end
    local sound_timer_quant = getSoundVolume(sElement)
    local slowlyStop = setTimer(function ()
        local soundVolume = getSoundVolume(sElement)
        setSoundVolume(sElement,soundVolume - 0.5)
		if soundVolume >= 0 then stopSound(sElement) end
	end,400,sound_timer_quant*2)
end


function playVideo (posX, posY, width, height, url, duration, canClose, postGUI)
	if not posX or not posY or not width or not height or not url then
		return false
	end
	local webBrowser = false
	closeButton = guiCreateButton (0.97, 0, 0.03, 0.03, "X", true)
	guiSetAlpha (closeButton, 0.5)
	guiSetVisible (closeButton, false)
	if not isElement (webBrowser) then
		webBrowser = createBrowser (width, height, false, false)
		function createVideoPlayer ()
			function webBrowserRender ()
				dxDrawImage (posX, posY, width, height, webBrowser, 0, 0, 0, tocolor(255,255,255,255), postGUI)
			end
			loadBrowserURL (webBrowser, url)
			
			setTimer (function()
				addEventHandler ("onClientRender", getRootElement(), webBrowserRender)
				showChat (false)
				if canClose then
					guiSetVisible (closeButton, true)
					showCursor (true)
				end
			end, 500, 1)
			setElementFrozen (localPlayer, true)
			if duration then
				videoTimer = setTimer (function()
					removeEventHandler ("onClientRender", getRootElement(), webBrowserRender)
					setElementFrozen (localPlayer, false)
					guiSetVisible (closeButton, false)
					showCursor (false)
					showChat (true)
					destroyElement (webBrowser)
				end, duration, 1)
			end
			
			addEventHandler ("onClientGUIClick", closeButton, function (button, state)
				if button == "left" then
					if isTimer (videoTimer) then
						killTimer (videoTimer)
						videoTimer = nil
						removeEventHandler ("onClientRender", getRootElement(), webBrowserRender)
						setElementFrozen (localPlayer, false)
						guiSetVisible (closeButton, false)
						showCursor (false)
						showChat (true)
						destroyElement (webBrowser)
					end
				end
			end, false)
		end
		setTimer (createVideoPlayer, 500, 1)
	end
end

function setVehicleGravityPoint( targetVehicle, pointX, pointY, pointZ, strength )
	if isElement( targetVehicle ) and getElementType( targetVehicle ) == "vehicle" then
		local vehicleX,vehicleY,vehicleZ = getElementPosition( targetVehicle )
		local vectorX = vehicleX-pointX
		local vectorY = vehicleY-pointY
		local vectorZ = vehicleZ-pointZ
		local length = ( vectorX^2 + vectorY^2 + vectorZ^2 )^0.5
		
		local propX = vectorX^2 / length^2
		local propY = vectorY^2 / length^2
		local propZ = vectorZ^2 / length^2
		
		local finalX = ( strength^2 * propX )^0.5
		local finalY = ( strength^2 * propY )^0.5
		local finalZ = ( strength^2 * propZ )^0.5
		
		if vectorX > 0 then finalX = finalX * -1 end
		if vectorY > 0 then finalY = finalY * -1 end
		if vectorZ > 0 then finalZ = finalZ * -1 end
		
		return setVehicleGravity( targetVehicle, finalX, finalY, finalZ )
	end
	return false
end

function getVehicleTurnVelocityCenterOfMass(veh)
	assert(isElement(veh),"Bad argument @getVehicleTurnVelocityCenterOfMass at argument 1, except a vehicle got "..type(veh))
	assert(getElementType(veh)=="vehicle","Bad argument @getVehicleTurnVelocityCenterOfMass at argument 1, except a vehicle got "..getElementType(veh))
	local tx,ty,tz = getElementAngularVelocity(veh)
	local matrix = veh.matrix
	local turnV = Vector3(tx,ty,tz)
	local front = matrix:getForward()
	local right = matrix:getRight()
	local up = matrix:getUp()
	local frontV = turnV:dot(front)/front:getLength()
	local rightV = turnV:dot(right)/right:getLength()
	local upV = turnV:dot(up)/up:getLength()
	return rightV,frontV,upV
end

function setVehicleTurnVelocityCenterOfMass(veh,tx,ty,tz)
	assert(isElement(veh), "Bad argument @setVehicleTurnVelocityCenterOfMass at argument 1, except a vehicle got "..type(veh))
	assert(getElementType(veh) == "vehicle", "Bad argument @setVehicleTurnVelocityCenterOfMass at argument 1, except a vehicle got "..getElementType(veh))
	local matrix = veh.matrix
	local turnV = matrix:transformPosition(Vector3(tx,ty,tz))-matrix.position
	veh.turnVelocity = turnV
end

local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function animate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end)

function callClientFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onServerCallsClientFunction", true)
addEventHandler("onServerCallsClientFunction", resourceRoot, callClientFunction)

function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerServerEvent("onClientCallsServerFunction", resourceRoot , funcname, unpack(arg))
end

local fps = 0
function getCurrentFPS()
    return fps
end

local function updateFPS(msSinceLastFrame)
    fps = (1 / msSinceLastFrame) * 1000
end
addEventHandler("onClientPreRender", root, updateFPS)

function isMouseInCircle(x, y, r)
	local sx, sy = guiGetScreenSize( )
    if isCursorShowing( ) then
        local cx, cy = getCursorPosition( )
        local cx, cy = cx*sx, cy*sy
        return (x-cx)^2+(y-cy)^2 <= r^2
    end
    return false
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function isCursorOverText(posX, posY, sizeX, sizeY)
	if ( not isCursorShowing( ) ) then
		return false
	end
	local cX, cY = getCursorPosition()
	local screenWidth, screenHeight = guiGetScreenSize()
	local cX, cY = (cX*screenWidth), (cY*screenHeight)

	return ( (cX >= posX and cX <= posX+(sizeX - posX)) and (cY >= posY and cY <= posY+(sizeY - posY)) )
end