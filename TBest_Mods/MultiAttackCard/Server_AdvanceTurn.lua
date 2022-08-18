require("Utilities")

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "MultiAttackCard_")) then --look for the order
		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here

		local payloadSplit = split(string.sub(order.Payload, 17), ",")
		local fromTerritoryID = tonumber(payloadSplit[1])
		local toTerritoryID = tonumber(payloadSplit[2])

		--Make sure the territories boarders each other
		if (game.Map.Territories[fromTerritoryID].ConnectedTo[toTerritoryID] == nil) then
			skipThisOrder(WL.ModOrderControl.Skip)
			return
		end
		--Make sure that the player has enough charges
		local playerGameData = Mod.PlayerGameData
		if (playerGameData[order.PlayerID].charges < 1) then
			skipThisOrder(WL.ModOrderControl.Skip)
			return
		end
		--Remove one charge
		playerGameData[order.PlayerID].charges = playerGameData[order.PlayerID].charges - 1
		Mod.PlayerGameData = playerGameData

		local armies = WL.Armies.Create(game.ServerGame.LatestTurnStanding.Territories[fromTerritoryID].NumArmies.NumArmies)
		local removeFromSource = WL.TerritoryModification.Create(fromTerritoryID)

		removeFromSource.AddArmies = armies.NumArmies
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Add armies for multiattack", {}, {removeFromSource}, nil))
		addNewOrder(
			WL.GameOrderAttackTransfer.Create(order.PlayerID, fromTerritoryID, toTerritoryID, 3, false, armies, false)
		)
		removeFromSource.AddArmies = -armies.NumArmies
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Remove armies for multiattack", {}, {removeFromSource}, nil))

	--	skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	--Give 1 charge to all players
	local playerGameData = Mod.PlayerGameData
	for playerID, _ in pairs(Mod.PlayerGameData) do
		playerGameData[playerID].charges = playerGameData[playerID].charges + 1
	end
	Mod.PlayerGameData = playerGameData
end
