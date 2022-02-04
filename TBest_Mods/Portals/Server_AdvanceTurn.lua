function Server_AdvanceTurn_End(game, addNewOrder)
	TerritoryModifications = {}
	Game = game

	--Swap the standing (owner, armies) of the two portals
	TerritoryModifications[1] = terrModHelper(Mod.PublicGameData.portalB, Mod.PublicGameData.portalA)
	TerritoryModifications[2] = terrModHelper(Mod.PublicGameData.portalA, Mod.PublicGameData.portalB)

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Portal Away", nil, TerritoryModifications, nil))
end

function terrModHelper(targertTerritory, sourceTerritory)
	local terrMod = WL.TerritoryModification.Create(targertTerritory)

	terrMod.SetArmiesTo = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].NumArmies.NumArmies
	terrMod.SetOwnerOpt = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].OwnerPlayerID

	return terrMod
end
