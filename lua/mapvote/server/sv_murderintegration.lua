if not MAPVOTE.Murder or not MAPVOTE.Murder.Enable then
	return
end

MAPVOTE.Murder.RoundsPlayed = 0

hook.Add( "OnEndRound", "KMapVoteCountRounds", function( )
	MAPVOTE.Murder.RoundsPlayed = MAPVOTE.Murder.RoundsPlayed + 1
	
	if MAPVOTE.Murder.AnnounceInChat then
		local roundsLeft = MAPVOTE.Murder.MaxRounds - MAPVOTE.Murder.RoundsPlayed
		
		if roundsLeft > 1 then
			for k, v in pairs( player.GetAll( ) ) do
				v:PrintMessage( HUD_PRINTTALK, Format( "[KMapVote] The round ended. %s rounds left until the vote starts.", roundsLeft ) )
			end
		elseif roundsLeft == 1 then
			for k, v in pairs( player.GetAll( ) ) do
				v:PrintMessage( HUD_PRINTTALK, "[KMapVote] Voting will start after next round" )
			end
		end
	end
	
	if MAPVOTE.Murder.RoundsPlayed >= MAPVOTE.Murder.MaxRounds then
		MAPVOTE:BeginVote( )
	end
end )

hook.Add( "KMapVoteMapExtension", "KMapVoteResetCounter", function( )
	MAPVOTE.Murder.RoundsPlayed = 0
end )