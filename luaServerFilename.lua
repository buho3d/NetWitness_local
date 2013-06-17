--[[
HTTP Server Filename Parser

Parser Returns the following Meta

server.filename -- Captures the filename returned in the Content-Disposition Server Header.

Parser requires the following Index Keys to be added to the Custom Indexes.
	=Decoder=
	<key description="Server Filename" level="IndexNone" name="server.filename" format="Text" />

	=Concentrator/Broker/Investigator=
	<key description="Server Filename" level="IndexValues" name="server.filename" format="Text" valueMax="2000000"/>

Server filename samples:
Content-Disposition: inline; filename="kinopo.jar"
Content-Disposition: attachment; filname=blah.bin
Content-Disposition: inline; filename=21b.exe
	
21May2013	stephen.brzozowski@rsa.com	Initial Development
--]]

local luaServerFilename = nw.createParser("Server_Filename", "Server_Filename")

-- declare the meta keys we'll be registering meta with
luaServerFilename:setKeys({
	nwlanguagekey.create("server.filename"),
	--nwlanguagekey.create("alert"),
})

function luaServerFilename:tokenContentDisposition(token, first, last)
	-- set position to byte after the token
	current_position = last + 1
	-- get the payload
	local payload = nw.getPayload()
	
	-- find the next semicolon
	local num_temp = payload:find(";", current_position, current_position + 4096)
	-- if we found that
	if num_temp then
	
		--Check Content-Disposition Type (Inline or Attachment)
		
		-- we don't want to read the ;
		num_temp = num_temp - 1
		
		
		local condis_type = payload:tostring(current_position, num_temp)
		-- make sure the read succeeded
		if condis_type then
			if condis_type:lower() == "inline" then
				--It's inline
				--nw.logInfo('###' .. condis_type .. '###')
			end
			if condis_type:lower() == "attachment" then
				--It's attachment
				--nw.logInfo('###' .. condis_type .. '###')
			end
			
			-- Move forward
			current_position = num_temp + 2
			
			num_temp = nil
			num_temp = payload:find("=", current_position, current_position + 4096)
			if num_temp then
				local end_of_line = payload:find("\r\n", num_temp, num_temp + 4096)
				if end_of_line then
				-- we don't want to read the \r
				end_of_line = end_of_line - 1
					local filename = payload:tostring(num_temp + 1, end_of_line)
					
					if filename then
						-- Trim leading and trailing punctuation (e.g. ' or ")
						filename = filename:gsub('^%p',''):gsub('%p$','')
						--nw.logInfo('###' .. filename .. '###')
						nw.createMeta(self.keys["server.filename"], filename)
					end
				end
			end
		end
	end
end



-- declare what tokens and events we want to match
luaServerFilename:setCallbacks({
	[nwevents.OnSessionBegin] = luaServerFilename.sessionBegin,
	["^Content-Disposition: "] = luaServerFilename.tokenContentDisposition,
	["^Content-disposition: "] = luaServerFilename.tokenContentDisposition,
	["^content-Disposition: "] = luaServerFilename.tokenContentDisposition,
	["^content-disposition: "] = luaServerFilename.tokenContentDisposition,
	["^CONTENT-DISPOSITION: "] = luaServerFilename.tokenContentDisposition,
	
	--The below are not used.
	--["^Content-Disposition: inline; "] = luaServerFilename.tokenContent-Disposition,
	--["^Content-disposition: inline; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-Disposition: inline; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-disposition: inline; "] = luaServerFilename.tokenContent-Disposition,
	--["^CONTENT-DISPOSITION: inline; "] = luaServerFilename.tokenContent-Disposition,
	
	--["^Content-Disposition: INLINE; "] = luaServerFilename.tokenContent-Disposition,
	--["^Content-disposition: INLINE; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-Disposition: INLINE; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-disposition: INLINE; "] = luaServerFilename.tokenContent-Disposition,
	--["^CONTENT-DISPOSITION: INLINE; "] = luaServerFilename.tokenContent-Disposition,
	
	--["^Content-Disposition: attachment; "] = luaServerFilename.tokenContent-Disposition,
	--["^Content-disposition: attachment; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-Disposition: attachment; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-disposition: attachment; "] = luaServerFilename.tokenContent-Disposition,
	--["^CONTENT-DISPOSITION: attachment; "] = luaServerFilename.tokenContent-Disposition,
	
	--["^Content-Disposition: ATTACHMENT; "] = luaServerFilename.tokenContent-Disposition,
	--["^Content-disposition: ATTACHMENT; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-Disposition: ATTACHMENT; "] = luaServerFilename.tokenContent-Disposition,
	--["^content-disposition: ATTACHMENT; "] = luaServerFilename.tokenContent-Disposition,
	--["^CONTENT-DISPOSITION: ATTACHMENT; "] = luaServerFilename.tokenContent-Disposition,
	
	
})