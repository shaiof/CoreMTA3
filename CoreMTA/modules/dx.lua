local DX = {}
local dxElements = {}
DX.__index = DX
local sx, sy = guiGetScreenSize()
local sw, sh = 1366, 768

-- absolute to relative funcs --
function dxRect(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1]/sw*sx, arg[2]/sh*sy, arg[3]/sw*sx, arg[4]/sh*sy
	return dxDrawRectangle(unpack(arg))
end

function dxImage(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1]/sw*sx, arg[2]/sh*sy, arg[3]/sw*sx, arg[4]/sh*sy
	return dxDrawImage(unpack(arg))
end

function dxText(...)
    arg[2], arg[3], arg[4], arg[5] = arg[2]/sw*sx, arg[3]/sh*sy, (arg[2] + arg[4])/sw*sx, (arg[3] + arg[5])/sh*sy
	return dxDrawText(unpack(arg))
end

function dxLine(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1]/sw*sx, arg[2]/sh*sy, arg[3]/sw*sx, arg[4]/sh*sy
	return dxDrawLine(unpack(arg))
end

-- useful funcs
function isMouseIn(x, y, w, h)
	local cx, cy = getCursorPosition()
	if cx and cy then
		cx, cy = cx*sw, cy*sh
		if cx > x and cx < x+w and cy > y and cy < y+h then
			return true
		end
	end
	return false
end

-- start of framework
function DX.new(x, y, w, h, parent)
    local self = setmetatable({}, DX)
    self.drawElements = {}
    self.x, self.y, self.w, self.h = x, y, w, h
    self.visible = true

    self.style = {}

    self.parent = parent or nil
    self.children = {}

    if self.parent then
        self.parent.children[#self.parent.children+1] = self
    else
        dxElements[#dxElements+1] = self
    end

    return self
end

function DX.createWindow(title, x, y, w, h, closeBtn, parent)
    local self = DX.new(x, y, w, h, parent)
    self.title = ' '..title
    self.titleBarHeight = 25
    
    if closeBtn then
        local closeBtn = DX.createButton('X', self.x+self.w-self.titleBarHeight, self.y, self.titleBarHeight, self.titleBarHeight, function() self.visible = false end, self)

        closeBtn.style = {-- its also not applying style here, where is it drawing the actual X text?
            backgroundColor = tocolor(255, 0, 0, 200),
            textColor = tocolor(0, 0, 0, 200),
            textAlignH = 'center',
            textAlignV = 'center',
            textFont = 'default-bold',
            textSize = 1
        }
    end

    self.style = {
        backgroundColor = tocolor(0, 0, 0, 100),
        titlebarColor = tocolor(0, 0, 0, 120),
        titleColor = tocolor(255, 255, 255, 200),
        titleAlignH = 'left',
        titleAlignV = 'center',
        titleFont = 'default',
        titleSize = 1
    }

    self.drawElements = {
        function() dxRect(self.x, self.y, self.w, self.h, self.style.backgroundColor) end,
        function() dxRect(self.x, self.y, self.w, self.titleBarHeight, self.style.titlebarColor) end,
        function() dxText(self.title, self.x, self.y, self.w, self.titleBarHeight, self.style.titleColor, self.style.titleSize, self.style.titleFont, self.style.titleAlignH, self.style.titleAlignV) end
    }

    return self
end

function DX.createButton(text, x, y, w, h, callback, parent)
    local self = DX.new(x, y, w, h, parent)
    self.text = text
    self.callback = callback or function() end

    self.style = {
        backgroundColor = tocolor(0, 0, 0, 100),
        textColor = tocolor(255, 255, 255, 200),
        textAlignH = 'center',
        textAlignV = 'center',
        textFont = 'default',
        textSize = 1
    }

    self.drawElements = { -- tell me what is self span, there fixed
        function() dxRect(self.x, self.y, self.w, self.h, self.style.backgroundColor) end,
        function() dxText(self.text, self.x, self.y, self.w, self.h, self.style.textColor, self.style.textSize, self.style.textFont, self.style.textAlignH, self.style.textAlignV) end
    }

    return self
end

function DX:draw()
    for name, draw in pairs(self.drawElements) do
        draw()
    end
end

function renderDX(dxElems)
    for i, dxElem in ipairs(dxElems) do
        if dxElem then
            if dxElem.visible then
                dxElem:draw()
                if dxElem.children[1] then
                    renderDX(dxElem.children)
                end
            end
        end
    end
end

addEventHandler('onClientRender', root, function()
    renderDX(dxElements)
end)

local window = DX.createWindow('test', 438, 162, 493, 487, true)
window.visible = false