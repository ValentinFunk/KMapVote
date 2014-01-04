local PANEL = {}

function PANEL:Init( )
	self.slideInterval = 0
	self.slides = {}
	self.activeSlideId = 1
	self.lastSlide = 0
end

function PANEL:addSlide( slide )

end

function PANEL:startSlideShow( )

end

function PANEL:stopSlideShow( )

end

function PANEL:gotoAndStop( intFrameNum )

end
vgui.Register( "KSlideShow", PANEL, "DButton" )

local PANEL = {}

function PANEL:Init( )
end

function PANEL:imageReceived( mat, tex )
	local tex = urltex.Cache[url]
	local mat = CreateMaterial("kmapv_urltex_" .. util.CRC(url .. SysTime()), "UnlitGeneric")
	mat:SetTexture("$basetexture", tex)
	print( "Received material" .. url )
end

function PANEL:Think( )
	
end
vgui.Register( "KMapVoteSlideShow", PANEL, "KSlideShow" )
