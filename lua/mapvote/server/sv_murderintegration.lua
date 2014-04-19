if not MAPVOTE.Murder or not MAPVOTE.Murder.Enable then
	return
end

hook.Add( "OnEndRound", "KMapVoteCountRounds", function( )
	MAPVOTE.CustomRoundEnded( "Murder" )
end )