function Server_AdvanceTurn_End(game,addNewOrder) --Give Zoombie armies at the end of a turn
	standing = game.ServerGame.LatestTurnStanding;
	local newExtraDeploy = Mod.Settings.ExtraArmies;
	CurrentIndex=1;
	Order66={};
	local ZombieID = ZombieID(Mod.Settings.RandomSeed);
	
	if (playersAlive() == 2) then --update to count teams, not players
		for _,territory in pairs(standing.Territories) do 
			if (territory.OwnerPlayerID == ZombieID) then
				terrMod = WL.TerritoryModification.Create(territory.ID);
				terrMod.SetOwnerOpt=WL.PlayerID.Neutral;
				Order66[CurrentIndex]=terrMod;
				CurrentIndex=CurrentIndex+1;
--the order66 is a modefication from https://github.com/dabo123148/WarlightMod/blob/master/Pestilence/Server_AdvanceTurn.lua
			end
		end
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"Cure Found and zombies are now harmless",nil,Order66));
	else
		for _,territory in pairs(standing.Territories) do 	
			if (territory.OwnerPlayerID == ZombieID) then
				if (newExtraDeploy + territory.NumArmies.NumArmies < newExtraDeploy *10) then
					if (newExtraDeploy < 0) then newExtraDeploy = 0 end;	
					if (newExtraDeploy > 1000) then newExtraDeploy = 1000 end;	
--make this only add one event, that is "All Zombie territories deployex X armies. ?
					addNewOrder(WL.GameOrderDeploy.Create(ZombieID, newExtraDeploy, territory.ID,nil,GameOrderDeploy));
				end
			end
		end
	end
end

function ZombieID(seed)
	local playersSet = {}
	for _, territory in pairs(game.TurnZeroStanding ) do
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
	local x = #playersTable;
	local count;
	local  i =0;
	local y = 0;
	while (seed <i )do
		i = i + 1;
		while (y < x) do
			y = y +1;
		end
	end
	return playersTable[y];
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
