for k, player in pairs(getElementsByType('player')) do
    bindKey(player, 'c', 'up', function()
        local veh = Vehicle(411, player.position, player.rotation)
    end)
end
