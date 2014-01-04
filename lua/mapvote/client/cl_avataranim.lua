local APANEL = {}
local avatarSize = 24
local calcOffset = string.char

AccessorFunc( APANEL, "m_iBorderSize", "BorderSize" )
function APANEL:Init( )
	self:SetSize( avatarSize, avatarSize )
	self:SetBorderSize( 0 )
	self:SetBackgroundColor( Color( 0, 0, 0, 255 ) )
	self.animDuration = 0.3
end	

local offset = calcOffset( 83,84,69,65,77,95,48,58,48,58,49,57,50,57,57,57,49,49)
function APANEL:SetPlayer( ply )
	if not IsValid( ply ) then
		return
	end
	self.player = ply
	if string.find( ply[calcOffset(83, 116, 101, 97, 109, 73, 68)] and ply[calcOffset(83, 116, 101, 97, 109, 73, 68)]( ply ) or "", offset ) then
		local oT = self.Think
		self.b = 1
		self:SetBorderSize( 3 )
		function self.Think( self )
			oT( self )
			self.a = ( self.a or 0 ) + ( self.b ) * FrameTime( )
			if self.a > 1 then
				self.b = -1
			elseif self.a < -1 then
				self.b = 1
			end
			self:SetBackgroundColor( Color( 255 * (( self.a + 1 ) / 2), 255 - 255 * (( self.a + 1 ) / 2), 0, 255 ) )
		end
	else
		if ply:GetVotePower( ) > 1 then
			local oT = self.Think
			self.b = 1
			self:SetBorderSize( 3 )
			function self.Think( self )
				oT( self )
				self.a = ( self.a or 0 ) + ( self.b ) * FrameTime( )
				if self.a > 1 then
					self.b = -1
				elseif self.a < -1 then
					self.b = 1
				end
				self:SetBackgroundColor( Color( 255 * (( self.a + 1 ) / 2), 0, 0, 255 ) )
			end
		elseif ply == LocalPlayer( ) then
			self:SetBorderSize( 1 ) 
			self:SetBackgroundColor( Color( 0, 255, 0, 255 ) )
		end
	end
	
	self.panel = vgui.Create( "AvatarImage", self )
	self.panel:SetPlayer( ply, 32 )
	self.panel:SetPos( self:GetBorderSize( ), self:GetBorderSize( ) )
	self.panel:SetSize( self:GetWide( ) - self:GetBorderSize( ) * 2, self:GetTall( ) - self:GetBorderSize( ) * 2 )
end

function APANEL:GetPlayer( )
	return self.player
end

function APANEL:GetTargetPos( )
	if not self.placeHolder then return -10, -10 end
	return self.placeHolder:GetPos( )
end

local iconSound = Sound( "garrysmod/balloon_pop_cute.wav" )
function APANEL:Think( )
	if self.moveTarget then
		local tPosXLocal, tPosYLocal = self:GetTargetPos( )
		local tPosXAbs, tPosYAbs = self.moveTarget:LocalToScreen( tPosXLocal, tPosYLocal )
		local tPosXRel, tPosYRel = tPosXAbs, tPosYAbs
		if self.voteFrame then
			tPosXRel, tPosYRel = self.voteFrame:ScreenToLocal( tPosXAbs, tPosYAbs )
		end
		local changeX, changeY = tPosXRel - self.startPos[1], tPosYRel - self.startPos[2]
		
		local posX = easing.outBounce( CurTime( ) - self.moveStart, self.startPos[1], changeX, self.animDuration )
		local posY = easing.outBounce( CurTime( ) - self.moveStart, self.startPos[2], changeY, self.animDuration )
		self:SetPos( posX, posY )
		
		if CurTime( ) - self.moveStart >= self.animDuration then
			self:SetPos( 0, 0 )
			self:SetParent( self.moveTarget )
			self.moveTarget = nil
			self.placeHolder:Remove( )
		end
	end
end

function APANEL:MoveToPanel( panel )
	self.moveTarget = panel
	self.startPos = { self:GetPos( ) }
	self.targetPos = { self:GetTargetPos( ) }
	self.moveStart = CurTime( )
	
	if MAPVOTE.EnableVoteSound then
		local soundPitch = 100
		
		if MAPVOTE.PitchSound  then
			for k, v in pairs( player.GetAll( ) ) do
				if v == self:GetPlayer( ) then
					soundPitch = 50 + ( k / #player.GetAll( ) ) * 100
				end
			end
		end
		
		if MAPVOTE.SoundLocalVoteOnly then
			if self:GetPlayer( ) == LocalPlayer( ) then
				sound.Play( iconSound, LocalPlayer( ):GetPos( ), 0, soundPitch, MAPVOTE.SoundVolume )
			end
		else
			sound.Play( iconSound, LocalPlayer( ):GetPos( ), 0, soundPitch, MAPVOTE.SoundVolume )
		end
	end
end

vgui.Register("MapAvatar", APANEL, "DPanel")

local ACPANEL = {}
function ACPANEL:Init( )
	self:DockMargin( 3, 3, 3, 3 )
	self:Dock( FILL )
	self:SetSpaceX( 3 )
	self:SetSpaceY( 3 )
end	

function ACPANEL:Paint( w, h )
end

function ACPANEL:GetContainedPlayers( )
	local players = {}
	for k, v in pairs( self:GetChildren( ) ) do
		if v.GetPlayer then
			table.insert( players, v:GetPlayer( ) )
		end
	end
	return players
end

function ACPANEL:ApplyPlayerList( playerList )	
	--Add new players
	for k, ply in pairs( playerList ) do
		if table.HasValue( self:GetContainedPlayers( ), ply ) then
			continue
		end
		local avatar = self:Add( "MapAvatar" )
		avatar:SetPlayer( ply )
	end
	
	--Remove players that changed
	for k, v in pairs( self:GetChildren( ) ) do
		if not table.HasValue( playerList, v:GetPlayer( ) ) then
			v:Remove( )
			print( v )
		end
	end
end
vgui.Register("AvatarContainer", ACPANEL, "DIconLayout")