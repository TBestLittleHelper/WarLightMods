function Server_AdvanceTurn_Start (game, addNewOrder)	
	--The turns cities can grow.
	if ((game.Game.NumberOfTurns+1) %5 == 0) then
		standing = game.ServerGame.LatestTurnStanding;
		CurrentIndex=1;
		NewOrders={};
		
		--As of now WarZone only has one type of structure. If this changes in the future, this code may break.
		local structure = {}
		Cities = WL.StructureType.City
		for _, territory in pairs(standing.Territories) do
			--Can be 0, if a territory has been bombed. We don't want that city to grow.
			if not(territory.Structures == nil or territory.Structures[WL.StructureType.City] == 0) then
				terrMod = WL.TerritoryModification.Create(territory.ID);		
				structure[Cities] = territory.Structures[WL.StructureType.City] +1;
				--A cap on how big cities can get
				if (structure[Cities] < 8 ) then
					terrMod.SetStructuresOpt   = structure
					NewOrders[CurrentIndex]=terrMod;
					CurrentIndex=CurrentIndex+1;
				end
			end
		end					
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"Cities have grown",nil,NewOrders));
	end
end

--As of now WarZone only has one type of structure. If this changes in the future, this code may break.
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)	
	--Give a 10% def. bonus per city on defending territory 
	if (order.proxyType == 'GameOrderAttackTransfer')  then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil) then	
				if (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] > 0) then
					DefBonus = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * 0.50;
					attackersKilled = result.AttackingArmiesKilled.NumArmies +  result.AttackingArmiesKilled.NumArmies * DefBonus
					
					--Minimum kill 1 attacking army
					if(attackersKilled == 0) then
						attackersKilled = 1					
						--Max armies lost is equal to actualArmies
						elseif (result.ActualArmies.NumArmies - attackersKilled < 0) then
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
		end
	end	
	--For now, bomb cards reduces cities to 1.
	if(order.proxyType == 'GameOrderPlayCardBomb') then
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			local structure = {}
			NewOrders={};
			Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] -2;
			msg = "City was bombed";
			if (structure[Cities] < 1) then
				structure[Cities] = 0;
				msg = "The City is destroyed!"
			end
			terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
		end
	end	
	
	--If we blockade or emergency blockade on a city we own. We build on that city
	--Maybe, we want this to be a way to make new cities in the future
	if(order.proxyType == 'GameOrderPlayCardBlockade' or order.proxyType == 'GameOrderPlayCardAbandon') then
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			local structure = {}
			NewOrders={};
			Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] +1;
			msg = "The City have been improved!";
			terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	end
end
	