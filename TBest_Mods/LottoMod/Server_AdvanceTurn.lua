function Server_AdvanceTurn_Start (game,addNewOrder)
	--some code is from https://github.com/kszyhoop/WarlightModPicksSwap/blob/master/SwapPicks.lua
	standing = game.ServerGame.LatestTurnStanding;
	local playersSet = {}
	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			playersSet[territory.OwnerPlayerID] = true
		end
	end

	local winner = lucky(playersSet);
	for _,territory in pairs(standing.Territories)do
		territory.OwnerPlayerID = winner;
	end
	addNewOrder(WL.GameOrderEvent.Create(winner,"Won the lottery!",nil));
	print ('here')
end

function lucky(playersSet)
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
  	local winner = math.random(0,n);
	return winner;
end
