--TODO Hardcode Zombie surrender in a better way, 
--TODO Better way of picking Zombie? Then inpuPlayerID. Random Zombie, AI Zombie. Determine ZombieID on server created and store as Mod.Settings.ZombieID

function Server_AdvanceTurn_End(game,addNewOrder) --Give Zoombie armies at the end of a turn
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
	if (playersAlive() > 2) then
		addOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,'Last surviver wins',nil));
		for _,territory in pairs(standing.Territories) do 	
			if (territory.OwnerPlayerID == Mod.Settings.ZombieID) then
				territory.SetOwnerOpt=WL.PlayerID.Neutral;
			end
		end
	else	
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
end

function playersAlive()
	local playersSet = {}
	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			playersSet[territory.OwnerPlayerID] = true
		end
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
	return n;
end
