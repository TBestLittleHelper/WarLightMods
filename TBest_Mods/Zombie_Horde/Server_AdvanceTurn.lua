function Server_AdvanceTurn_End(game,addNewOrder) --Give Zoombie armies at the end of a turn
	standing = game.ServerGame.LatestTurnStanding;
	newExtraDeploy = Mod.Settings.ExtraArmies;
	CurrentIndex=1;
	Order66={};
	ZombieID = Mod.Settings.ZombieID;
	if (Mod.Settings.RandomZombie ==true) then
		ZombieID = FindZombieID(Mod.Settings.RandomSeed);
	end
	if (playersAlive() == 2) then --update to count teams, not players
		for _,territory in pairs(standing.Territories) do --also make it check each order. Not at the end of a turn
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

function FindZombieID(seed)
	print( "Seeding with "..seed )
	print( game.Settings.Created)
	math.randomseed(game.Settings.Created)
	print (math.random())
	print (math.random())
	print (math.random())
	local playersSet = {}
	for _,territory in pairs(game.ServerGame.TurnZeroStanding.Territories)do
		print ('here')
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
	
	ID = playersTable[math.random];
	return ID;
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
