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
		name = "gm_construct",
		label = "Construct",
		minplayers = 5,
		maxplayers = 40
	}

	MAPVOTE:AddMap{
		name = "ttt_67thway_v3",
		label = "67th Way",
		minplayers = 5,
		maxplayers = 40
	}

	MAPVOTE:AddMap{
		name = "ttt_aftermath_a1",
		label = "Aftermath",
		minplayers = 10,
		maxplayers = 5,
	}
	
	MAPVOTE:AddMap{
		name = "ttt_airship_b1",
		label = "Airship"
	}
	
	MAPVOTE:AddMap{
		name = "gm_construct",
		label = "Construct"
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
		name = "cs_office",
		label = "Office", 
		gamemodes = {
			"murder", 
			"terrortown",
			"prop_hunt"
		}
	}
	
	--Melonbomber
	MAPVOTE:AddMap{
		name = "mb_melonbomber",
		label = "Melonbomber"
	}
	
	--Hallowgrounds
	MAPVOTE:AddMap{
		name = "hg_hallowgrounds",
		label = "Hallowgrounds"
	}
	
	--Metal Melon
	MAPVOTE:AddMap{
		name = "gm_mm_screamlane",
		label = "Screamlane",
		gamemodes = {
			"metalmelon"
		}
	}
	
	--Honeypot
	MAPVOTE:AddMap{
		name = "hp_melonmart_final",
		label = "Melonmart",
		gamemodes = {
			"honeypot"
		}
	}
	
	--Melonfight
	MAPVOTE:AddMap{
		name = "mf_gcc",
		label = "Melonfight Hills"
	}
	
	--Pedobear Escape 2
	MAPVOTE:AddMap{
		name = "pb_arena_2014",
		label = "Arena 2014"
	}
	
	MAPVOTE:AddMap{
		name = "pb_cubic",
		label = "Cubic"
	}
	
	MAPVOTE:AddMap{
		name = "pb_levels",
		label = "Levels"
	}
	
	--Melon Tank
	MAPVOTE:AddMap{
		name = "mt_lego_arena_b2p",
		label = "Lego Arena"
	}
	
	--Labyrinth
	MAPVOTE:AddMap{
		name = "lab_theseus_v2",
		label = "Theseus v2",
		gamemodes = {
			"labyrinth"
		}
	}
	
/*
	End of map list
*/