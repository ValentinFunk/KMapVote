LibK.InitializeAddon{
    addonName = "KMapVote",                  --Name of the addon
    author = "Kamshak",                         --Name of the author
    luaroot = "mapvote",                     --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false
}
LibK.addReloadFile( "autorun/mapvote_init.lua" )

print( "Loaded KMapVote", "{{ user_id }}" )