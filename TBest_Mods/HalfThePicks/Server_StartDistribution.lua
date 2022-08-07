function Server_StartDistribution(game, standing)
	local allPickableTerr = {}
	local minPickable = tableSize(game.Game.Players) * game.Settings.LimitDistributionTerritories
	local pickable = 0
	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID == -2 then
			pickable = pickable + 1
			table.insert(allPickableTerr, terr)
		end
	end
	local wantedPickable = math.ceil((pickable * Mod.Settings.PickablePercent) * 0.01)
	if (wantedPickable < minPickable) then
		wantedPickable = minPickable
	end
	local changePicks = pickable - wantedPickable
	for i = 1, changePicks do
		r = math.random(#allPickableTerr)
		terr = table.remove(allPickableTerr, r)
		terr.OwnerPlayerID = 0
	end
end

function tableSize(table)
	local size = 0
	for _ in pairs(table) do
		size = size + 1
	end
	return size
end
