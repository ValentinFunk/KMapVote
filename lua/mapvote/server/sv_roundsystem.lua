MAPVOTE.OwnRoundCounter = 0

function MAPVOTE.CustomRoundEnded( gmConfigName )
	MAPVOTE.OwnRoundCounter = MAPVOTE.OwnRoundCounter + 1
	local roundsLeft = MAPVOTE[gmConfigName].RoundsToPlay - MAPVOTE.OwnRoundCounter
	if roundsLeft > 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, Format( "[KMapVote] The round ended. %i rounds left until the vote starts.", roundsLeft ) )
		end
	elseif roundsLeft == 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, "[KMapVote] Voting will start after next round" )
		end
	end
	
	if MAPVOTE.OwnRoundCounter >= MAPVOTE[gmConfigName].RoundsToPlay then
		MAPVOTE:BeginVote( )
	end
	
	hook.Run( "KMapVoteRoundEnded", gmConfigName )
end

hook.Add( "KMapVoteMapExtension", "KMapVoteResetCounterRoundSys", function( )
	MAPVOTE.OwnRoundCounter = 0
end )