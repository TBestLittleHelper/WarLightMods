require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'Paratroopers_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 14), ',');
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);

		--Skip if we control the territory. You can't attack your self
		if (order.PlayerID == game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end

		--Subtract armies * -2 from the attacker player income
		local incomeMod = WL.IncomeMod.Create(order.PlayerID, numArmies * -2, numArmies .. ' paratroopers attacked ' .. game.Map.Territories[targetTerritoryID].Name);

		--Check if the player can afford the attack. If we can't afford, skip
		PlayerCurrentIncome = game.Game.Players[order.PlayerID].Income(0, game.ServerGame.LatestTurnStanding, false, false).Total;

		if (PlayerCurrentIncome < numArmies * 2) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end;

		local armiesOnTerritory = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies;

		if (numArmies < 0) then numArmies = 0 end;
		if (numArmies > armiesOnTerritory) then numArmies = armiesOnTerritory end;

		--Remove armies from the target territory
		local removeFromSource = WL.TerritoryModification.Create(targetTerritoryID);
		removeFromSource.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies - numArmies;

		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {removeFromSource}, nil, {incomeMod}));

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.
	end
end
