--Labyrinth
if engine.ActiveGamemode( ) == "labyrinth" and MAPVOTE.Labyrinth.Enable then
	MAPVOTE.OwnRoundCounter = -1 --RoundPre is called once on init
	hook.Add( "Initialize", "PostGMLoaded", function( )
		local old = RoundPre
		function RoundPre( )
			old( )
			MAPVOTE.CustomRoundEnded( "Labyrinth" )
		end
	end )
end

--Melonbomber
if engine.ActiveGamemode( ) == "melonbomber" and MAPVOTE.Melonbomber.Enable then
	hook.Add( "Initialize", "melonbomberhook", function( )
		local old = GAMEMODE.EndRound
		function GAMEMODE.EndRound( ... )
			old( ... )
			MAPVOTE.CustomRoundEnded( "Melonbomber" )
		end
	end )
end

--Melontank
if engine.ActiveGamemode( ) == "melontank" and MAPVOTE.Melontank.Enable then
	hook.Add( "Initialize", "MelonTankhk", function( )
		local old = GAMEMODE.GameEnd
		function GAMEMODE.GameEnd( Team )
			old( Team )
			MAPVOTE.CustomRoundEnded( "Melontank" )
		end--Announce rounds left until a vote starts in chat after each round
	end )
end

/*
--Pedobearescape 2
if engine.ActiveGamemode( ) == "pedobearescape2" then
	hook.Add( "Initialize", "HKPedo", function( )
		game.ConsoleCommand( "pbe2_rounds", MAPVOTE.RoundsToPlay )
		function game.LoadNextMap( )
			MAPVOTE:BeginVote( )
		end
	end )
end
*/