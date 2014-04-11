/*
	HUD indicator for MAPVOTE.TimeBetweenVotes
*/

if not MAPVOTE.ShowHUDHint then
	return
end

if not MAPVOTE.TimeBetweenVotes then
	return
end

local function animSlide( self, anim, delta, data )
	self:InvalidateLayout( )
	
	if anim.Finished then
		return
	end
	
	self:SetPos( ScrW( ) / 2 - self:GetWide( ) / 2, Lerp( delta, data.From, data.To ) )
end

HudPanel = HudPanel or nil
local function createHud( )
	HudPanel = vgui.Create( "DPanel" )
	local pnl = HudPanel
	pnl:SetSize( 300, 30 )
	pnl:SetSkin( MAPVOTE.DermaSkin )
	derma.SkinHook( "Layout", "HudPanel", pnl )
	function pnl:Paint( w, h )
		local p = self:GetSkin( ).PaintHudPanel
		if p then
			return p( self, w, h )
		end
		if self.animSlide:Active( ) or self.centered then
			draw.RoundedBox( 6, 0, 0, w, h, Color( 0, 0, 0, 200 ), true, true, false, false )
		else
			draw.RoundedBoxEx( 6, 0, 0, w, h, Color( 0, 0, 0, 200 ), true, true, false, false )
		end
	end
	pnl:SetPos( ScrW( ) / 2 - pnl:GetWide( ) / 2, ScrH( ) - pnl:GetTall( ) )
	pnl:SetPaintedManually( true )
	pnl.animSlide = Derma_Anim( "Anim", pnl, animSlide )
	function pnl:Think( )
		self.animSlide:Run( )
	end
	
	pnl.label = vgui.Create( "DLabel", pnl )
	pnl.label:Dock( FILL )
	pnl.label:SetContentAlignment( 5 )
end

hook.Add( "HUDPaint", "DrawShit", function( )	
	if MAPVOTE:GetState( ) != "STATE_NOVOTE" then
		return
	end
	
	if not IsValid( HudPanel ) then
		createHud( )
	end
	
	HudPanel:SetPaintedManually( false )
	HudPanel:PaintManual( )
	HudPanel:SetPaintedManually( true )
end )

hook.Add( "Think", "kmv_showtimer", function( )
	if not MAPVOTE then return end
	if not IsValid( HudPanel ) then return end
	if MAPVOTE:GetState( ) != "STATE_NOVOTE" then
		if HudPanel.centered then
			HudPanel.animSlide:SetPos( ScrW( ) / 2 - pnl:GetWide( ) / 2, ScrH( ) - pnl:GetTall( ) )
		end
		return
	end
	
	local statevars = MAPVOTE:GetStatevars( )
	if not statevars.nextVote then
		return
	end
	
	local timeLeft = statevars.nextVote - CurTime( )
	local formatTbl = string.FormattedTime( timeLeft )
	local text
	if formatTbl.m > 0 then
		text = Format( "A mapvote will start in %02i:%02i minutes", formatTbl.m, formatTbl.s )
	else
		text = Format( "A mapvote will start in %02i seconds", formatTbl.s )
	end
	
	HudPanel.label:SetText( text )
	
	if MAPVOTE.EnableHUDHintWarnings then
		if timeLeft < 10 * 60 and timeLeft > ( 10 * 60 ) - 10 and not HudPanel.centered then
			local x, y = HudPanel:GetPos( )
			HudPanel.centered = true
			HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) / 2 - HudPanel:GetTall( ) * 2 } )
			timer.Simple( 5, function( )
				MAPVOTE.HudPanel.centered = false
				local x, y = HudPanel:GetPos( )
				HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) - HudPanel:GetTall( ) } )
			end )
		elseif timeLeft < 5 * 60 and timeLeft > ( 5 * 60 ) - 1 and not HudPanel.centered then
			local x, y = HudPanel:GetPos( )
			HudPanel.centered = true
			HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) / 2 - HudPanel:GetTall( ) * 2 } )
			timer.Simple( 10, function( )
				HudPanel.centered = false
				local x, y = HudPanel:GetPos( )
				HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) - HudPanel:GetTall( ) } )
			end )
		elseif timeLeft < 60 and timeLeft > 59 and not HudPanel.centered then
			HudPanel.centered = true
			local x, y = HudPanel:GetPos( )
			HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) / 2 - HudPanel:GetTall( ) * 2 } )
			timer.Simple( 60, function( )
				HudPanel.centered = false
				local x, y = HudPanel:GetPos( )
				HudPanel.animSlide:Start( 0.5, { From = y, To = ScrH( ) - HudPanel:GetTall( ) } )
			end )
		end
	end
end )