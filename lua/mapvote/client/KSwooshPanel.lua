local PANEL = {}

function PANEL:Init( )
	self.slideInDuration = 0.5
	self.operation = "slidein" 
	self.fadedOut = true
	self:SetTall( 0 )
	self.targetHeight = 400
	print( "Init" )
end

local origSetSize
function PANEL:SetSize( w, h )
	origSetSize = origSetSize or vgui.GetControlTable( "DFrame" ).SetSize
	if self.fadingStarted then
		origSetSize( self, w, h )
		print( "setsize", w, h )
	else
		self.targetHeight = h
		origSetSize( self, w, 0.01 )
		print( "target",  h )
	end
end


function PANEL:fadeIn( )
	self.fadeStart = self.fadeStart or CurTime( )
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, 0, self.targetHeight, self.slideInDuration / 2 )
	print( height, self.targetHeight )
	self:SetTall( height )
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = false
		return true
	end
	return false
end

function PANEL:fadeOut( )
	self.fadeStart = self.fadeStart or CurTime( )
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, self.targetHeight, -self.targetHeight, self.slideInDuration / 2 )
	height = math.Clamp( height, 0.01, self.targetHeight )
	print( height )
	self:SetTall( height )
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = true
		return true
	end
	return false
end

function PANEL:startSlideIn( )
	self.fadingStarted = true
	self:SetTall( 0.001 )
	print( "startslidein", self.targetHeight )
	self.operation = "slidein"
	if not self.fading then
		self.fadeStart = CurTime( )
		self.fading = true
	else
		self.fadeStart = CurTime( )
		self.fading = true
	end
end

function PANEL:startSlideOut( )
	self.fadingStarted = true
	self:SetTall( 0.001 )
	self.operation = "slideout"
	if not self.fading then
		self.fadeStart = CurTime( )
		self.fading = true
	else
		self.fadeStart = CurTime( )
		self.fading = true
	end
end

function PANEL:Think( )
	if self.operation == "slidein" then
		if self:fadeIn( ) then
			self.fading = false
			self.operation = ""
		end
	elseif self.operation == "slideout" then
		if self:fadeOut( ) then
			self.fading = false
			self.operation = ""
		end
	end
end
vgui.Register( "KMVSwooshPanel", PANEL, "DPanel" )