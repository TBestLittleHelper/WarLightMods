--TODO Hardcode Zombie surrender when one non-zombie player ramians
--TODO Remove hardcode Zombie on AI 1

function Server_AdvanceTurn_Start(game,addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
	for _,territory in pairs(standing.Territories) do 		
		if (territory.OwnerPlayerID == 1) then -- AI 1, in game
			if (newExtraDeploy + territory.NumArmies.NumArmies < newExtraDeploy *10) then
				if (newExtraDeploy < 0) then newExtraDeploy = 0 end;	
				if (newExtraDeploy > 1000) then newExtraDeploy = 1000 end;	

				addNewOrder(WL.GameOrderDeploy.Create(1, newExtraDeploy, territory.ID,nil,GameOrderDeploy));
			end
		end
	end
end
