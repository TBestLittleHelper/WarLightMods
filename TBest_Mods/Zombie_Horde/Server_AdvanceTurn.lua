--TODO Hardcode Zombie surrender when one non-zombie player ramians. Wait for FizzerUpdate
--TODO Better way of picking Zombie?

function Server_AdvanceTurn_Start(game,addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
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

Server_AdvanceTurn_Order(game,GameOrder,GameOrderResult)
	standing = game.ServerGame.LatestTurnStanding;
	local playersAlive;
	
--need Update fromFIzzer on GameOrderResult: The result of the order being processed. This is writable, so mods can change the result. Currently, only GameOrderAttackTransferResult has writable fields.
end
