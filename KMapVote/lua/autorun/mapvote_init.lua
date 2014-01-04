-- Short and sweet
if SERVER then
	include( "mapvote/init.lua" )
else
	include( "mapvote/cl_init.lua" )
end