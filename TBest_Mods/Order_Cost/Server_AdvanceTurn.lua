-- Count the number of orders, then subtract the non free amount from a player's income

local playersTable = {}

function Server_AdvanceTurn_Start(game, addNewOrder)
	playersTable = {}
	for playerID, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		playersTable[playerID] = Mod.Settings.FreeOrders
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	--We skip game order event's, since we create that order ourselves. This does argubly harm mod compatabilety.
	if (order.proxyType == "GameOrderEvent")then return end

	if (playersTable[order.PlayerID] ~= nil)then
		playersTable[order.PlayerID] = playersTable[order.PlayerID] -1
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	for playerID, cost in pairs(playersTable) do
		if (cost > 0) then
			cost = 0
		end

		local incomeMod = WL.IncomeMod.Create(playerID, cost, "Cost of orders")
		addNewOrder(WL.GameOrderEvent.Create(playerID, cost .. " cost of orders", nil, {}, nil, {incomeMod}))
	end
end
