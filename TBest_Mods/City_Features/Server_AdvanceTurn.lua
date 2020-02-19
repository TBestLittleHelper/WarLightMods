function Server_AdvanceTurn_Start (game, addNewOrder)	
	--The turns cities grow. For now, we hardcode some turns
	if (game.Game.NumberOfTurns == 5 or game.Game.NumberOfTurns == 10 or game.Game.NumberOfTurns == 15) then

--	if (game.Game.NumberOfTurns %5 == 0 and game.Game.NumberOfTurns > 3) then
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


--TODO have fog on new orders
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)	
	--Give a 10% def. bonus per city on defending territory 
	if (order.proxyType == 'GameOrderAttackTransfer')  then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil) then	
				DefBonus = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * 0.10;
				attackersKilled = result.AttackingArmiesKilled.NumArmies +  result.AttackingArmiesKilled.DefensePower * DefBonus
				
				--Minimum kill 1 attacking army
				if(attackersKilled == 0) then
					attackersKilled = 1
			
				--Max armies lost is equal to actualArmies
				elseif (attackersKilled - result.ActualArmies.NumArmies < 0) then
					attackersKilled = result.ActualArmies.NumArmies;
					--Note : At the moment we don't dmg special units
					--That would be a rare edge case
				else
					--round up, always
					attackersKilled = math.ceil(attackersKilled);
				end
				
				--Write to GameOrderResult	 (result)
				local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled) 
				result.AttackingArmiesKilled = NewAttackingArmiesKilled
				msg = "The city has " .. tostring(DefBonus*100) .. "% fortification bonus";
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{}));
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
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,"City was bombed",NewOrders));
		end
	end
end
