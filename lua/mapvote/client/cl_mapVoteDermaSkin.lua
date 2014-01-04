hook.Add( "Initialize", "LoadKMapVoteSimpleSkin", function( )

local SKIN = {}

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )
SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

function SKIN:LayoutRTVPanel( )

end

function SKIN:PaintRTVPanel( )

end


derma.DefineSkin( "KMapVoteSimple", "Default Derma with KMapVote extensions", SKIN )

end ) --hook.Add( "Initialize" )