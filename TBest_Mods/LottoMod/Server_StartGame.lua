function Server_StartGame(game, standing)
	--some code is from https://github.com/kszyhoop/WarlightModPicksSwap/blob/master/SwapPicks.lua
	local playersSet = {}
	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			playersSet[territory.OwnerPlayerID] = true
		end
	end

	local winner = lucky(playersSet);
		print (winner);
	for _,territory in pairs(game.ServerGame.TurnZeroStanding.Territories)do
		territory.OwnerPlayerID = winner;
	
	end
	
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
