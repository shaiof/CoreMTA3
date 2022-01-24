local c = 0
setTimer(function()
    c = c+1
    outputChatBox(c)
end,1000,0)

bindKey('e','down',function()
	outputChatBox('other test')
end)

local txd = engineLoadTXD(602, 'broadway.txd')
local dff = engineLoadModel(602, 'broadway.dff')