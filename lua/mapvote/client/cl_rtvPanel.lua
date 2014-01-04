local PANEL = {}
Derma_Hook( PANEL, "Paint", "Paint", "RTVPanel" )
function PANEL:Init( )	
	self:SetSkin( MAPVOTE.DermaSkin )
	self:DockPadding( 5, 5, 5, 5 )
	self:SetContentAlignment( 5 )
	self:SetBackgroundColor( Color( 90, 90, 90, 180 ) )
	
	local container = vgui.Create( "DPanel", self )
	function container:Paint( ) end
	container:Dock( FILL )
	
	self.label = vgui.Create( "DLabel", container )
	--panel.label:SetColor( Color( 224, 209, 163, 255 ) )
	self.label:DockMargin( 0, 5, 0, 0 )
	self.label:Dock( TOP )
	self.label:SetContentAlignment( 5 )
	
	self.voterPanels = vgui.Create( "AvatarContainer", container )
	self.voterPanels:DockMargin( 0, 1, 0, 0 )
	self.voterPanels:Dock( FILL )
	self.voterPanels:SetTall( 54 )
	self.voterPanels:SetMouseInputEnabled( true )
	
	self.timeLeftLabel = vgui.Create( "DLabel", container )
	self.timeLeftLabel:DockMargin( 0, 5, 0, 0 )
	self.timeLeftLabel:SetContentAlignment( 5 )
	self.timeLeftLabel:Dock( TOP )
	
	self:InvalidateLayout( true )

	derma.SkinHook( "Layout", "RTVPanel", self )
end	

function PANEL:UpdateVotes( votes )
	self.AvatarPanels = self.AvatarPanels or { }
	for k, ply in pairs( votes ) do
		if not self.AvatarPanels[ply] then
			local avatar = vgui.Create( "MapAvatar" )
			avatar:SetPlayer( ply )
			avatar:SetPos( ScrW( ) / 2, ScrH( ) / 2 ) --Move in from middle of the screen
			self.AvatarPanels[ply] = avatar
		end
		
		if self.voterPanels != self.AvatarPanels[ply]:GetParent( ) then
			if IsValid( self.AvatarPanels[ply].placeHolder ) then
				self.AvatarPanels[ply].placeHolder:Remove( )
			end
			
			local placeHolder = self.voterPanels:Add( "DPanel" )
			placeHolder:SetSize( 24, 24 )
			function placeHolder:Paint( ) end
			
			self.AvatarPanels[ply].placeHolder = placeHolder
			self.AvatarPanels[ply]:SetPos( ScrW( ) / 2, ScrH( ) / 2 )
			self.AvatarPanels[ply]:MoveToPanel( self.voterPanels )
		end
	end
end

function PANEL:Remove( )
	if self.AvatarPanels then
		for k, v in pairs( self.AvatarPanels ) do
			if IsValid( v ) then
				v:Remove( )
			end
		end
	end
	self.BaseClass.Remove( self )
end

function PANEL:SetStartingPlayer( ply )
	self.label:SetText( ply:Nick( ) .. " has started a vote to change the map. Say !rtv to vote, too." )
	self:UpdateVotes( {ply} ) --No data yet at this point, starting player as initial voter
end

function PANEL:SetEndTime( time )
	self.endTime = time
end	

function PANEL:Think( )
	local score = 0
	for k, ply in pairs( self.voterPanels:GetContainedPlayers( ) ) do
		if MAPVOTE.RTVUserVotePower then
			score = score + ply:GetVotePower( )
		else
			score = score + 1
		end
	end
	self.timeLeftLabel:SetText( score .. " / " .. math.Round( #player.GetAll( ) * MAPVOTE.RTVRequiredFraction ) .. " reached, Time Left: " .. math.Round( self.endTime - CurTime( ) ) )
end
vgui.Register("RtvPanel", PANEL, "DPanel")
