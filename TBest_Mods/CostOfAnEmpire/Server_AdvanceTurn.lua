function Server_AdvanceTurn_End(game, addNewOrder)
	local players = {}
	local costOfACityState = -0.5
	local costOfAKingdom = -0.8
	local costOfAnEmpire = -1

	--Loop all territories and count how many a player owns
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if (terr.IsNeutral == false) then
			if (players[terr.OwnerPlayerID] == nil) then
				players[terr.OwnerPlayerID] = 0
			end

			players[terr.OwnerPlayerID] = players[terr.OwnerPlayerID] + 1
		end
	end

	--Subtract income for each territory a player owns
	for playerID, territoriesOwned in pairs(players) do
		--First 75 territories are a citystate cost [ 0 - 75]
		--Next 75 territories are a kingdom cost [ 75 - 150]
		--Everything over 75 is an Empire cost [ 150+ ]

		local cost = math.floor(costOfACityState * territoriesOwned)
		local msg = "Cost of a city-state for " .. territoriesOwned .. " territories"

		if (territoriesOwned > 75) then
			msg = "Cost of a kingdom for " .. territoriesOwned .. " territories"
			cost = cost + math.floor(costOfAKingdom * (territoriesOwned - 75))
		end

		if (territoriesOwned > 150) then
			msg = "Cost of an empire for " .. territoriesOwned .. " territories"
			cost = cost + math.floor(costOfAnEmpire * (territoriesOwned - 150))
		end

		local incomeMod = WL.IncomeMod.Create(playerID, cost, msg)
		addNewOrder(WL.GameOrderEvent.Create(playerID, msg, nil, {}, nil, {incomeMod}))
	end
end
