function Server_StartGame(game, standing)		
	--Set the mod boolean flag to be enabled
	local publicGameData = Mod.PublicGameData
	publicGameData.GameFinalized = false;
	publicGameData.Diplo = {};
	publicGameData.Chat = {};
	publicGameData = broadCastGroupSetup(game,publicGameData);
	Mod.PublicGameData = publicGameData;

	playerGameDataSetup(game);


	if (Mod.Settings.ModBetterCitiesEnabled)then StartGameBetterCities(game, standing) end;
	if (Mod.Settings.ModWinningConditionsEnabled)then StartGameWinCon(game, standing) end;
end

function playerGameDataSetup(game)
	local playerGameData = Mod.PlayerGameData;
	for _,pid in pairs(game.ServerGame.Game.Players)do
		if(pid.IsAI == false)then
			playerGameData[pid.ID] = {};
			playerGameData[pid.ID].Chat = {}; -- For the chat function
			playerGameData[pid.ID].Diplo = {}; -- For the diplo function
			--TODO more diplo stuff
			playerGameData[pid.ID].Diplo.PendingProposals = {}			
			playerGameData[pid.ID].WinCon = {}; --For WinCon mod
			playerGameData[pid.ID].WinCon.HoldTerritories = {};
		end
	end
	Mod.PlayerGameData = playerGameData;
end
function broadCastGroupSetup(game,publicGameData)
	publicGameData.Chat.BroadcastGroup = {};
	publicGameData.Chat.BroadcastGroup[1] = "When a game ends, all chat messages will be made public. Also, check out settings and tweek it to your liking."
	--publicGameData.Chat.BroadcastGroup[1].Sender = 0; --this might be someting we add in the future
	publicGameData.Chat.BroadcastGroup[2] = "Note that messages to the server is rate-limited to 5 calls every 30 seconds per client. Therefore, do not spam chat or group changes: it won't work!"
	publicGameData.Chat.BroadcastGroup.NumChat = 2
	return publicGameData;
end


function StartGameBetterCities( game, standing )
		--If we are not doing anything, return
		if (Mod.Settings.StartingCitiesActive == false and Mod.Settings.WastlandCities == false and Mod.Settings.CustomSenarioCapitals == false)then
			return;
		end
		
		--Make a city on all starting territories
		local structure = {}
		Cities = WL.StructureType.City
		structure[Cities] = Mod.Settings.NumberOfStartingCities;
		
		for _, territory in pairs(standing.Territories) do
			if (territory.IsNeutral == false and Mod.Settings.StartingCitiesActive == true) then
				--Players starts with a city
				territory.Structures  = structure
				
				elseif (territory.NumArmies.NumArmies == game.Settings.WastelandSize and Mod.Settings.WastlandCities == true
				and territory.IsNeutral == true) then
				--Wastelands starts with a city.
				structure[Cities] = 1;
				territory.Structures  = structure
				structure[Cities] = Mod.Settings.NumberOfStartingCities;	
				end
			
			--Capitals results in bigger city
			--Useful for Custom scenario, where players can start with a lot of territories
			if (territory.NumArmies.NumArmies == Mod.Settings.CustomSenarioCapitals and territory.IsNeutral == false) then
				structure[Cities] = Mod.Settings.CapitalExtraStartingCities;
				territory.Structures = structure;
				--Reset to 1, as we loop back to the next territory.
				structure[Cities] = Mod.Settings.NumberOfStartingCities;
			end
		end
end

function StartGameWinCon(game, standing) 
	local playerGameData = Mod.PlayerGameData;
	for _,pid in pairs(game.ServerGame.Game.Players)do
		if(pid.IsAI == false)then
			playerGameData[pid.ID].WinCon = {};
			playerGameData[pid.ID].WinCon.Capturedterritories = 0;
			playerGameData[pid.ID].WinCon.Lostterritories = 0;
			playerGameData[pid.ID].WinCon.Ownedterritories = 0;
			playerGameData[pid.ID].WinCon.Capturedbonuses = 0;
			playerGameData[pid.ID].WinCon.Lostbonuses = 0;
			playerGameData[pid.ID].WinCon.Ownedbonuses = 0;
			playerGameData[pid.ID].WinCon.Killedarmies = 0;
			playerGameData[pid.ID].WinCon.Lostarmies = 0;
			playerGameData[pid.ID].WinCon.Ownedarmies = 0;
			playerGameData[pid.ID].WinCon.Eleminateais = 0;
			playerGameData[pid.ID].WinCon.Eleminateplayers = 0;
			playerGameData[pid.ID].WinCon.Eleminateaisandplayers = 0;
		end
	end
	for _,terr in pairs(standing.Territories)do
		if(terr.OwnerPlayerID ~= WL.PlayerID.Neutral)then
			if(game.ServerGame.Game.PlayingPlayers[terr.OwnerPlayerID].IsAI == false)then
				playerGameData[terr.OwnerPlayerID].WinCon.Ownedterritories = playerGameData[terr.OwnerPlayerID].WinCon.Ownedterritories+1;
				playerGameData[terr.OwnerPlayerID].WinCon.Ownedarmies = playerGameData[terr.OwnerPlayerID].WinCon.Ownedarmies+terr.NumArmies.NumArmies;
			end
		end
	end
	for _,boni in pairs(game.Map.Bonuses)do
		local Match = true;
		for _,terrid in pairs(boni.Territories)do
			if(pid == nil)then
				pid = standing.Territories[terrid].OwnerPlayerID;
			end
			if(pid ~= standing.Territories[terrid].OwnerPlayerID)then
				Match = false;
			end
		end
		if(Match == true)then
			if(pid ~= WL.PlayerID.Neutral and game.ServerGame.Game.PlayingPlayers[pid].IsAI == false)then
				playerGameData[pid].WinCon.Ownedbonuses = playerGameData[pid].WinCon.Ownedbonuses+1;
			end
		end
		pid = nil;
	end
	Mod.PlayerGameData = playerGameData;
end