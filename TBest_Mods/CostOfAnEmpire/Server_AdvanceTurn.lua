function Server_AdvanceTurn_End(game, addNewOrder)
	local players = {};
	--Loop all territories
  for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories)do
	if (terr.IsNeutral == false) then
		if (players[terr.OwnerPlayerID] == nil) then
			players[terr.OwnerPlayerID] = 0;
		end

		players[terr.OwnerPlayerID] = players[terr.OwnerPlayerID] + 1;
	end

  end

  --Subtract 0.5 income for each territory a player owns
  for playerID,territoriesOwned in pairs(players)do
	local incomeMod = WL.IncomeMod.Create(playerID, math.floor(-0.5 * territoriesOwned ), ' Cost of an empire');
	addNewOrder(WL.GameOrderEvent.Create(playerID, "Cost of an empire", {}, {}, nil, {incomeMod}));
  end
end
