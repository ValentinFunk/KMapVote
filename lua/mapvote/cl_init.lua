--Shared modules
local files = file.Find( "mapvote/shared/*.lua", "LUA" )
if #files > 0 then
	for _, file in ipairs( files ) do
		Msg( "[MapVote] Loading SHARED file: " .. file .. "\n" )
		include( "mapvote/shared/" .. file )
	end
end

--Client modules
local files = file.Find( "mapvote/client/*.lua", "LUA" )
if #files > 0 then
	for _, file in ipairs( files ) do
		Msg( "[MapVote] Loading CLIENT file: " .. file .. "\n" )
		include( "mapvote/client/" .. file )
	end
end
MsgN( "Mapvote by Kamshak loaded" )