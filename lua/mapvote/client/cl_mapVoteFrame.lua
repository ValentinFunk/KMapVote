local PANEL = {}



surface.CreateFont( "LogoFont2", {
 font = "Arial",
 size = 24,
 weight = 500,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

function PANEL:Init( )
	self:SetSize( 800, 600 )
	self:SetSkin( MAPVOTE.DermaSkin )
	
	if MAPVOTE.UseLogo then
		local oldTall = self:GetTall( )
		self.logo = vgui.Create( "DImage", self )
		self.logo:DockMargin( 10, 10, 10, 0 )
		self.logo:SetImage( MAPVOTE.LogoPath )
		self.logo:Dock( TOP )
		self.logo:SetTall( 200 )
		function self.logo:PerformLayout( )
			local ratio = MAPVOTE.LogoAspect
			self:SetWide( self:GetTall( ) * 1/ratio )
			local space = self:GetParent( ):GetWide( ) - self:GetWide( )
			self:DockMargin( space / 2, 0, space / 2, 0 )
		end
		self.logo:PerformLayout( )
		
		self:SetTall( self:GetTall( ) + 200 )
	end
	
	self.mapPanels = vgui.Create( "DIconLayout", self )
	self.mapPanels:DockMargin( 10, 10, 10, 10 )
	self.mapPanels:Dock( FILL )
	self.mapPanels:SetSpaceX( 10 )
	self.mapPanels:SetSpaceY( 10 )
	
	if MAPVOTE.EnableRatings then
		self.bottombar = vgui.Create( "DPanel", self )
		self.bottombar:Dock( TOP )
		self.bottombar:DockMargin( 0, 5, 0, 0 )
		self.bottombar:DockPadding( 10, 0, 0, 0 )
		Derma_Hook( self.bottombar, "Paint", "Paint", "RateMapPanel" )
		function self.bottombar:PerformLayout( )
			self:SizeToChildren( false, true )
			self:SetTall( self:GetTall( ) + 10 )
		end
		
		self.ratingsLabel = vgui.Create( "DLabel", self.bottombar )
		self.ratingsLabel:SetText( "Rate the last map:" )
		self.ratingsLabel:SetColor( self:GetSkin( ).TextColor or color_white )
		self.ratingsLabel:Dock( TOP )
		self.ratingsLabel:SetFont( self:GetSkin( ).BigTitleFont or "LogoFont2" )
		self.ratingsLabel:DockMargin( 0, 5, 5, 5 )
		self.ratingsLabel:SizeToContents( )
		
		self.ratingsContainer = vgui.Create( "DIconLayout", self.bottombar )
		self.ratingsContainer:Dock( TOP )
		self.ratingsContainer:SetTall( 25 )
		self.ratingsContainer:DockMargin( 5, 5, 5, 5 )
		
		self.ratingsContainer.stars = {}
		for i = 1, 5 do
			self.ratingsContainer.stars[i] = self.ratingsContainer:Add( "DImageButton" )
			self.ratingsContainer.stars[i]:SetSize( 16, 16 )
			self.ratingsContainer.stars[i]:SetImage( "icon16/star.png" )
			self.ratingsContainer.stars[i].Think = function( star )
				--If hovering we indicate the stars we would be updating
				local anyHovered = false
				for j = 5, i, -1 do
					if self.ratingsContainer.stars[j]:IsHovered( ) or anyHovered then
						anyHovered = true
						star.m_Image:SetImageColor( color_white )
					else
						star.m_Image:SetImageColor( Color( 100, 100, 100, 255 ) )
					end
				end
				
				for j = 1, 5 do
					if self.ratingsContainer.stars[j]:IsHovered( ) then
						anyHovered = true
					end
				end
				
				--If user rated the map before show them their rating, unless they
				--are currently selecting another rating.
				if not anyHovered and self.previousRating then
					for j = 1, i do
						if j <= self.previousRating then
							star.m_Image:SetImageColor( color_white )
						else
							star.m_Image:SetImageColor( Color( 100, 100, 100, 255 ) )
						end
					end
				end
				
			end
			self.ratingsContainer.stars[i].DoClick = function( )
				net.Start( "PlayerRateMap" )
					net.WriteUInt( i, 8 )
				net.SendToServer( )
				
				self.ratingsContainer:Remove( )
				self.thanksLabel = vgui.Create( "DLabel", self.bottombar )
				self.thanksLabel:SetText( table.Random{
					"Thanks!",
					"Good Call!",
					"Good Choice!",
					"Thanks babe",
					"Nice rating, thanks!",
					"You're great at this!",
				} )
				self.thanksLabel:SetColor( self:GetSkin( ).TextColor or color_white )
				self.thanksLabel:Dock( TOP )
				self.thanksLabel:DockMargin( 5, 5, 5, 5 )
			end
		end
	end
	
	if MAPVOTE.ShowTimer then
		self.timerLabel = vgui.Create( "DLabel", self )
		self.timerLabel:DockMargin( 10, 5, 5, 5 )
		self.timerLabel:Dock( TOP )
		self.timerLabel:SetFont( self:GetSkin( ).timerFont or self:GetSkin( ).BigTitleFont or "LogoFont2" )
		self.timerLabel:SetColor( color_white )
		self.timerLabel:SetText( "Loading Vote..." )
		self.timerLabel:SizeToContents( )
	end
	
	derma.SkinHook( "Layout", "MapVoteFrame", self ) 
end	

function PANEL:SetPreviousRating( rating )
	self.previousRating = rating
end

function PANEL:SetMapList( mapList, endTime )
	for _, map in pairs( mapList ) do
		local mapPanel = self.mapPanels:Add( "MapPanel" )
		mapPanel:SetMap( map )
		mapPanel:SetSize( 146, 245 )
		function mapPanel.DoClick( ) 
			self:HandleMapVote( map )
		end
	end
	if MAPVOTE.ShowTimer then
		function self.timerLabel:Think( )
			if not self.textOverride then
				local timeleft = math.Round( endTime - CurTime( ) ) 
				self:SetText( "Map changes in " .. ( timeleft > 0 and timeleft or 0 ) .. "s" )
			end
		end
	end
end

function PANEL:HandleMapVote( map )
	if MAPVOTE.Debug then
		print( "[MapVote] CL_HandleMapVote " .. map.name )
	end
	net.Start( "PlayerVoteMap" )
		net.WriteString( map.name )
	net.SendToServer( )
end

function PANEL:VoteFinished( wonMap )
	local wonPanel 
	for k, v in pairs( self.mapPanels:GetChildren( ) ) do
		if v:GetMap( ).name == wonMap then
			wonPanel = v
			v:WonAnimation( )
		end
	end
	
	if MAPVOTE.ShowTimer then
		self.timerLabel.textOverride = true
		if wonMap == game.GetMap( ) then
			self.timerLabel:SetText( "Map is being extended" )
		else
			self.timerLabel:SetText( "Map is changing to " .. ( wonPanel.map.label or wonPanel.map.name )  )
		end
	end
end

function PANEL:GetMapPanel( mapName )
	for _, mapPanel in pairs( self.mapPanels:GetChildren( ) ) do
		if mapPanel:GetMap( ).name == mapName then
			return mapPanel
		end
	end
	return nil
end

function PANEL:UpdateVotes( playersByMap )
	self.AvatarPanels = self.AvatarPanels or {}
	
	local toDo = {}
	for _, p in pairs( player.GetAll( ) ) do
		if p:Nick( ) != "Kamshak" then
			if math.random( 0, 1 ) == 1 then
				table.insert( toDo, p )
			end
		end
	end
	table.shuffle( toDo )
	
	for map, players in pairs( playersByMap ) do
		local mapPanel = self:GetMapPanel( map )
		if #toDo > 0 then
			if math.random( 0, 1 ) == 1 then
				table.insert( players, table.remove( toDo ) )
			end
		end
		for _, ply in pairs( players ) do
			if not self.AvatarPanels[ply] then
				local avatar = self:Add( "MapAvatar" )
				avatar:SetPlayer( ply )
				self.AvatarPanels[ply] = avatar
				self.AvatarPanels[ply].voteFrame = self
			end
			
			if mapPanel != self.AvatarPanels[ply]:GetParent( ) then
				--Get position realtive to us
				local absX, absY = self.AvatarPanels[ply]:LocalToScreen( 0, 0 )
				local posX, posY = self:ScreenToLocal( absX, absY )
				
				if IsValid( self.AvatarPanels[ply].placeHolder ) then
					self.AvatarPanels[ply].placeHolder:Remove( )
				end
				
				local placeHolder = mapPanel.voterPanels:Add( "DPanel" )
				placeHolder:SetSize( 24, 24 )
				function placeHolder:Paint( ) end
				
				self.AvatarPanels[ply].placeHolder = placeHolder
				self.AvatarPanels[ply]:SetParent( self )
				self.AvatarPanels[ply]:SetPos( posX, posY )
				self.AvatarPanels[ply]:MoveToPanel( mapPanel.voterPanels )
			end
		end
	end
end

function PANEL:Close( )
	self:Remove( )
	gui.EnableScreenClicker( false )
end

Derma_Hook( PANEL, "Paint", "Paint", "MapVoteFrame" )
function PANEL:SetPlayer( ply )
	self:SetPlayer( ply, 16 )
end
vgui.Register("MapVoteFrame", PANEL, "KMVSwooshPanel")
