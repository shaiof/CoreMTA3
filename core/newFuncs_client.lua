function Script:engineReplaceCOL(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local col = engineLoadCOL(path)
		if col then
			self.cols[#self.cols+1] = col
			engineReplaceCOL(col, arg[1])
		end
	end
end

function Script:engineReplaceModel(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local dff = engineLoadDFF(path)
		if dff then
			self.dffs[#self.dffs+1] = dff
			engineReplaceModel(dff, arg[1])
		end
	end
end

function Script:engineImportTXD(...)
	local path = 'resources/'..self.name..'/'..arg[2]
	if fileExists(path) then
		local txd = engineLoadTXD(path)
		if txd then
			self.txds[#self.txds+1] = txd
			engineImportTXD(txd, arg[1])
		end
	end
end