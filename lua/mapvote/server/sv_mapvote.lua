-----LibK Database Init-----
LibK.SetupDatabase( "KMapVote", KMapVote )

resource.AddFile( "materials/" .. MAPVOTE.LogoPath )

for _, map in pairs( MAPVOTE.maps ) do
	resource.AddFile( "materials/mapicons/" .. map.name .. ".png" )
end

for _, gm in pairs( MAPVOTE.VoteGamemodes ) do
	resource.AddFile( "materials/gmicons/" .. gm .. ".png" )
end

util.AddNetworkString( "VotemapState" )
util.AddNetworkString( "PlayerVoteMap" )
util.AddNetworkString( "VotesBroadcast" )
util.AddNetworkString( "MapVoteAdminOverride" )
util.AddNetworkString( "MapVoteRTVBroadcast" )
util.AddNetworkString( "MapVotePreviousRating" )

util.AddNetworkString( "GMVotesBroadcast" )
util.AddNetworkString( "PlayerVoteGM" )
util.AddNetworkString( "GMVoteAdminOverride" )
util.AddNetworkString( "PlayerRateMap" )

local STATE = "STATE_NOVOTE"
local STATES = {}

local function setState( strState )
	STATE = strState
	STATES[STATE].initialized = false
	if MAPVOTE.Debug then
		print( "[VoteMap] State changed to " ..strState ) 
	end
end

concommand.Add( "mapvote_force_vote", function( ply, cmd, args )
	if IsValid( ply ) and not ply:IsAdmin( ) then
		return
	end
	
	if MAPVOTE.VoteForGamemode then
		setState( "VoteGamemode" )
	else
		setState( "Vote" )
	end
end )

hook.Add( "Think", "MapVoteMainThink", function( )
	local state = STATES[STATE]
	if not state then
		error( "[KMapVote]State " .. STATE .. " does not exist" )
	end
	if not state.initialized then
		state:Init( )
		state.initialized = true
		
		net.Start( "VotemapState" )
			net.WriteString( STATE )
			net.WriteTable( state.netStateVars )
		net.Broadcast( )
	end
	state:Think( )
end)

hook.Add( "PlayerInitialSpawn", "MapVoteUpdateState", function( ply )
	local state = STATES[STATE]
	if not state then
		error( "[KMapVote]Couldn't send state, state " .. STATE .. " does not exist" )
	end
	timer.Simple( 2, function( ) 
		net.Start( "VotemapState" )
			net.WriteString( STATE )
			net.WriteTable( state.netStateVars )
		net.Send( ply )
	end )
end )

STATES.STATE_NOVOTE = {}
function STATES.STATE_NOVOTE:Init( )
	self.netStateVars = {}

	if MAPVOTE.RTVInitialCooldown and not STATES.RockTheVote.nextRtvValid then
		STATES.RockTheVote.nextRtvValid = CurTime( ) + MAPVOTE.RTVInitialCooldown * 60
	end
	
	if MAPVOTE.TimeBetweenVotes then
		self.nextVote = CurTime( ) + MAPVOTE.TimeBetweenVotes * 60
		self.netStateVars = { nextVote = self.nextVote }
	else
		self.netStateVars = { }
	end
end

function STATES.STATE_NOVOTE:Think( )
	if self.nextVote and CurTime( ) > self.nextVote then
		if MAPVOTE.VoteForGamemode then
			setState( "VoteGamemode" )
		else
			setState( "Vote" )
		end
	end
end

STATES.RockTheVote = {}
function STATES.RockTheVote:Init( )
	self.playersVoted = {
		self.startedPly
	}
	
	if MAPVOTE.RTVCooldown then
		self.nextRtvValid = CurTime( ) + MAPVOTE.RTVCooldown * 60
	end
	
	self.endTime = CurTime( ) + MAPVOTE.RTVPreVoteTime
	self.netStateVars = { 
		starter = self.startedPly,
		endTime = self.endTime
	}
end


function STATES.RockTheVote:Think( )
	if CurTime( ) > self.endTime then
		setState( "STATE_NOVOTE" )
	end
	
	local numVotes = 0
	for k, v in pairs( self.playersVoted ) do
		if MAPVOTE.RTVUserVotePower then
			numVotes = numVotes + v:GetVotePower( )
		else
			numVotes = numVotes + 1
		end
	end
	if numVotes >= math.Round( #player.GetAll( ) * MAPVOTE.RTVRequiredFraction ) then
		if table.HasValue( MAPVOTE.RTVWaitForRoundEndGamemodes, engine.ActiveGamemode( ) ) then
			setState( "WaitForRoundEnd" )
		else
			if MAPVOTE.VoteForGamemode then
				setState( "VoteGamemode" )
			else
				setState( "Vote" )
			end
		end
	end
end

STATES.WaitForRoundEnd = {}
function STATES.WaitForRoundEnd:Init( )
	self.netStateVars = {}
end

function STATES.WaitForRoundEnd:Think( )
	if engine.ActiveGamemode( ) == "terrortown" then
		if GetRoundState( ) == ROUND_POST then
			MAPVOTE:BeginVote( )
		end
	elseif engine.ActiveGamemode( ) == "murder" then
		if GAMEMODE:GetRound( ) == 2 		--About to start new round
		   or GAMEMODE:GetRound( ) == 0		--Not 100% sure...
		then
			MAPVOTE:BeginVote( )
		end
	end
end
hook.Add( "KMapVoteRoundEnded", "RoundEndedStartVote", function( )
	if MAPVOTE:GetState( ) == "WaitForRoundEnd" then
		MAPVOTE:BeginVote( )
	end
end )


function SecondsToClock(sSeconds)
	local nSeconds = tonumber(sSeconds)
	if nSeconds == 0 then
		return 0
	else
		nHours = math.floor(nSeconds/3600)
		nMins = math.floor(nSeconds/60 - (nHours*60))
		nSecs = math.floor(nSeconds - nHours*3600 - nMins *60)
		return nHours, nMins, nSecs
	end
end

function MAPVOTE:PlayerRTV( ply )
	if STATE == "RockTheVote" then
		if not table.HasValue( STATES.RockTheVote.playersVoted, ply ) then
			if MAPVOTE.Debug then
				print( ply:Nick( ) .. " voted for rtv" )
			end
			table.insert( STATES.RockTheVote.playersVoted, ply )
			net.Start( "MapVoteRTVBroadcast" )
				net.WriteTable( STATES.RockTheVote.playersVoted )
			net.Broadcast( )
		end
	elseif STATE == "STATE_NOVOTE" then
		if STATES.RockTheVote.nextRtvValid then
			if CurTime( ) > STATES.RockTheVote.nextRtvValid then
				STATES.RockTheVote.startedPly = ply
				setState( "RockTheVote" )
				if MAPVOTE.Debug then
					print( ply:Nick( ) .. " started an rtv" )
				end
			else
				local timeLeft = STATES.RockTheVote.nextRtvValid - CurTime( )
				local hours, minutes, seconds = SecondsToClock( timeLeft )
				if minutes > 0 then
					ply:PrintMessage( HUD_PRINTTALK , string.format( "RTV is on cooldown. Next RTV can be started in %02.f:%02.f minutes", minutes, seconds )  )
				else
					ply:PrintMessage( HUD_PRINTTALK , string.format( "RTV is on cooldown. Next RTV can be started in %02.f seconds", seconds )  )
				end
				if MAPVOTE.Debug then
					print( ply:Nick( ) .. " started an rtv but it is still on cooldown for " .. hours .. ":" .. minutes .. ":" .. seconds )
				end
			end
		else 
			STATES.RockTheVote.startedPly = ply
			setState( "RockTheVote" )
		end
	else
		if MAPVOTE.Debug then
			print( "Invalid state for RTV: " .. STATE )
		end
	end
end


STATES.VoteGamemode = {}
function STATES.VoteGamemode:Init( )
	self.playerVotes = {}
	self.voteTimeout = CurTime( ) + MAPVOTE.GamemodeVoteTime
	
	self.voteGamemodes = {}
	for k, gm in pairs( engine.GetGamemodes( ) ) do
		if table.HasValue( MAPVOTE.VoteGamemodes, gm.name ) then
			table.insert( self.voteGamemodes, gm )
		end
	end
	
	hook.Call( "KMapVote_GamemodeVoteStarted" )
	self.netStateVars = {
		gamemodes = self.voteGamemodes,
		endTime = self.voteTimeout
	}
end

function STATES.VoteGamemode:Think( )
	if CurTime( ) >= self.voteTimeout then
		--Find winner
		local scoreByGM = {} --map = score
		for ply, gm in pairs( self.playerVotes ) do
			local playerVotePower = ply:GetVotePower( )
			scoreByGM[gm] = ( scoreByGM[gm] or 0 ) + playerVotePower
		end
	
		--Add Maps with 0 votes(important if noone voted)
		for _, gm in pairs( self.voteGamemodes ) do
			scoreByGM[gm.name] = scoreByGM[gm.name] or 0
		end
		
		--Sort into a table by score
		local gmByScore = {} --score = map
		for gm, score in pairs( scoreByGM ) do
			gmByScore[score] = gmByScore[score] or {}
			table.insert( gmByScore[score], gm )
		end
		
		--Determine the highest score
		local highestScore = 0
		for score, gm in pairs( gmByScore ) do
			if score > highestScore then
				highestScore = score
			end
		end
		
		--Choose a random winner out of the maps with the same, highest score
		local wonGm = table.Random( gmByScore[highestScore] )
		STATES.GMVoteFinished.wonGm = wonGm
		setState( "GMVoteFinished" )
	end
end

net.Receive( "PlayerVoteGM", function( len, ply )
	if STATE != "VoteGamemode" then
		--Some idiot clicking on the maps after the vote is finished
		return
	end
	
	local gm = net.ReadString( )
	
	if STATES.VoteGamemode.playerVotes[ply] and STATES.VoteGamemode.playerVotes[ply] == gm then
		print( "[MapVote] Player " .. ply:Nick( ) .. " voted for " .. gm .. ", double vote, not sending" )
		return
	end
	
	if MAPVOTE.Debug then
		print( "[MapVote] Player " .. ply:Nick( ) .. " voted for " .. gm )
	end
	
	STATES.VoteGamemode.playerVotes[ply] = gm
	
	net.Start( "GMVotesBroadcast" )
		net.WriteTable( STATES.VoteGamemode.playerVotes )
	net.Broadcast( )
end )

net.Receive( "GMVoteAdminOverride", function( len, ply )
	--Accept even if in wrong state, since admin
	if not ply:CanOverride( ) then
		return
	end
	STATES.GMVoteFinished.wonGm = net.ReadString( )
	setState( "GMVoteFinished" )
end )


STATES.GMVoteFinished = {}
function STATES.GMVoteFinished:Init( )
	self.voteGmTimeout = CurTime( ) + MAPVOTE.PostVoteTime
	
	--Send winner to client
	self.netStateVars = { 
		wonGm = self.wonGm
	}
end

function STATES.GMVoteFinished:Think( )
	if CurTime( ) >= self.voteGmTimeout then
		--Start Map Vote
		STATES.Vote.wonGm = self.wonGm
		
		--To Make sure the maps get picked up from the content folders
		RunConsoleCommand( "gamemode", self.wonGm )
		
		setState( "Vote" )
	end
end

local function isMapGoodForGamemode( map, gmTable )
	--Check if map is valid for the upcoming gamemode
	local isValidMap = false
	local validMaps = string.Split( gmTable.maps, "|" )
	if validMaps && gmTable.maps != "" then
		for k, pattern in pairs( validMaps ) do
			if string.find( string.lower( map.name ), pattern ) then
				isValidMap = true
				break
			end
		end
	end
	if not isValidMap then
		KLogf( 5, "Map %s is not within the valid gamemode pattern for gm %s pattern %s", map.name, gmTable.name, gmTable.maps )
	end	
	
	--Check for override
	if map.gamemodes then
		if table.HasValue( map.gamemodes, gmTable.name ) then
			isValidMap = true
		else
			KLogf( 5, "Map %s has override %s, not adding it (gamemode is %s)", map.name, table.concat( map.gamemodes, ',' ), gmTable.name )
			isValidMap = false --override override gm map pattern
		end
	end
	
	
	return isValidMap
end

STATES.Vote = {}
function STATES.Vote:Init( )
	self.ExtendCounter = self.ExtendCounter or 0
	
	self.playerVotes = {} --ply = mapname
	self.voteTimeout = CurTime( ) + MAPVOTE.VoteTime
	
	--Gather list of maps to allow voting on
	self.maps = {}
	table.shuffle( MAPVOTE.maps )
	
	if engine.ActiveGamemode( ) == "terrortown" then
		timer.Stop( "end2prep" )
	end
	
	local gmTable 
	if MAPVOTE.VoteForGamemode and self.wonGm then
		for k, v in pairs( engine.GetGamemodes( ) ) do
			if v.name == self.wonGm then
				gmTable = v
			end
		end
	else
		for k, v in pairs( engine.GetGamemodes( ) ) do
			if v.name == engine.ActiveGamemode() then
				gmTable = v
			end
		end
	end
	
	self.wonGm = self.wonGm or engine.ActiveGamemode()
	
	local mapsInCooldown = {}
	if MAPVOTE.MapCooldown then
		if not DATABASES or not DATABASES.KMapVote then
			for k, v in pairs( player.GetAll( ) ) do
				if v:IsAdmin( ) then
					BaseController.startView( nil, "MapvoteView", "displayError", v, "[KMapVote|AdminOnly] There has been an error fetching map information, please check your database configuration and the server console for errors. Contact Kamshak if this persists." )
				end
			end
		else
			DATABASES.KMapVote.DoQuery( 
				"SELECT * FROM kmapvote_mapinfo ORDER BY createdAt DESC LIMIT " ..  MAPVOTE.MapCooldown,
				true --blocking
			)
			:Then( function( rows )
				rows = rows or {}
				
				for k, row in pairs( rows ) do
					table.insert( mapsInCooldown, row.mapname )
				end
			end )
		end
	end
	
	local mapErrors = {}
	local maxMaps = MAPVOTE.MapsPerVote
	if MAPVOTE.ExtensionLimit and self.ExtendCounter < MAPVOTE.ExtensionLimit then
		maxMaps = maxMaps + 1 --Allow one more map than configured since extension panel is gone
	end
	
	for _, map in pairs( MAPVOTE.maps ) do
		if #self.maps >= MAPVOTE.MapsPerVote then
			break
		end
		
		if map.minplayers and #player.GetAll( ) < map.minplayers then
			continue
		end
		
		if map.maxplayers and #player.GetAll( ) > map.maxplayers then
			continue
		end
		
		if map.name == game.GetMap( ) then
			continue --extension handled below
		end
		
		if not isMapGoodForGamemode( map, gmTable ) then
			continue
		end
		
		if table.HasValue( mapsInCooldown, map.name ) then
			continue
		end
		
		if MAPVOTE.CheckMaps and not file.Exists( "maps/" .. map.name .. ".bsp", "GAME" ) then
			table.insert( mapErrors, map.name .. ".bsp could not be found on the server and was not added to the vote!" )
			continue
		end
		
		table.insert( self.maps, map )
	end
	if MAPVOTE.AllowExtension then
		local map
		for k, v in pairs( MAPVOTE.maps ) do
			if v.name == game.GetMap( ) then
				map = v
			end
		end
		if map and isMapGoodForGamemode( map, gmTable ) then
			if MAPVOTE.ExtensionLimit and self.ExtendCounter < MAPVOTE.ExtensionLimit then
				table.insert( self.maps, map )
			end
		end
	end
	
	if #mapErrors > 0 and MAPVOTE.CheckMaps then
		for k, v in pairs( player.GetAll( ) ) do
			local errors = table.concat( mapErrors, "\n" ) 
			if v:IsAdmin( ) then
				BaseController.startView( nil, "MapvoteView", "displayError", v, "[KMapVote|AdminOnly] Errors have been detected in your config:\n" .. errors )
			end
		end
	end
	
	if MAPVOTE.EnableRatings and DATABASES and DATABASES.KMapVote and DATABASES.KMapVote.IsConnected then
		--Send Clients their previous vote
		for k, v in pairs( player.GetAll( ) ) do
			KMapVote.Rating.getDbEntries( Format( 
				"WHERE owner_id = %i AND mapname = %s",
				v.kPlayerId,
				DATABASES.KMapVote.SQLStr( game.GetMap( ) )
			) )
			:Then( function( rating )
				if rating and rating[1] then
					net.Start( "MapVotePreviousRating" )
						net.WriteString( tostring( rating[1].stars ) )
					net.Send( v )
				end
			end )
		end	
	
		--Add ratings
		KMapVote.Rating.addRatingSummaryToMaps( self.maps )
	end
	
	if #self.maps < 1 then
		for k, v in pairs( player.GetAll( ) ) do
			if v:IsAdmin( ) then
				BaseController.startView( nil, "MapvoteView", "displayError", v, "[KMapVote|AdminOnly][CRITICAL] No map criteria matched the current config! Aborting vote!" )
			end
		end
		KLogf( 2, "[ERROR] There was no map that would be valid for the current config! Please fix it!" )
		setState( "STATE_NOVOTE" )
		return
	end
	
	hook.Call( "KMapVote_MapVoteStarted" )
	
	--Send list to client
	self.netStateVars = { 
		mapList = self.maps, 
		endTime = self.voteTimeout,
	}
	
	self.netStateVars["wonGm"] = self.wonGm or nil
end

hook.Add( "KMapVoteMapExtension", "LimitExtension", function( )
	STATES.Vote.ExtendCounter = STATES.Vote.ExtendCounter + 1
end )

function STATES.Vote:Think( )
	if CurTime( ) >= self.voteTimeout or #self.maps == 1 then
		--Find winner
		local scoreByMap = {} --map = score
		for ply, map in pairs( self.playerVotes ) do
			local playerVotePower = ply:GetVotePower( )
			scoreByMap[map] = ( scoreByMap[map] or 0 ) + playerVotePower
		end
	
		--Add Maps with 0 votes(important if noone voted)
		for _, map in pairs( self.maps ) do
			scoreByMap[map.name] = scoreByMap[map.name] or 0
		end
		
		--Sort into a table by score
		local mapByScore = {} --score = map
		for map, score in pairs( scoreByMap ) do
			mapByScore[score] = mapByScore[score] or {}
			table.insert( mapByScore[score], map )
		end
		
		--Determine the highest score
		local highestScore = 0
		for score, maps in pairs( mapByScore ) do
			if score > highestScore then
				highestScore = score
			end
		end
		
		--Choose a random winner out of the maps with the same, highest score
		local wonMap = table.Random( mapByScore[highestScore] )
		STATES.VoteFinished.wonMap = wonMap
		setState( "VoteFinished" )
	end
end

net.Receive( "PlayerRateMap", function( len, ply )
	local stars = net.ReadUInt( 8 )
	local comment = ""
	
	if STATE != "Vote" then
		return --Can only rate maps in the voting screen
	end
	
	KMapVote.Rating.getDbEntries( Format( 
		"WHERE owner_id = %i and mapname = %s",
		ply.kPlayerId,
		DATABASES.KMapVote.SQLStr( game.GetMap( ) )
	))
	:Then( function( ratings )
		local rating
		if ratings and #ratings > 0 then
			rating = ratings[1]
		else
			rating = KMapVote.Rating:new( )
			rating.mapname = game.GetMap( )
			rating.owner_id = ply.kPlayerId
		end
		rating.comment = comment
		rating.stars = stars
		return rating:save( )
	end )
	:Then( function( rating )
		KLogf( 4, 
			"%s rated map %s with %i stars(%s)",
			ply:Nick(),
			rating.mapname,
			rating.stars,
			rating.comment
		)
	end, function( errid, err )
		KLogf( 2, 
			"Error rating map: %s tried to rate map %s, error %i: %s",
			ply:Nick( ),
			game.GetMap( ),
			errid,
			err
		)
	end )
end )

net.Receive( "MapVoteAdminOverride", function( len, ply )
	--Accept even if in wrong state, since admin
	if not ply:CanOverride( ) then
		return
	end
	STATES.VoteFinished.wonMap = net.ReadString( )
	setState( "VoteFinished" )
end )

net.Receive( "PlayerVoteMap", function( len, ply )
	if STATE != "Vote" then
		--Some idiot clicking on the maps after the vote is finished
		return
	end
	
	local map = net.ReadString( )
	
	if STATES.Vote.playerVotes[ply] and STATES.Vote.playerVotes[ply] == map then
		if MAPVOTE.Debug then
			print( "[MapVote] Player " .. ply:Nick( ) .. " voted for " .. map .. ", double vote, not sending" )
		end
		return false
	end
	
	if MAPVOTE.Debug then
		print( "[MapVote] Player " .. ply:Nick( ) .. " voted for " .. map )
	end
	
	STATES.Vote.playerVotes[ply] = map
	
	net.Start( "VotesBroadcast" )
		net.WriteTable( STATES.Vote.playerVotes )
	net.Broadcast( )
end )

STATES.VoteFinished = {}
function STATES.VoteFinished:Init( )
	self.changeMapTimeout = CurTime( ) + MAPVOTE.PostVoteTime
	self.changingMapAfterSave = false
	
	--Send winner to client
	self.netStateVars = { wonMap = self.wonMap }
end

function STATES.VoteFinished:Think( )
	if CurTime( ) >= self.changeMapTimeout then
		--Run mapchange logic only once, since we're using async calls it might take more
		--than a single think and save playcounts more often and leave us with a strange
		--lua state when the map changes(crashes in the worst case)
		if self.changingMapAfterSave then
			return
		end
		self.changingMapAfterSave = true
		
		local changed = false
		local function doChangeMap( )	
			changed = true
			if self.wonMap == game.GetMap() then
				--Map Extension
				
				--Change map if gamemode changed
				if MAPVOTE.VoteForGamemode and STATES.Vote.wonGm and STATES.Vote.wonGm != GAMEMODE.FolderName then
					RunConsoleCommand( "gamemode", STATES.Vote.wonGm )
					RunConsoleCommand( "changelevel", self.wonMap )
				end
				
				hook.Call( "KMapVoteMapExtension" )
				setState( "STATE_NOVOTE" )
				if MAPVOTE.TimeBetweenVotes then
					STATES.STATE_NOVOTE.nextVote = CurTime( ) + MAPVOTE.TimeBetweenVotes * 60
				end
				
				if MAPVOTE.RTVInitialCooldown then
					STATES.RockTheVote.nextRtvValid = CurTime( ) + MAPVOTE.RTVInitialCooldown * 60
				end
				
				if MAPVOTE.UseTerrortown then
					if GAMEMODE.InitCvars then
						GAMEMODE:InitCvars()
					end
					GAMEMODE.extendedStartTime = CurTime( )
				end
				
				if engine.ActiveGamemode( ) == "terrortown" then
					PrepareRound()
				end
			else
				if MAPVOTE.VoteForGamemode and STATES.Vote.wonGm then
					if MAPVOTE.Debug then
						KLogf( 4, "[MapVote] Changing map to %s gamemode: %s", self.wonMap, STATES.Vote.wonGm )
					end
					RunConsoleCommand( "gamemode", STATES.Vote.wonGm )
					RunConsoleCommand( "changelevel", self.wonMap )
				else
					if MAPVOTE.Debug then
						KLogf( 4, "[MapVote] Changing map to %s", self.wonMap )
					end
					RunConsoleCommand( "changelevel", self.wonMap )
				end
			end
		end
		
		local mapInfo = KMapVote.MapInfo:new( )
		mapInfo.mapname = game.GetMap( )
		mapInfo:save( )
		:Then( function( )
			doChangeMap( )
		end,
		function( num, err )
			KLogf( 2, "[KMapVote] Error %i occured when saving the mapinfo: %s", num, err )
			RunConsoleCommand( "changelevel", self.wonMap )
		end )
		
		timer.Simple( 7, function( )
			if not changed then
				KLogf( 2, "[KMapVote] Mapchange to %s timed out, forcing it", self.wonMap )
				doChangeMap( )
			end
		end )
	end
end

--For Reloads
for k, v in pairs( STATES ) do
	v.initialized = false
end

if MAPVOTE.UseTerrortown then
	local function TTTHooked( )
		-- Check for mapswitch
		local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
		SetGlobalInt("ttt_rounds_left", rounds_left)

		local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - ( CurTime() - ( GAMEMODE.extendedStartTime or 0 ) ) )
		local switchmap = false
		local nextmap = string.upper(game.GetMapNext())

		if rounds_left <= 0 then
			LANG.Msg("limit_round", {mapname = " Vote"})
			switchmap = true
		elseif time_left <= 0 then
			LANG.Msg("limit_time", {mapname = " Vote"})
			switchmap = true
		end
		
		if switchmap then
			--timer.Stop( "end2prep" )
			timer.Simple( 15, function( )
				if MAPVOTE.VoteForGamemode then
					setState( "VoteGamemode" )
				else
					setState( "Vote" )
				end
			end )
		else
			LANG.Msg("limit_left", {num = rounds_left,
				  time = math.ceil(time_left / 60),
			      mapname = " Vote"})
		end
	end
	local function replaceTTT( )
		if CheckForMapSwitch != TTTHooked then
			CheckForMapSwitch = TTTHooked
		end
		function game.LoadNextMap( )
			if MAPVOTE.VoteForGamemode then
				setState( "VoteGamemode" )
			else
				setState( "Vote" )
			end
		end
	end
	hook.Add( "Think", "TTTRehookHook", replaceTTT )
end

if MAPVOTE.SetFrettaReplacement then
	hook.Add( "Think", "hookGMVote", function( )
		if GAMEMODE.StartGamemodeVote then
			--KLogf( 4, "Found GAMEMODE.StartGamemodeVote, patching..." )
		end
		function GAMEMODE:StartGamemodeVote()
			if not GAMEMODE.m_bVotingStarted then
				if MAPVOTE.VoteForGamemode then
					setState( "VoteGamemode" )
				else
					setState( "Vote" )
				end
				GAMEMODE.m_bVotingStarted = true
			end
		end
		
		if GAMEMODE.VoteForChange then
			--KLogf( 4, "Found GAMEMODE.VoteForChange, patching..." )
		end
		function GAMEMODE:VoteForChange( ply )
			MAPVOTE:PlayerRTV( ply )
		end
		
		if GAMEMODE.StartMapVote then
			--KLogf( 4, "Found GAMEMODE.StartMapVote, patching..." )
		end
		function GAMEMODE:StartMapVote( )
			if not GAMEMODE.m_bVotingStarted then
				setState( "Vote" )
				GAMEMODE.m_bVotingStarted = true
			end
		end
		
		if MapVote then
			if MapVote then
				--KLogf( 4, "Found MapVote, patching MapVote.Start..." )
			end
			function MapVote.Start( )
				if MAPVOTE.VoteForGamemode then
					setState( "VoteGamemode" )
				else
					setState( "Vote" )
				end
			end
		end
		
		if FC_VOTE then
			--KLogf( 2, "[KMapVote][WARNING] found FCVote, replacing it's functions!" )
		end
		FC_VOTE = {}
		function FC_VOTE:StartVote( )
				if MAPVOTE.VoteForGamemode then
					setState( "VoteGamemode" )
				else
					setState( "Vote" )
				end
		end
		function FC_VOTE.CheckRTV( )
			--KLogf( 2, "[KMapVote][WARNING] FCVote CheckRTV called! Please contact kam" )
		end
		
		if RTV then
			if RTV then
				--KLogf( 4, "Found RTV, patching RTV.StartVote..." )
			end
			function RTV.StartVote( ply )
				MAPVOTE:PlayerRTV( ply )
			end
		end
	end )
end

if MAPVOTE.SetDeathrunReplacement then
	hook.Add( "InitPostEntity", "hookGMVoteDeathrun", function( )
		if RTV then
			RTV.ChatCommands = { } --Disable deathrun RTV
			function RTV.Start( )
				if MAPVOTE.VoteForGamemode then
					setState( "VoteGamemode" )
				else
					setState( "Vote" )
				end
			end
		end
	end )
end

--Interface

--Force a map vote
function MAPVOTE:StartMapVote( )
	setState( "Vote" )
end	

--Force a gamemode vote
function MAPVOTE:StartGamemodeVote( )
	setState( "VoteGamemode" )
end

--Force a vote as per config
function MAPVOTE:BeginVote( )
	if MAPVOTE.VoteForGamemode then
		setState( "VoteGamemode" )
	else
		setState( "Vote" )
	end
end

function MAPVOTE:GetState( )
	return STATE
end

function MAPVOTE:GetStateTable( )
	return STATES[STATE]
end