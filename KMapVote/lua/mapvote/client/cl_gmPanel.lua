local PANEL = {}

function PANEL:Init( )
	self:SetSkin( MAPVOTE.DermaSkin )
	
	for k, v in pairs( self:GetChildren( ) ) do
		v:Remove( )
	end

	self:DockPadding( 5, 5, 5, 5 )
	
	local topPanel = vgui.Create( "DPanel", self )
	function topPanel:Paint( w, h )
	end
	topPanel:DockMargin( 5, 5, 5, 5 )
	topPanel:Dock( TOP )
	function topPanel.OnMousePressed( )
		self:DoClick( )
	end
	
	
	self.icon = vgui.Create( "DImage", topPanel )
	self.icon:Dock( LEFT )
	self.icon:SetSize( 24, 24 )
	self.icon:SetMouseInputEnabled( true )
	function self.icon.OnMousePressed( )
		self:DoClick( )
	end
	
	self.label = vgui.Create( "DLabel", topPanel )
	self.label:SetColor( self:GetSkin( ).TextColor or color_white )
	self.label:DockMargin( 5, 5, 0, 0 )
	self.label:Dock( LEFT )
	self.label:SetFont( self:GetSkin( ).MapPanelLabelFont or "MapName" )
	self.label:SetContentAlignment( 4 )
	function self.label.OnMousePressed( )
		self:DoClick( )
	end
	
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
	
	local bottomPanel = vgui.Create( "DPanel", self )
	bottomPanel:DockMargin( 5, 5, 5, 5 )
	bottomPanel:Dock( TOP )
	Derma_Hook( bottomPanel, "Paint", "Paint", "RateMapPanel" )
	
	self.scoreLabel = vgui.Create( "DLabel", bottomPanel )
	self.scoreLabel:Dock( LEFT )
	self.scoreLabel:SetText( "Score: " )
	self.scoreLabel:SetFont( self:GetSkin( ).fontName )
	self.scoreLabel:SetColor( self:GetSkin( ).TextColor or color_white )
	self.scoreLabel:SizeToContents( )
	
	if LocalPlayer( ):CanOverride( ) then
		self.adminOverride = vgui.Create( "DButton", bottomPanel )
		self.adminOverride:DockMargin( 5, 5, 0, 0 )
		self.adminOverride:SetText( "Force" )
		self.adminOverride:Dock( RIGHT )
		self.adminOverride:SetColor( self:GetSkin( ).TextColor or color_white )
		function self.adminOverride.DoClick( )
			Derma_Query( "Are you sure you want to force this gamemode?", 
				"Please confirm",
				"Yes", function( )
					net.Start( "GMVoteAdminOverride" )
						net.WriteString( self.gm.name )
					net.SendToServer( )
				end,
				"No", function( )
				end 
			)
		end
		function self.adminOverride:Paint( w, h )
			if self.Hovered then
				surface.SetDrawColor( MAPVOTE.HighlightColor )
			else
				surface.SetDrawColor( MAPVOTE.ButtonColor )
			end
			surface.DrawRect( 0, 0, w, h )
			return false
		end
	end
	
	self:SetText( "" )
	self:InvalidateLayout( true )
	derma.SkinHook( "Layout", "GMPanel", self )
end	

function PANEL:GetGamemode( )
	return self.gm
end

function PANEL:GetMap( )
	return self.gm
end

function PANEL:SetGamemode( gm )
	self.gm = gm
	self.icon:SetImage( "gmicons/" .. gm.name .. ".png" )
	print( "materials/gmicons/" .. gm.name .. ".png" )
	if not file.Exists( "materials/gmicons/" .. gm.name .. ".png", "GAME" ) then
		function self.icon:Paint( w, h )
			surface.SetDrawColor( Color( 200, 90, 90, 255 ) )
			surface.DrawRect( 0, 0, w, h )
			draw.SimpleText( "Missing Icon", "MapName", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	
	if gm.name == GAMEMODE.FolderName then
		self.label:SetText( "Extend current gamemode" )
	else
		self.label:SetText( gm.title )
	end
	self.label:SizeToContents( )
end
vgui.Register("GMPanel", PANEL, "MapPanel")
