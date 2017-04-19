
function Server_AdvanceTurn_Start(game,addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	for _,territory in pairs(standing.Territories) do
		if (territory.OwnerPlayerID == 1) then -- AI 1, in game
			local newExtraDeploy = Mod.Settings.ExtraArmies;
			print (territory.NumArmies.NumArmies .." " .. territory.ID);

			--TODO determine a better cap
			if (newExtraDeploy < 0) then newExtraDeploy = 0 end;	
			if (newExtraDeploy > 1000) then newExtraDeploy = 1000 end;	
	
			
			addNewOrder(WL.GameOrderDeploy.Create(1, newExtraDeploy, territory.ID,nil,GameOrderDeploy));
		end
	end
end
