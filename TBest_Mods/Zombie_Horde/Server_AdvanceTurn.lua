--TODO Hardcode Zombie surrender when one non-zombie player ramians. Wait for FizzerUpdate
--TODO Better way of picking Zombie? Then inpuPlayerID. Random Zombie, AI Zombie. Determine ID on server created and store as Mod.Settings.ZombieID

function Server_AdvanceTurn_End(game,addNewOrder) --Give Zoombie armies at the end of a turn
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
	
	PrintProxyInfo(standing);
	PrintProxyInfo(result);
	
	for _,territory in pairs(standing.Territories) do 	
		if (territory.OwnerPlayerID == Mod.Settings.ZombieID) then
			if (newExtraDeploy + territory.NumArmies.NumArmies < newExtraDeploy *10) then
				if (newExtraDeploy < 0) then newExtraDeploy = 0 end;	
				if (newExtraDeploy > 1000) then newExtraDeploy = 1000 end;	

				addNewOrder(WL.GameOrderDeploy.Create(Mod.Settings.ZombieID, newExtraDeploy, territory.ID,nil,GameOrderDeploy));
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	local playersAlive;

	
--need Update from FIzzer on State GamePlayerState
end

function PrintProxyInfo(obj)
   print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end
