local PANEL = {}

surface.CreateFont( "MapName", {
 font = "Arial",
 size = 16,
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

surface.CreateFont( "VoteScore", {
 font = "Coolvetica",
 size = 16,
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
	self:SetSkin( MAPVOTE.DermaSkin )
	self:DockPadding( 5, 5, 5, 5 )
	
	self.icon = vgui.Create( "DImage", self )
	self.icon:Dock( TOP )
	self.icon:SetSize( 128, 128 )
	self.icon:SetMouseInputEnabled( true )
	function self.icon.OnMousePressed( )
		self:DoClick( )
	end
	if LocalPlayer( ):CanOverride( ) then
		self.adminOverride = vgui.Create( "DButton", self.icon )
		self.adminOverride:DockMargin( 5, 5, 5, 5 )
		self.adminOverride:SetText( "Force" )
		self.adminOverride:Dock( BOTTOM )
		self.adminOverride:SetColor( self:GetSkin( ).TextColor or color_white )
		function self.adminOverride.DoClick( )
			Derma_Query( "Are you sure you want to force this map?", 
				"Please confirm",
				"Yes", function( )
					net.Start( "MapVoteAdminOverride" )
						net.WriteString( self.map.name )
					net.SendToServer( )
				end,
				"No", function( )
				end 
			)
		end
		Derma_Hook( self.adminOverride, "Paint", "Paint", "ForceButton" )
	end
	
	self.ratingsBar = vgui.Create( "DPanel", self.icon )
	self.ratingsBar:Dock( TOP )
	self.ratingsBar:SetTall( 25 )
	Derma_Hook( self.ratingsBar, "Paint", "Paint", "RatingsBar" )
	
	self.ratingsLayout = vgui.Create( "DIconLayout", self.ratingsBar )
	self.ratingsLayout:SetWide( 16 * 5 + 4 * 2 )
	self.ratingsLayout:DockMargin( 5, ( 25 - 16 ) / 2, 5, 0 )
	self.ratingsLayout:Dock( LEFT )
	self.ratingsLayout:SetSpaceX( 2 )
	function self.ratingsLayout:setRating( stars )
		stars = math.Round( stars )
		for k, v in pairs( self:GetChildren( ) ) do
			v:Remove( )
		end
		for i = 1, stars do 
			local img = self:Add( "DImage" )
			img:SetImage( "icon16/star.png" )
			img:SetSize( 16, 16 )
		end
		for i = ( stars + 1 ), 5 do
			local img = self:Add( "DImage" )
			img:SetImage( "icon16/star.png" )
			img:SetImageColor( Color( 100, 100, 100, 255 ) )
			img:SetSize( 16, 16 )
		end
	end
	
	self.numRatingsLabel = vgui.Create( "DLabel", self.ratingsBar )
	self.numRatingsLabel:Dock( LEFT )
	self.numRatingsLabel:SetFont( self:GetSkin( ).NumRatingsFont or "MapName" )
	
	self.label = vgui.Create( "DLabel", self )
	self.label:SetColor( self:GetSkin( ).TextColor or color_white )
	self.label:DockMargin( 0, 5, 0, 0 )
	self.label:Dock( TOP )
	self.label:SetFont( self:GetSkin( ).MapPanelLabelFont or "MapName" )
	self.label:SetContentAlignment( 5 )
	
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:DockMargin( 0, 5, 0, 0 )
	self.scroll:Dock( TOP )
	self.scroll:SetTall( 54 )
	Derma_Hook( self.scroll, "Paint", "Paint", "AvatarContainer" )
	function self.scroll.OnMousePressed( )
		self:DoClick( )
	end
	
	self.voterPanels = vgui.Create( "AvatarContainer", self.scroll )
	self.voterPanels:DockMargin( 0, 1, 0, 0 )
	self.voterPanels:Dock( FILL )
	self.voterPanels:SetTall( 54 )
	self.voterPanels:SetMouseInputEnabled( true )
	function self.voterPanels.OnMousePressed( )
		self:DoClick( )
	end
	
	self.scoreLabel = vgui.Create( "DLabel", self )
	self.scoreLabel:DockMargin( 0, 5, 0, 0 )
	self.scoreLabel:Dock( TOP )
	self.scoreLabel:SetText( "Score: " )
	self.scoreLabel:SetColor( self:GetSkin( ).TextColor or color_white )
	
	self:SetText( "" )
	self:InvalidateLayout( true )
	
	derma.SkinHook( "Layout", "MapPanel", self )
end	

function PANEL:SetMap( map )
	self.ratingsLayout:setRating( map.ratingAverage or 2 )
	self.numRatingsLabel:SetText( "(" .. ( map.ratingCount or 1337 ) .. ")" )
	self.map = map
	self.icon.materials = {}
	if MAPVOTE.UseCDN then
		local url = Format( "http://kamshak.com/mapicons/%s.png", map.name )
		urltex.GetMaterialFromURL( url,
			function( mat, tex )
				local tex = urltex.Cache[url]
				local mat0 = CreateMaterial("kmapv_urltex_" .. util.CRC(url .. SysTime()), "UnlitGeneric")
				mat0:SetTexture("$basetexture", tex)
				timer.Simple( 0.1, function( )
					if IsValid( self.icon ) then
						table.insert( self.icon.materials, mat0 )
						self.icon:SetMaterial( mat0 )
					end
				end )
			end,
			false,
			"UnlitGeneric",
			128
		)
	else
		local mat0 = Material( Format( "mapicons/%s.png", map.name ) )
		table.insert( self.icon.materials, mat0 )
		self.icon:SetMaterial( mat0 )
	end
	
	self.icon.startedHover = 0
	self.icon.watchingHover = false
	
	function self.icon:OnIconReceived( mat, tex, url )
		local tex = urltex.Cache[url]
		local mat = CreateMaterial("kmapv_urltex_" .. util.CRC(url .. SysTime()), "UnlitGeneric")
		mat:SetTexture("$basetexture", tex)
		table.insert( self.materials, mat )
		print( "Got ", mat, tex )
	end
	
	timer.Simple( 0.1, function( )
		if not MAPVOTE.IconCounts[map.name] then return end
		for i = 1, MAPVOTE.IconCounts[map.name] - 1 do
			if MAPVOTE.UseCDN then
				local url = Format( "http://kamshak.com/mapicons/%s(%i).png", map.name, i )
				urltex.GetMaterialFromURL( url,
					function( mat, tex ) 
						if self.icon then self.icon:OnIconReceived( mat, tex, url ) end
					end,
					false,
					"UnlitGeneric",
					128
				)
			else
				local mat = Material( Format( "mapicons/%s(%i).png", map.name, i ) )
				table.insert( self.icon.materials, mat )
			end
		end
	end )
	
	function self.icon:Think( )
		if not MAPVOTE.IconCounts[map.name] or MAPVOTE.IconCounts[map.name] == 1 then
			return
		end
		
		if not self.Hovered then
			self.watchingHover = false
			if self.materials[1] then
				self:SetMaterial( self.materials[1] )
			end
			return
		end
		
		if not self.watchingHover then
			self.watchingHover = true
			self.startedHover = CurTime( )
		end
		
		if CurTime( ) > self.startedHover + 0.3 then
			local timeHovered = CurTime( ) - self.startedHover
			local iconIndex = math.floor( timeHovered ) % #self.materials + 1
	
			if self.materials[iconIndex] then
				self:SetMaterial( self.materials[iconIndex] )
				self:InvalidateParent( )
				self.mat = self.materials[iconIndex]
			end
		end
	end
	
	if map.name == game.GetMap( ) then
		self.label:SetText( "Extend current map" )
	else
		self.label:SetText( map.label or map.name )
	end
end

function PANEL:GetMap( )
	return self.map
end

function PANEL:Think( )
	if self.icon then 
		self.icon.Hovered = self.Hovered or self:IsChildHovered( 3 )
	end
	
	local score = 0
	for k, ply in pairs( self.voterPanels:GetContainedPlayers( ) ) do
		score = score + ply:GetVotePower( )
	end
	self.scoreLabel:SetText( "Score: " .. score )
	self.scoreLabel:SizeToContents( )
	
	if self.Flashing then
		if not self.blip then
			self.blip = math.Round( CurTime( ) * 2 ) % 2
		end
		if math.Round( CurTime( ) * 2 ) % 2 != self.blip then
			surface.PlaySound( Sound( "buttons/blip1.wav" ) )
			self.blip = math.Round( CurTime( ) * 2 ) % 2
		end
	end
end

function PANEL:WonAnimation( )
	self.Flashing = true
end

Derma_Hook( PANEL, "Paint", "Paint", "MapPanel" )
vgui.Register("MapPanel", PANEL, "DButton")
