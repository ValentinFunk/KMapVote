KMapVote.Rating = class( "KRating" )

KMapVote.Rating.static.DB = "KMapVote"
KMapVote.Rating.static.model = {
	tableName = "kmapvote_ratings",
	fields = {
		owner_id = "int",
		stars = "int",
		comment = "text", 
		mapname = "string"
	}
}
KMapVote.Rating:include( DatabaseModel )

function KMapVote.Rating.static.addRatingSummaryToMaps( maps )
	local mapNamesSafe = {}
	for k, v in pairs( maps ) do
		table.insert( mapNamesSafe, DATABASES.KMapVote.SQLStr( v.name ) )
	end
	
	local promise = DATABASES.KMapVote.DoQuery( Format( [[
			SELECT mapname, COUNT(*) as ratingCount, AVG(stars) as ratingAverage
			FROM %s 
			WHERE mapname IN ( %s )
			GROUP BY mapname
			]],
			KMapVote.Rating.model.tableName,
			table.concat( mapNamesSafe, "," )
		),
		true --blocking
	):Then( function( rows )
		rows = rows or {}
		for _, map in pairs ( maps ) do
			map.ratingCount = 0
			map.ratingAverage = 0
			for _, row in pairs( rows ) do
				if row.mapname == map.name then
					map.ratingCount = row.ratingCount
					map.ratingAverage = row.ratingAverage
				end
			end
		end
	end, function( err )
		ErrorNoHalt( err )
	end )
	
	return promise
end