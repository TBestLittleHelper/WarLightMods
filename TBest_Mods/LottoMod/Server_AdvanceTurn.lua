function Server_AdvanceTurn_Start(game, addNewOrder)
	local CurrentIndex = 1
	local winnerCapturesAll = {}
	local winner = randomPlayer(game)

	for _, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		terrMod = WL.TerritoryModification.Create(territory.ID)
		terrMod.SetOwnerOpt = winner
		winnerCapturesAll[CurrentIndex] = terrMod
		CurrentIndex = CurrentIndex + 1
	end
	addNewOrder(WL.GameOrderEvent.Create(winner, "Won the lottery!", nil, winnerCapturesAll))
end

function randomPlayer(game)
	local playersSet = game.ServerGame.game.PlayingPlayers

	local playersTable = {}
	local count = 0
	for key, _ in pairs(playersSet) do
		playersTable[count] = key
		count = count + 1
	end
	local winner = math.random(#playersTable)
	return playersTable[winner]
end
