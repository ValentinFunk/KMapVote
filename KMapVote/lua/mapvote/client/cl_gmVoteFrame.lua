local PANEL = {}

function PANEL:Init( )
	self:SetSize( 800, 680 )
	
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
	for k, v in pairs( self.mapPanels:GetChildren( ) ) do
		if v:GetGamemode( ).name == wonGm then
			v:WonAnimation( )
		end
	end
end

function PANEL:SetGMList( gamemodes )
	for _, gm in pairs( gamemodes ) do
		local mapPanel = self.mapPanels:Add( "GMPanel" )
		mapPanel:SetGamemode( gm )
		mapPanel:SetSize( 380, 150 )
		function mapPanel.DoClick( ) 
			self:HandleGMVote( gm )
		end
	end
end

vgui.Register("GMVoteFrame", PANEL, "MapVoteFrame")
