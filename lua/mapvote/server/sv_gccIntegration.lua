MAPVOTE.OwnRoundCounter = 0
MAPVOTE.RoundsToPlay = 3

function MAPVOTE.CustomRoundEnded( )
	MAPVOTE.OwnRoundCounter = MAPVOTE.OwnRoundCounter + 1
	local roundsLeft = MAPVOTE.RoundsToPlay - MAPVOTE.OwnRoundCounter
	if roundsLeft > 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, Format( "[KMapVote] The round ended. %i rounds left until the vote starts.", roundsLeft ) )
		end
	elseif roundsLeft == 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, "[KMapVote] Voting will start after next round" )
		end
	end
	
	if MAPVOTE.OwnRoundCounter >= MAPVOTE.RoundsToPlay then
		MAPVOTE:BeginVote( )
	end
end

hook.Add( "KMapVoteMapExtension", "KMapVoteResetCounterGCC", function( )
	MAPVOTE.OwnRoundCounter = 0
end )