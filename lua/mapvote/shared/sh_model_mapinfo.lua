--Used for playcounts
KMapVote.MapInfo = class( "KMapInfo" )

KMapVote.MapInfo.static.DB = "KMapVote"
KMapVote.MapInfo.static.model = {
	tableName = "kmapvote_mapinfo",
	fields = {
		mapname = "string",
		createdAt = "createdTime",
	}
}
KMapVote.MapInfo:include( DatabaseModel )