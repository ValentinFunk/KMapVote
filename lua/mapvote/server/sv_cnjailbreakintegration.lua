if MAPVOTE.CNJailbreakIntegrationEnabled then
	hook.Add( "Initialize", "HookCNVote", function( )
		if cn_vote then
			local oldInit = cn_vote.Init
			function cn_vote:Init( question, time, options, Callback)
				if question == "Map Vote" then
					JB_FAIL_SAFE = false
					MAPVOTE:BeginVote( )
				else
					return oldInit( self, question, time, options, Callback )
				end
			end
		end
	end )
end