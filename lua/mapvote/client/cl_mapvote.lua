MapvoteView = class( "MapvoteView" )
MapvoteView:include( BaseView )

local STATE = "STATE_NOVOTE"
STATEVARS = STATEVARS or {}
net.Receive( "VotemapState", function( len )
	STATE = net.ReadString( )
	STATEVARS = net.ReadTable( )
	if MAPVOTE.Debug then
		print( "[VoteMap] State changed to " .. STATE ) 
		PrintTable( STATEVARS )
	end
end )

local function openVotingFrame( mapList )
	local mainPanel = vgui.Create( "MapVoteFrame" )
	mainPanel:SetMapList( mapList )
	--mainPanel:MakePopup( )
	
	return mainPanel
end

local function openGamemodeVotingFrame( gmList )
	local mainPanel = vgui.Create( "GMVoteFrame" )
	mainPanel:SetGMList( gmList )
	--mainPanel:MakePopup( )
	
	return mainPanel
end

local function createRtvPanel( startingPlayer, endTime )
	local rtvPanel = vgui.Create( "RtvPanel" )
	rtvPanel:SetSize( 450, 85 )
	rtvPanel:SetPos( ScrW( ) / 2 - rtvPanel:GetWide( ) / 2, 0 )
	rtvPanel:SetStartingPlayer( startingPlayer )
	rtvPanel:SetEndTime( endTime )
	
	rtvPanel:SetSkin( MAPVOTE.DermaSkin )
	derma.SkinHook( "Layout", "RTVPanel", rtvPanel )
	Derma_Hook( rtvPanel, "Paint", "Paint", "RTVPanel" )
	
	return rtvPanel
end

local function createWaitPanel( )
	local waitPanel = vgui.Create( "DPanel" )
	waitPanel:SetSkin( MAPVOTE.DermaSkin )
	waitPanel:SetSize( 400, 85 )
	waitPanel:SetPos( ScrW( ) / 2 - waitPanel:GetWide( ) / 2, 0 )
	waitPanel:SetContentAlignment( 5 )
	waitPanel:SetBackgroundColor( Color( 90, 90, 90, 180 ) )
	
	waitPanel.label = vgui.Create( "DLabel", waitPanel )
	--self.label:SetColor( Color( 224, 209, 163, 255 ) )
	waitPanel.label:DockMargin( 0, 5, 0, 0 )
	waitPanel.label:Dock( FILL )
	waitPanel.label:SetContentAlignment( 5 )
	waitPanel.label:SetText( "RTV successful, vote will start after the round is finished." )
	
	derma.SkinHook( "Layout", "RTVPanel", waitPanel )
	Derma_Hook( waitPanel, "Paint", "Paint", "RTVPanel" )
	
	return waitPanel
end

function updatePreviousRating( len, retries )
	retries = retries or 0
	local prevRating = net.ReadString( )
	print( "update prev " .. prevRating )
	local function doIt( )
		if not IsValid( LocalPlayer( ).votingPanel ) then
			if retries > 3 then return end
			retries = retries + 1
			timer.Simple( 1, function( )
				doIt( retries )
			end )
			return
		end
		LocalPlayer( ).votingPanel:SetPreviousRating( tonumber( prevRating ) )
	end
	doIt( )
end
net.Receive( "MapVotePreviousRating", updatePreviousRating )

if IsValid( LocalPlayer( ).votingPanel ) then LocalPlayer( ).votingPanel:Remove( ) end
hook.Add( "Think", "MapVoteThink", function( )
	if STATE == "STATE_NOVOTE" then
		if IsValid( LocalPlayer( ).votingPanel ) then
			LocalPlayer( ).votingPanel:Close( )
			gui.EnableScreenClicker( false )
		end
		if IsValid( LocalPlayer( ).gmVotingPanel ) then
			LocalPlayer( ).gmVotingPanel:Remove( )
		end
		if IsValid( LocalPlayer( ).rtvPanel ) then
			LocalPlayer( ).rtvPanel:Remove( )
		end
		if IsValid( LocalPlayer( ).waitPanel ) then
			LocalPlayer( ).waitPanel:Remove( )
		end
	elseif STATE == "Vote" then
		if not IsValid( LocalPlayer( ).votingPanel ) and not STATEVARS.PanelClosed then
			LocalPlayer( ).votingPanel = openVotingFrame( STATEVARS.mapList )
			gui.EnableScreenClicker( true )
		end
		if IsValid( LocalPlayer( ).gmVotingPanel ) then
			LocalPlayer( ).gmVotingPanel:Remove( )
		end
		if IsValid( LocalPlayer( ).rtvPanel ) then
			LocalPlayer( ).rtvPanel:Remove( )
		end
		if IsValid( LocalPlayer( ).waitPanel ) then
			LocalPlayer( ).waitPanel:Remove( )
		end
	elseif STATE == "VoteGamemode" then
		if not IsValid( LocalPlayer( ).gmVotingPanel ) and not STATEVARS.PanelClosed then
			LocalPlayer( ).gmVotingPanel = openGamemodeVotingFrame( STATEVARS.gamemodes )
			gui.EnableScreenClicker( true )
		end
		if IsValid( LocalPlayer( ).rtvPanel ) then
			LocalPlayer( ).rtvPanel:Remove( )
		end
		if IsValid( LocalPlayer( ).waitPanel ) then
			LocalPlayer( ).waitPanel:Remove( )
		end
	elseif STATE == "VoteFinished" then
		if not IsValid( LocalPlayer( ).votingPanel ) then
			return
		end
		LocalPlayer( ).votingPanel:VoteFinished( STATEVARS.wonMap )
	elseif STATE == "GMVoteFinished" then
		if not IsValid( LocalPlayer( ).gmVotingPanel ) then
			return
		end
		LocalPlayer( ).gmVotingPanel:VoteFinished( STATEVARS.wonGm )
	elseif STATE == "RockTheVote" then
		if not IsValid( LocalPlayer( ).rtvPanel ) then
			LocalPlayer( ).rtvPanel = createRtvPanel( STATEVARS.starter, STATEVARS.endTime )
		end
	elseif STATE == "WaitForRoundEnd" then
		if IsValid( LocalPlayer( ).rtvPanel ) then
			LocalPlayer( ).rtvPanel:Remove( )
		end
		if not IsValid( LocalPlayer( ).waitPanel ) then
			LocalPlayer( ).waitPanel = createWaitPanel( )
		end
	end
end )

net.Receive( "VotesBroadcast", function( len )
	local votes = net.ReadTable( )
	local playersByMap = {}
	for ply, map in pairs( votes ) do
		playersByMap[map] = playersByMap[map] or {}
		table.insert( playersByMap[map], ply )
	end
	
	if IsValid( LocalPlayer( ).votingPanel ) then 
		LocalPlayer( ).votingPanel:UpdateVotes( playersByMap )
	end
end )

net.Receive( "GMVotesBroadcast", function( len )
	local votes = net.ReadTable( )
	local playersByGM = {}
	for ply, map in pairs( votes ) do
		playersByGM[map] = playersByGM[map] or {}
		table.insert( playersByGM[map], ply )
	end
	
		if IsValid( LocalPlayer( ).gmVotingPanel ) then 
		LocalPlayer( ).gmVotingPanel:UpdateVotes( playersByGM )
	end
end )	

net.Receive( "MapVoteRTVBroadcast", function( len )
	local votes = net.ReadTable( )
	LocalPlayer( ).rtvPanel:UpdateVotes( votes )
end )