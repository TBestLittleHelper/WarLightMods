function Server_AdvanceTurn_Start (game, addNewOrder)	
	--The turns cities can grow.
	if ((game.Game.NumberOfTurns+1) %5 == 0) then
		standing = game.ServerGame.LatestTurnStanding;
		CurrentIndex=1;
		NewOrders={};
		
		--As of now WarZone only has one type of structure.
		local structure = {}
		Cities = WL.StructureType.City
		for _, territory in pairs(standing.Territories) do
			--Can be 0, if a territory has been bombed. We don't want that city to grow.
			if not(territory.Structures == nil or territory.Structures[WL.StructureType.City] == 0) then
				terrMod = WL.TerritoryModification.Create(territory.ID);		
				structure[Cities] = territory.Structures[WL.StructureType.City] +1;
				--A hardcoded cap on how big cities can grow
				if (structure[Cities] < 11 ) then
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
	--Always Free to deploy on cities in commerce games
	if (order.proxyType == 'GameOrderDeploy' and game.Settings.CommerceGame == true and Mod.Settings.CommerceFreeCityDeploy == true) then
		if (game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures ~= nil) then
			--if city is already destroyed, return
			if (game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures[WL.StructureType.City] == 0) then
				return;
			end			
			NewOrders={};	
			terrMod = WL.TerritoryModification.Create(order.DeployOn);	
			terrMod.SetArmiesTo  = game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].NumArmies.NumArmies + order.NumArmies;
			NewOrders[1]=terrMod;
			
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,"Deployed " .. terrMod.SetArmiesTo .. " in a city for free", {}, NewOrders));
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);			
			return;
		end
	end	
	
	--Give a X% def. bonus per city on defending territory 
	if (order.proxyType == 'GameOrderAttackTransfer' and Mod.Settings.CityWallsActive == true)  then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil) then	
				if (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] > 0) then
					DefBonus = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * Mod.Settings.DefPower;
					attackersKilled = result.AttackingArmiesKilled.NumArmies +  result.AttackingArmiesKilled.NumArmies * DefBonus
					
					--Minimum kill 1 attacking army
					if(attackersKilled == 0) then
						attackersKilled = 1					
						--Max armies lost is equal to actualArmies
						elseif (result.ActualArmies.NumArmies - attackersKilled < 0) then
						attackersKilled = result.ActualArmies.NumArmies;
						--Note : At the moment we don't dmg special units
						--That would be a very rare edge case, we might want to handle in the future
						else
						--round up, always
						attackersKilled = math.ceil(attackersKilled);
					end
					
					--Write to GameOrderResult	 (result)
					local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled) 
					result.AttackingArmiesKilled = NewAttackingArmiesKilled
					msg = "The city has " .. tostring(DefBonus*100) .. "% fortification bonus";
					addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID}));
					return;
					end
				end
			end
		end	
		--Bomb cards reduces cities by the given X strength.
		if(order.proxyType == 'GameOrderPlayCardBomb' and Mod.Settings.BombcardActive == true) then
			if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
				--if city is already destroyed, return
				if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] == 0) then
					return;
				end
				
				local structure = {}
				NewOrders={};
				Cities = WL.StructureType.City
				structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] -Mod.Settings.BombcardPower;
				msg = "City was bombed";
				if (structure[Cities] < 1) then
					--We can't set to nil, so we set to zero
					structure[Cities] = 0;
				msg = "The City is destroyed! It is now a ruin and won't grow before it's been rebuilt."
			end
			terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			
			--Add the new order event. Discard the card played. Skip the normal card effect.		
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID));			
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			return;
		end
	end	
	
	--If we blockade or emergency blockade on a city we own. We build on that city
	if(order.proxyType == 'GameOrderPlayCardBlockade' or order.proxyType == 'GameOrderPlayCardAbandon' and Mod.Settings.BlockadeBuildCityActive == true) then
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			--Check that the player controls the territory
			if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
				return;
			end;
			
			local structure = {}
			NewOrders={};
			Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] +Mod.Settings.BlockadePower;
			msg = "The City's defenses have been increased!";
			terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			
			--Add the new order event. Discard the card played. Skip the normal card effect.
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID));			
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);		
			return;
		end
	end
end