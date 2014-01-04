local SKIN = {}
SKIN.Name = "KMapVotePulseFS"

local function loadSkin( )

SKIN.BGColorFrom = Color( 0, 0, 0 )
SKIN.BGColorTo = Color( 255, 140, 6 )
SKIN.PanelBG = Color( 255, 140, 6 ) --Color( 201, 103, 6 )
SKIN.TextColor = Color( 0, 0, 0 )
SKIN.ButtonColor = Color(255, 175, 49 )
SKIN.HighlightColor = Color(255, 100, 10 )
SKIN.RateMapBarColor = Color( 255, 140, 6 )
SKIN.RatingsBarColor =  Color( 20, 20, 20, 200 )

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )
SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

SKIN.fontName = "FlatElement"
SKIN.BigTitleFont = "LibKLarge"
SKIN.MapPanelLabelFont = "LibKHeading"
SKIN.NumRatingsFont = "DermaDefault"

SKIN.LogoFont = "LibKHeading"

--Layout Hooks
function SKIN:LayoutWaitPanel( panel )
end

function SKIN:LayoutRTVPanel( panel )
	
end

function SKIN:LayoutMapPanel( panel )
end

function SKIN:LayoutGMPanel( panel )
end

--GMVoteFrame inherits from MapVoteFrame so the 
--hook below will be called first. Dont c&p code, only 
--do things that need to differ here.
function SKIN:LayoutGMVoteFrame( panel )

end

function SKIN:LayoutMapVoteFrame( panel )
	panel:SetSize( ScrW( ), ScrH( ) )
	
	if MAPVOTE.AllowClose then
		local closeButton = vgui.Create('DButton', panel)
		closeButton:SetFont('marlett')
		closeButton:SetText('r')
		closeButton:SetColor(Color(0, 0, 0))
		closeButton:SetSize(30, 30)
		closeButton:SetDrawBackground(true)
		function closeButton.PerformLayout( )
			closeButton:SetPos(panel:GetWide() - 40, 15)
		end
		closeButton.DoClick = function()
			panel:Close( )
			STATEVARS.PanelClosed = true
			gui.EnableScreenClicker( false )
		end
	end
	
	local opl = panel.mapPanels.PerformLayout
	function panel.mapPanels:PerformLayout( )
		self:SetWide( 146 * 5 + 10 * 4 )
		opl( self )
		local spaceW = self:GetParent( ):GetWide( ) - self:GetWide( )
		local spaceH = self:GetParent( ):GetTall( ) - self:GetTall( )
		self:DockMargin( spaceW / 2, 10, 0, 0 )
	end
	panel.mapPanels:PerformLayout( )
	
	if panel.logo then
		function panel.logo:PerformLayout( )
			local ratio = MAPVOTE.LogoAspect
			local wantedW = math.Round( math.Clamp( ScrW( ) * MAPVOTE.LogoScreenScale, MAPVOTE.LogoMinWidth, MAPVOTE.LogoMaxWidth ) )
			local space = ScrW( ) - wantedW
			self:DockMargin( space / 2, 0, space / 2, 0 )
			self:SetSize( wantedW, wantedW * ratio )
		end
		panel.logo:PerformLayout( )
	end
end

local id = os.time( ) .. "MapVoteGradienyvxcyt" 
function SKIN:PaintMapVoteFrame( panel, w, h )
	draw.GradientBox( id, 0, 0, w, h, self.BGColorFrom,  self.BGColorTo, GRADIENT_VERTICAL, true, Color( 0.6, 0.6, 0.6 ), Color( 0.9, 0.9, 0.9 ) )
end

function SKIN:PaintAvatarContainer( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
end

--Ratings bar on top of a map panel
function SKIN:PaintRatingsBar( panel, w, h )
	surface.SetDrawColor( self.RatingsBarColor )
	surface.DrawRect( 0, 0, w, h )
end

--The Rate Last Map area
function SKIN:PaintRateMapPanel( panel, w, h )
	panel:DockPadding( 15, 15, 15, 15 )
	draw.RoundedBox( 6, 5, 5, w - 10, h - 10, self.RateMapBarColor )
end

function SKIN:PaintMapPanel( panel, w, h )
	local color_normal, color_highlight = self.PanelBG, self.HighlightColor
	local color = color_normal
	if panel.Hovered or panel:IsChildHovered( 5 ) then
		color = color_highlight
	else
		color = color_normal
	end
	
	--True when the map won
	if panel.Flashing then
		if math.Round( CurTime( ) * 2 ) % 2 == 1 then
			color = color_highlight
		else
			color = color_normal
		end
	end
	color = color or Color( 40, 40, 40 ) --WTF
	draw.RoundedBox( 6, 0, 0, w , h , color )
end

function SKIN:PaintForceButton( panel, w, h )
	if panel.Hovered then
		surface.SetDrawColor( self.HighlightColor )
	else
		surface.SetDrawColor( self.ButtonColor )
	end
	surface.DrawRect( 0, 0, w, h )
	return false
end

derma.DefineSkin( SKIN.Name, "Fullscreen customized KMapVote Skin", SKIN )

end --function loadSkin

hook.Add( "Initialize", "LoadKMapVoteFSSkin" .. SKIN.Name, loadSkin )
hook.Add( "OnReloaded", "ReLoadKMapVoteFSSkin" .. SKIN.Name, loadSkin )