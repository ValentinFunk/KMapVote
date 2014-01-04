--TODO: Clean up! This is LibK functionality!
local materials2 = {}
function GradientBox( id, x, y, w, h, from, to, dir, pulse )
	dir = dir or GRADIENT_VERTICAL
	pulse = pulse or false
	if not materials2[id] then
		if not GAMEMODE.CanRender then
			return
		end
		print( "Creating" )
		if dir == GRADIENT_VERTICAL then
			materials2[id] = createGradientMaterial( id, 1, h, from, to, dir )
		else
			materials2[id] = createGradientMaterial( id, w, 1, from, to, dir )
		end
	end
	if pulse then
		local matrix = materials2[id]:GetString( "$color" )
		matrix = Vector( ( math.sin( CurTime( ) / 2 ) + 1 ) / 6 + 1/6, ( math.sin( CurTime( ) / 2 ) + 1 ) / 6 + 1/6, 1 )
		materials2[id]:SetVector( "$color", matrix )
	end
	
	surface.SetMaterial( materials2[id] )
	surface.SetDrawColor( 255, 255, 255, 255 )
	if dir == GRADIENT_VERTICAL then
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, w, 1 )
	else
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, h )
	end
end