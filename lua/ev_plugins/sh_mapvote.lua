local PLUGIN = {}
PLUGIN.Title = "Rock the Vote"
PLUGIN.Description = "Call for a vote to change the map"
PLUGIN.Author = "Kamshak"
PLUGIN.ChatCommand = "rtv"
PLUGIN.Usage = ""
PLUGIN.Privileges = { "Rock The Vote" }

function PLUGIN:Call( ply, args )
        if ( ply:EV_HasPrivilege( "Rock The Vote" ) ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has voted to Rock The Vote.", evolve.colors.red )
			MAPVOTE:PlayerRTV( ply )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
        end
end

if evolve then
	if MAPVOTE.RockTheVote then
		evolve:RegisterPlugin( PLUGIN )
	end
end
