MAPVOTE.OwnRoundCounter = 0

function MAPVOTE.CustomRoundEnded( gmConfigName )
	MAPVOTE.OwnRoundCounter = MAPVOTE.OwnRoundCounter + 1
	local roundsLeft = MAPVOTE[gmConfigName].MaxRounds - MAPVOTE.OwnRoundCounter
	if roundsLeft > 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, Format( "[KMapVote] The round ended. %i rounds left until the vote starts.", roundsLeft ) )
		end
	elseif roundsLeft == 1 then
		for k, v in pairs( player.GetAll( ) ) do
			v:PrintMessage( HUD_PRINTTALK, "[KMapVote] Voting will start after next round" )
		end
	end
	
	local maxRounds = MAPVOTE[gmConfigName].MaxRounds
	if gmConfigName == "ZombieSurvival" and GAMEMODE.ZombieEscape then
		maxRounds = MAPVOTE.ZombieSurvival.ZEMaxRounds
	end
	
	if MAPVOTE.OwnRoundCounter >= maxRounds then
		MAPVOTE:BeginVote( )
	end
	
	hook.Run( "KMapVoteRoundEnded", gmConfigName )
end

hook.Add( "KMapVoteMapExtension", "KMapVoteResetCounterRoundSys", function( )
	MAPVOTE.OwnRoundCounter = 0
end )