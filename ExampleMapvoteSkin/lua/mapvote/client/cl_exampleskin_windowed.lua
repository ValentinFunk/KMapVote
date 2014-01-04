local SKIN = {}
SKIN.Name = "MyCustomKMapVoteSkin"

local function loadSkin( )

SKIN.BGColorFrom = Color( 19, 37, 55 )
SKIN.BGColorTo = Color( 21, 54, 55 )
SKIN.PanelBG = Color( 0, 108, 128 )
SKIN.TextColor = Color( 235, 202, 184 )
SKIN.ButtonColor = Color( 87, 118, 145 )
SKIN.HighlightColor = Color( 254, 131, 21 )
SKIN.RateMapBarColor = Color( 21, 94, 55 )
SKIN.RatingsBarColor =  Color( 20, 20, 20, 200 )

surface.CreateFont( "LogoFontMapVoteDefault", {
 font = "Arial",
 size = 74,
 weight = 9,
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

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )
SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

SKIN.LogoFont = "LogoFontMapVoteDefault"

--Layout Hooks
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
	panel:Center( )
	function panel:PerformLayout( )
		local y = 0
		for k, v in pairs( self:GetChildren( ) ) do
			local x, _y = v:GetPos( )
			_y = _y + v:GetTall( )
			if _y > y then
				y = _y
			end
		end
		self:SetTall( y + 10 )
	end
	
	if MAPVOTE.AllowClose then
		local closeButton = vgui.Create('DButton', panel)
		closeButton:SetFont('marlett')
		closeButton:SetText('r')
		closeButton:SetColor(Color(0, 0, 0))
		closeButton:SetSize(30, 30)
		closeButton:SetDrawBackground(true)
		function closeButton.PerformLayout( )
			closeButton:SetPos(panel:GetWide() - 50, 10)
		end
		closeButton.DoClick = function()
			panel:Close( )
			STATEVARS.PanelClosed = true
			gui.EnableScreenClicker( false )
		end
	end
end

local id = os.time( ) .. "MapVoteGradient" 
function SKIN:PaintMapVoteFrame( panel, w, h )
	GradientBox( id, 0, 0, w, h, self.BGColorFrom, self.BGColorTo, GRADIENT_VERTICAL, false )
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
	surface.SetDrawColor( self.RateMapBarColor )
	surface.DrawRect( 0, 0, w, h )
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
	draw.RoundedBox( 6, 0, 0, w, h, color_white )
	draw.RoundedBox( 6, 1, 1, w - 2, h - 2, color )
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

derma.DefineSkin( SKIN.Name, "Customized KMapVoteSkin", SKIN )

end --function loadSkin

hook.Add( "Initialize", SKIN.Name .. "init", loadSkin, 100 )
hook.Add( "OnReloaded", SKIN.Name .. "reload", loadSkin, 100 )