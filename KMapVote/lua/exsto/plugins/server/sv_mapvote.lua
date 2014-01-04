local PLUGIN = exsto.CreatePlugin()

PLUGIN:SetInfo({
	Name = "Mapvote",
	ID = "mapvote",
	Desc = "A plugin that integrates the mapvote script into exsto!",
	Owner = "Kamshak",
} )

function PLUGIN:Rtv( self )
	MAPVOTE:PlayerRTV( self )
end

PLUGIN:AddCommand( "RockTheVote", {
	Call = PLUGIN.Rtv,
	Desc = "Vote for RockTheVote, starts a prevote if a mapchange vote should be started.",
	Console = { "rtv" },
	Chat = { "!rtv", "!rockthevote", "rtv" },
	Args = {},
	Category = "Mapvote",
})

PLUGIN:Register()