AddCSLuaFile( "mapvote/cl_init.lua" )
AddCSLuaFile( "autorun/mapvote_init.lua" )
local folder = "mapvote/shared"
local files = file.Find( folder .. "/" .. "*.lua", "LUA" )
for _, file in ipairs( files ) do
	AddCSLuaFile( folder .. "/" .. file )
end

folder = "mapvote/client"
files = file.Find( folder .. "/" .. "*.lua", "LUA" )
for _, file in ipairs( files ) do
	AddCSLuaFile( folder .. "/" .. file )
end

--Shared modules
local files = file.Find( "mapvote/shared/*.lua", "LUA" )
if #files > 0 then
	for _, file in ipairs( files ) do
		Msg( "[MapVote] Loading SHARED file: " .. file .. "\n" )
		include( "mapvote/shared/" .. file )
		AddCSLuaFile( "mapvote/shared/" .. file )
	end
end

--Server modules
local files = file.Find( "mapvote/server/*.lua", "LUA" )
if #files > 0 then
	for _, file in ipairs( files ) do
		Msg( "[MapVote] Loading SERVER file: " .. file .. "\n" )
		include( "mapvote/server/" .. file )
	end
end

--Map Icons
local files = file.Find( "materials/mapicons/*.png", "GAME" )
if #files > 0 then
	for _, file in ipairs( files ) do
		resource.AddFile( "materials/mapicons/" .. file )
	end
end

MsgN( "Mapvote by Kamshak loaded" )