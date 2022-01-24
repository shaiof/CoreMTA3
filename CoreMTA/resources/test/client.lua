local enabled = false
local slow, norm, fast = 0.3, 3, 16
local state = getPedControlState

function toggle()
	local elem = localPlayer.vehicle or localPlayer
	enabled = not enabled
	elem.collisions = not enabled
	elem.frozen = enabled
	Camera.setClip(not enabled, not enabled)
	if (enabled) then
		iprint('noclipiing', root)
		addEventHandler('onClientRender', root, noclip)
	else
		removeEventHandler('onClientRender', root, noclip)
	end
end
addCommandHandler('noclip', toggle, false, false)

function busy()
	return isChatBoxInputActive() or isConsoleActive() or isCursorShowing() or isMainMenuActive() or isChatBoxInputActive()
end

function noclip()
	local cam = Camera.matrix.rotation
	local veh = localPlayer.vehicle
	local x, y, z = 0, 0, 0
	local speed = getKeyState('lalt') and slow or norm
	local speed = getKeyState('lshift') and fast or speed
	x = (veh and state('vehicle_left') or state('left')) and -speed or x
	x = (veh and state('vehicle_right') or state('right')) and speed or x
	y = (veh and state('accelerate') or state('forwards')) and speed or y
	y = (veh and state('brake_reverse') or state('backwards')) and -speed or y
	if not busy() then
		z = getKeyState('mouse2') and speed or z
		z = getKeyState('mouse1') and -speed or z
	end
	print(cam)
	if (veh) then
		veh:setRotation(cam.x, 0, cam.z)
		print(veh)
		veh:transform('pos', Vector3(x, y, z))
	else
		localPlayer:setRotation(-cam.x, 0, cam.z)
		localPlayer:transform('pos', Vector3(x, y, z))
	end
	dxDrawText("noclipping: " .. tostring(enabled), 0,0,0,0, 1.15)
end

-- iprint(Vehicle)

function Player:transform(_type, x, y, z)
	if (_type == 'pos' and x) then
		self:setPosition(self.matrix:transformPosition(x, y or 0, z or 0))
	elseif (_type == 'rot' and x) then
		self:setRotation(self.rotation + Vector3(x, y or 0, z or 0))
	end
end

function Vehicle:transform(_type, x, y, z)
	print('transforming')
	if (_type == 'pos' and x) then
		self:setPosition(self.matrix:transformPosition(x, y or 0, z or 0))
	elseif (_type == 'rot' and x) then
		self:setRotation(self.rotation + Vector3(x, y or 0, z or 0))
	end
end
