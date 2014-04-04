local PANEL = {}

function PANEL:Init( )
	print( "GMVoteFrame init" )
	self:SetSkin( MAPVOTE.DermaSkin )
	
	--gmpanels, name is mappanels because of inheritance, k?
	self.mapPanels = vgui.Create( "DIconLayout", self )
	self.mapPanels:DockMargin( 10, 10, 10, 10 )
	self.mapPanels:Dock( FILL )
	self.mapPanels:SetSpaceX( 10 )
	self.mapPanels:SetSpaceY( 10 )
	
	derma.SkinHook( "Layout", "GMVoteFrame", self )
end	

function PANEL:HandleGMVote( gm )
	if MAPVOTE.Debug then
		print( "[MapVote] CL_HandleGMVote " .. gm.name )
	end
	net.Start( "PlayerVoteGM" )
		net.WriteString( gm.name )
	net.SendToServer( )
end

function PANEL:VoteFinished( wonGm )
	local panelWon = v
	for k, v in pairs( self.mapPanels:GetChildren( ) ) do
		if v:GetGamemode( ).name == wonGm then
			panelWon = v
			v:WonAnimation( )
		end
	end
	
	if MAPVOTE.ShowTimer then
		self.timerLabel.textOverride = true
		if wonMap == engine.ActiveGamemode( ) then
			self.timerLabel:SetText( "Gamemode is being extended" )
		else
			self.timerLabel:SetText( panelWon.gm.title .. " won the vote!" )
		end
	end
end

function PANEL:SetGMList( gamemodes, endTime )
	for _, gm in pairs( gamemodes ) do
		local mapPanel = self.mapPanels:Add( "GMPanel" )
		mapPanel:SetGamemode( gm )
		mapPanel:SetSize( 380, 150 )
		function mapPanel.DoClick( ) 
			self:HandleGMVote( gm )
		end
	end
	
	if MAPVOTE.ShowTimer then
		function self.timerLabel:Think( )
			if not self.textOverride then
				local timeleft = math.Round( endTime - CurTime( ) ) 
				self:SetText( "Vote ends in " .. ( timeleft > 0 and timeleft or 0 ) .. "s" )
			end
		end
	end
end

vgui.Register("GMVoteFrame", PANEL, "MapVoteFrame")
