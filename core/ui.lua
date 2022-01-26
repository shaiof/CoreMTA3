local sx, sy = guiGetScreenSize()
local dx, dy = 1366, 768

local ui = true

function absoluteToRelative(x, y, w, h)
    return x*sx/dx, y*sy/dy, w*sx/dx, h*sy/dy
end

local bx, by, bw, bh = absoluteToRelative(1060, 237, 296, 480)
local rx, ry, rw, rh = absoluteToRelative(1060, 237, 1356, 284)
local nx, ny, nw, nh = absoluteToRelative(1060, 284, 1209, 306)
local ex, ey, ew, eh = absoluteToRelative(1207, 284, 1356, 306)
local lx1, ly1, lw1, lh1 = absoluteToRelative(1063, 304, 1352, 304)
local lx2, ly2, lw2, lh2 = absoluteToRelative(1063, 285, 1352, 285)
local lx3, ly3, lw3, lh3 = absoluteToRelative(1205, 286, 1207, 680)
local tx, ty, tw, th = absoluteToRelative(1061, 695, 1356, 718)
local ix, iy, iw, ih = absoluteToRelative(1061, 665, 1356, 718)
local qx, qy, qw, qh = absoluteToRelative(1158, 760, 1280, 769)

local dx = {
    background = function() dxDrawRectangle(Vector2(bx, by), Vector2(bw, bh), tocolor(0, 0, 0, 72), false) end,
    resources = function() dxDrawText("Resources", Vector2(rx, ry), Vector2(rw, rh), tocolor(255, 255, 255, 255), 1.00, "bankgothic", "center", "center", false, false, false, false, false) end,
    name = function() dxDrawText("Name", Vector2(nx, ny), Vector2(nw, nh), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false) end,
    downloaded = function() dxDrawText("Downloaded", Vector2(ex, ey), Vector2(ew, eh), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false) end,
    line1 = function() dxDrawLine(Vector2(lx1, ly1), Vector2(lw1, lh1), tocolor(255, 255, 255, 255), 1, false) end,
    line2 = function() dxDrawLine(Vector2(lx2, ly2), Vector2(lw2, lh2), tocolor(255, 255, 255, 255), 1, false) end,
    line3 = function() dxDrawLine(Vector2(lx3, ly3), Vector2(lw3, lh3), tocolor(255, 255, 255, 255), 1, false) end,
    text = function()  dxDrawText("Toggle this window by pressing X.", Vector2(tx, ty), Vector2(tw, th), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false) end
}

local stats = getNetworkStats()
networkIn = stats.bytesReceived
networkOut = stats.bytesSent
times = 1
setTimer(function()
    local stats = getNetworkStats()
    networkIn = stats.bytesReceived
    networkOut = stats.bytesSent
    times = times + 1
end, 1000, 0)

setTimer(function()
    times = 0
end, 10000, 0)

addEventHandler("onClientRender", root, function()
    local i = 0
    if ui then
        dxDrawText("Network Usage - IN: "..math.floor((networkIn/times)/125000)..' Mbps  Out: '..math.floor((networkOut/times)/125000)..' Mbps', Vector2(ix, iy), Vector2(iw, ih), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false)
        for k, v in pairs(dx) do
            v()
        end
        if resources then
            for k, v in pairs(resources) do
                i = i + 1
                local mx, my, mw, mh = absoluteToRelative(1060, 284+(50*i), 1209, 306)
                local yx, yy, yw, yh = absoluteToRelative(1207, 284+(50*i), 1356, 306)
                dxDrawText(v.name..' ('..#v.downloadedFiles..' files)', Vector2(mx, my), Vector2(mw, mh), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false)
                if v.loaded then
                    dxDrawText('Downloaded', Vector2(yx, yy), Vector2(yw, yh), tocolor(0, 255, 0, 255), 1.00, "default", "center", "center", false, false, false, false, false)
                else
                    dxDrawText('Downloading..', Vector2(yx, yy), Vector2(yw, yh), tocolor(255, 0, 0, 255), 1.00, "default", "center", "center", false, false, false, false, false)
                end
            end
        end
    end
    dxDrawText("CoreMTA v3.0", Vector2(qx, qy), Vector2(qw, qh), tocolor(200, 200, 200, 255), 1.00, "default", "right", "bottom", false, false, false, false, false)
end)

bindKey('x', 'down', function()
    ui = not ui
end)