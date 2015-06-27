if not MAPVOTE.BVDeathrun or not MAPVOTE.BVDeathrun.Enable then
	return
end

hook.Add( "InitPostEntity", "KMVSupportBlackvoidDR", function( ) 
	GAMEMODE.MapVoteCheck = function( )
	end
end )

hook.Add( "CanStartRound", "KMVPreventRoundStart", function( )
	if MAVOTE:GetState( ) != "STATE_NOVOTE" then
		return false
	end
end )

hook.Add( "KMapVoteMapExtension", "KMVMAkeSureRoundStarts", function( )
	timer.Simple( 0.5, function( )
		if GAMEMODE.RoundStatusCheck then
			GAMEMODE:RoundStatusCheck( )
		end
	end )
end )

hook.Add( "OnRoundEnd", "KMapVoteCountRoundsDR", function( )
	MAPVOTE.CustomRoundEnded( "BVDeathrun" )
end )
