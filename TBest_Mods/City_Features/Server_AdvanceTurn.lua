--give % def bonus to cities

function Server_AdvanceTurn_Start (game, addNewOrder)
	
	--Every 10 turn, Cities grow by 1
	if (game.Game.NumberOfTurns %2 == 0 and game.Game.NumberOfTurns > 3) then
		print(game.Game.NumberOfTurns)
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
	--Cities can be removed by bomb card
	--For now, bomb cards set cities to 1.
	if(order.proxyType == 'GameOrderPlayCardBomb') then
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



 function PrintProxyInfo(obj)
   print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
 end
