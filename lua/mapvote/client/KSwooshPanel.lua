local PANEL = {}

function PANEL:Init( )
	self.slideInDuration = 0.5
	self.operation = "slidein" 
	self.fadedOut = true
	self:SetTall( 0 )
	self.targetHeight = 10
end

function PANEL:fadeIn( )
	self.fadeStart = self.fadeStart or CurTime( )
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, 0, self.targetHeight, self.slideInDuration / 2 )
	self:SetTall( height )
	if self.shouldCenter then self:Center( ) end
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = false
		self.fading = false
		self:OnFadedIn( )
		return true
	end
	return false
end

function PANEL:OnFadedIn( )

end

function PANEL:OnFadedOut( )

end

function PANEL:fadeOut( )
	self.fadeStart = self.fadeStart or CurTime( )
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, self.targetHeight, -self.targetHeight, self.slideInDuration / 2 )
	height = math.Clamp( height, 0.01, self.targetHeight )
	self:SetTall( height )
	if self.shouldCenter then self:Center( ) end
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = true
		self.fading = false
		self:OnFadedOut( )
		return true
	end
	return false
end

function PANEL:startSlideIn( )
	if not self.fading or self.operation == "slideout" then
		self.fadingStarted = true
		self:SetTall( 0.001 )
		self.operation = "slidein"
		self.fadeStart = CurTime( )
		self.fading = true
	end
end

function PANEL:startSlideOut( )
	if not self.fading or self.operation == "slidein" then
		self.fadingStarted = true
		self:SetTall( 0.001 )
		self.operation = "slideout"
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