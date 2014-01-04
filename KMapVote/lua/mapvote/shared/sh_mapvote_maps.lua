if MAPSLOADED then
	--return
end
MAPSLOADED = true

/*
	Map and Gamemode setup
*/

/*
	Insert your maps below.
	Format: 
	Notes: You only neeed the name parameter, all others are optional!
	Mapvote:AddMap{
		name = "Name of the map here",
		
		maxplayers = Maximum number of players on the server for the map to show up in a vote,
		minplayers = Minimum number of players on the server for the map to show up in a vote,
		label = "Name to show instead of the mapname", 
		gamemodes = { 
			--If you use the gamemode vote you can use this to override the
			--Gamemodes that this map should show up for. Usually this is done
			--automatically by the mappattern defined for the gamemodes, use this only
			--to override the default.
			"Gamemode1",
			"Gamemode2",
		}
	}
	
	If you want the gamemodes to have icons:
		1) put the gamemode icon as KMapVote\materials\gmicons\<gamemodename>.png as 24x24px png

	For map icons please follow this guide: 
	 	Map images are now loaded from the web to avoid extra downloads on the server.
		This makes sure that only the map images needed for a vote are loaded and is very
		useful for servers that use many maps. The map images are hosted on the cloudflare 
		CDN(Content Distribution Network) to ensure high availability and excellent speed
		for players independantly of where they connect from.
		
		If you have any icons that are missing, send them as 256x256px png to funk.valentin@gmail.com
		For the slideshow feature the naming should be as follows:
			1. Image: mapname.png
			2. Image: mapname(1).png
			3. Image: mapname(2).png 
			and so on
			example: de_dust.png, de_dust(1).png...
*/

	MAPVOTE:AddMap{
		name = "ttt_67thway_v3",
		label = "67th Way",
	}

	MAPVOTE:AddMap{
		name = "ttt_aftermath_a1",
		label = "Aftermath"
	}
	
	MAPVOTE:AddMap{
		name = "ttt_airship_b1",
		label = "Airship"
	}
	
	MAPVOTE:AddMap{
		name = "ttt_alt_borders_b13",
		label = "Alt Borders"
	}
	
	MAPVOTE:AddMap{
		name = "ttt_anxiety",
		label = "Anxiety"
	}
			
	MAPVOTE:AddMap{
		name = "cs_italy",
		label = "Italy",
		gamemodes = {
			"terrortown",
			"prop_hunt",
		}
	}
			
	MAPVOTE:AddMap{
		name = "de_inferno",
		label = "Inferno",
		gamemodes = {
			"terrortown",
			"prop_hunt",
		}
	}
	
	MAPVOTE:AddMap{
		name = "de_tides",
		label = "Tides",
		gamemodes = {
			"terrortown",
			"prop_hunt",
		}
	}
	
	MAPVOTE:AddMap{
		name = "gm_construct",
		labal = "Construct",
		gamemodes = {
			"terrortown",
		}
	}
	
	MAPVOTE:AddMap{
		name = "ttt_bank_b3",
		labal = "Bank",
		gamemodes = {
			"terrortown",
		}
	}
	
	MAPVOTE:AddMap{
		name = "ttt_bb_teenroom_b2",
		labal = "Teenroom",
		gamemodes = {
			"terrortown",
		}
	}
	
	MAPVOTE:AddMap{
		name = "ttt_biocube",
		labal = "Biocube",
		gamemodes = {
			"terrortown",
		}
	}
				
/*
	End of map list
*/