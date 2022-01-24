function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	-- If we are undoing, skip all orders

	if (Mod.PublicGameData.UndoLastTurn) then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if (Mod.PublicGameData.UndoLastTurn) then
		PublicgameData = Mod.PublicGameData
		PublicgameData.UndoLastTurn = false
		Mod.PublicGameData = PublicgameData

		turn = game.ServerGame.game.TurnNumber
		print(turn)
		lastTurnTerritoryStanding = game.ServerGame.PreviousTurnStanding.Territories
		--TODO special units
		--Structures

		--https://www.warzone.com/wiki/Mod_API_Reference:TerritoryModification
		TerritoryModifications = {}
		for _, territory in pairs(lastTurnTerritoryStanding) do
			local terrMod = WL.TerritoryModification.Create(territory.ID)
			terrMod.SetArmiesTo = territory.NumArmies.NumArmies
			SetOwnerOpt = territory.OwnerPlayerID
		end

		--Set territory standing
		--Set card standing
		--Set active card

		--Set resources (gold) https://www.warzone.com/wiki/Mod_API_Reference:GameStanding

		--https://www.warzone.com/wiki/Mod_API_Reference:GameOrderEvent //TODO addd gold

		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Turn was undone", nil, TerritoryModifications, nil))
	end
end
