function Server_StartDistribution(game, standing)
	local allPickableTerr = {}
	local pickable = 0
	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID == -2 then
			pickable = pickable + 1
			table.insert(allPickableTerr, terr)
		end
	end
	local wantedPickable = math.floor(pickable / 2)
	if (wantedPickable < #game.Game.Players) then
		wantedPickable = #game.Game.Players
	end
	print("Pickable ", pickable)
	print("Wanted pickable ", wantedPickable)

	for i = 1, wantedPickable do
		r = math.random(#allPickableTerr)
		terr = table.remove(allPickableTerr, r)
		terr.OwnerPlayerID = 0
	end
end
