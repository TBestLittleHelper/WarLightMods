function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	newExtraDeploy = Mod.Settings.ExtraArmies;
	CurrentIndex=1;
	Order66={};
	ZombieID = Mod.Settings.ZombieID;
	--ignore unimportent orders TODO
	if (Mod.Settings.RandomZombie ==true) then
		ZombieID = FindZombieID(Mod.Settings.RandomSeed, game);
	end
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
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
		standing = game.ServerGame.LatestTurnStanding;
	if (playersAlive() > 2) then --update to count teams, not players	
		for _,territory in pairs(standing.Territories) do 	
			if (territory.OwnerPlayerID == ZombieID) then
				if (newExtraDeploy + territory.NumArmies.NumArmies < newExtraDeploy *10) then
					if (newExtraDeploy < 0) then newExtraDeploy = 0 end;	
					if (newExtraDeploy > 1000) then newExtraDeploy = 1000 end;	
--make this only add one event, that is "All Zombie territories deployex X armies. ?TODO
					addNewOrder(WL.GameOrderDeploy.Create(ZombieID, newExtraDeploy, territory.ID,nil,GameOrderDeploy));
				end
			end
		end
	end
end

function FindZombieID(seed, game)
	local playersSet = {}
	for _,territory in pairs(game.ServerGame.TurnZeroStanding.Territories)do	
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
	winnerKey =0;
	for i=1,game.Game.ID do
		winnerKey = winnerKey +1;
		if (winnerKey > n ) then
			winnerKey =0;
		end
	end
	print( "Seeding with "..game.Game.ID  )
	print ('playerSet 'playersSet[winnerKey])
	print ('playersTable 'playersTable[winnerKey])
	print ('winnerKey ' .. winnerKey)
	return playersTable[winnerKey];
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
