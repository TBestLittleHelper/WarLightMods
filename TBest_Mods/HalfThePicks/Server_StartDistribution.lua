function Server_StartDistribution(game, standing)
	local allPickableTerr = {}
	local pickable = 0
	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID == -2 then
			pickable = pickable + 1
			table.insert(allPickableTerr, terr)
		end
	end
	local wantedPickable = math.floor(pickable * (Mod.Settings.PickablePercent * 0.01))
	local minTerritories = game.Settings.LimitDistributionTerritories * #game.Game.PlayingPlayers
	print(Mod.Settings.PickablePercent * 0.01)
	print(minTerritories)
	if (wantedPickable < minTerritories) then
		wantedPickable = minTerritories
	end
	print("Pickable ", pickable)
	print("Wanted pickable ", wantedPickable)

	for i = 1, wantedPickable do
		r = math.random(#allPickableTerr)
		terr = table.remove(allPickableTerr, r)
		terr.OwnerPlayerID = 0
	end
end
