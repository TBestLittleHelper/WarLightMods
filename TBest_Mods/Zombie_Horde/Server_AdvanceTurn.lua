--TODO Hardcode Zombie surrender in a better way, 
--TODO Better way of picking Zombie? Then inpuPlayerID. Random Zombie, AI Zombie. Determine ZombieID on server created and store as Mod.Settings.ZombieID

function Server_AdvanceTurn_End(game,addNewOrder) --Give Zoombie armies at the end of a turn
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
	if (playersAlive() > 2) then
		order66={};
		CurrentIndex=1;
		for _,territory in pairs(standing.Territories) do 
			if (territory.OwnerPlayerID == Mod.Settings.ZombieID) then
				terrMod = WL.TerritoryModification.Create(territory.ID);
				terrMod.SetOwnerOpt=WL.PlayerID.Neutral;
				order66[CurrentIndex]=terrMod;
				CurrentIndex=CurrentIndex+1;
--the order66 is a modefication from https://github.com/dabo123148/WarlightMod/blob/master/Pestilence/Server_AdvanceTurn.lua
			end
		end
		addOrder(WL.GameOrderEvent.Create(Mod.Settings.ZombieID,"Cure Found and zombies are now harmless",{},{order66}));
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
	end
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
	return n;
end
