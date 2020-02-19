function Server_AdvanceTurn_Start (game, addNewOrder)	
	--Every 5 turn, Cities grow by 1
	if (game.Game.NumberOfTurns %5 == 0 and game.Game.NumberOfTurns > 3) then
		standing = game.ServerGame.LatestTurnStanding;
		CurrentIndex=1;
		NewOrders={};

		local structure = {}
		Cities = WL.StructureType.City
		for _, territory in pairs(standing.Territories) do
			if (not territory.IsNeutral) then
				if not(territory.Structures == nil) then
					terrMod = WL.TerritoryModification.Create(territory.ID);		
					structure[Cities] = territory.Structures[WL.StructureType.City] +1;
					terrMod.SetStructuresOpt   = structure
					NewOrders[CurrentIndex]=terrMod;
					CurrentIndex=CurrentIndex+1;
				end
			end
		end					
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"Cities have grown",nil,NewOrders));
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)	
	--Give a 10% def. bonus per city on defending territory 
	if (order.proxyType == 'GameOrderAttackTransfer')  then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil) then	
				DefBonus = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * 0.10;
				attackersKilled = result.AttackingArmiesKilled.NumArmies +  result.AttackingArmiesKilled.DefensePower * DefBonus
				--round up, always
				math.ceil(attackersKilled);
				--Max armies lost is equal to actualArmies
				if (attackersKilled - result.ActualArmies.NumArmies < 0) then
					attackersKilled = result.ActualArmies.NumArmies;
					--Note : At the moment we don't dmg special units
					--That would be a rare edge case
				end
	
				--Write to GameOrderResult	
				local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled) 
				result.AttackingArmiesKilled = NewAttackingArmiesKilled
				msg = "The city has " .. tostring(DefBonus*100) .. "% defencive bonus";
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg));
			end
		end
	
	--For now, bomb cards set cities to 1.
	elseif(order.proxyType == 'GameOrderPlayCardBomb') then
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			local structure = {}
			NewOrders={};
			Cities = WL.StructureType.City
			structure[Cities] = 1;
			terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"City was bombed",nil,NewOrders));
		end
	end
end
