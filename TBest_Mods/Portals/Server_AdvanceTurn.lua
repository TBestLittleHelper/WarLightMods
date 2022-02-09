function Server_AdvanceTurn_Start(game, addNewOrder)
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
end

function Server_AdvanceTurn_End(game, addNewOrder)
	TerritoryModifications = {}
	Game = game

	--Swap the standing (owner, armies) of the two portals
	print(#Mod.PublicGameData.portals)
	for i = 1, #Mod.PublicGameData.portals do
		TerritoryModifications[i] = terrModHelper(Mod.PublicGameData.portals[i + 1], Mod.PublicGameData.portals[i])
		i = i + 1
	end
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Portal Away", nil, TerritoryModifications, nil))
end

function terrModHelper(targertTerritory, sourceTerritory)
	local terrMod = WL.TerritoryModification.Create(targertTerritory)

	terrMod.SetArmiesTo = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].NumArmies.NumArmies
	terrMod.SetOwnerOpt = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].OwnerPlayerID

	return terrMod
end
