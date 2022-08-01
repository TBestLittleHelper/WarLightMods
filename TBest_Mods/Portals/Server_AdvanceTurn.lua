function Server_AdvanceTurn_End(game, addNewOrder)
	Game = game
	TerritoryModifications = {}

	--Swap the standing (owner, armies) of the connected portals
	for i = 1, #Mod.PrivateGameData.portals do
		if (i % 2 == 1) then -- 1 , 3 , 5 swap with 2 , 4 , 6
			TerritoryModifications[i] = terrModHelper(Mod.PrivateGameData.portals[i], Mod.PrivateGameData.portals[i + 1])
		else
			TerritoryModifications[i] = terrModHelper(Mod.PrivateGameData.portals[i], Mod.PrivateGameData.portals[i - 1])
		end
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Portal Away", nil, TerritoryModifications, nil))
end

function terrModHelper(targertTerritory, sourceTerritory)
	local terrMod = WL.TerritoryModification.Create(targertTerritory)

	terrMod.SetArmiesTo = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].NumArmies.NumArmies
	terrMod.SetOwnerOpt = Game.ServerGame.LatestTurnStanding.Territories[sourceTerritory].OwnerPlayerID

	return terrMod
end
