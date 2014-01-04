function rtv( calling_ply )
	if calling_ply:IsValid() then
		MAPVOTE:PlayerRTV( calling_ply )
	end
end
if ulx then
	local rtvCmd = ulx.command( "KMapVote", "rtv", rtv, "!rtv", true )
	rtvCmd:defaultAccess( ULib.ACCESS_ALL )
	rtvCmd:help( "Vote for a change of map" )
end