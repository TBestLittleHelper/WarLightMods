require("Utilities")

function Server_StartGame(game, standing)
	if (Mod.Settings.Version ~= 1)then return end;

	--TODO we can move stuff here around better so we don't call unneeded things
	publicGameData = Mod.PublicGameData
	playerGameData = Mod.PlayerGameData;

	--Call playerGameDataSetup if we havn't done it already
	for _,pid in pairs(game.ServerGame.Game.Players)do
		if(pid.IsAI == false)then
			if (playerGameData[pid.ID] == nil )then
				print('Doing playerGameDataSetup')
				playerGameDataSetup(game, standing);
			end;
		end
	end;
	if (Mod.Settings.ModBetterCitiesEnabled)then StartGameBetterCities(game, standing) end;
	-- TODO We plan to remove winCon. For now, it won't be used in any new games
	--if (Mod.Settings.ModWinningConditionsEnabled)then StartGameWinCon(game, standing) end;

	Mod.PublicGameData = publicGameData;
	Mod.PlayerGameData = playerGameData;

end

function playerGameDataSetup(game, standing)
	--Set the mod boolean flag to be enabled
	publicGameData.GameFinalized = false;
	publicGameData.Chat = {};
	broadCastGroupSetup(game);

	for _,pid in pairs(game.ServerGame.Game.Players)do
		if(pid.IsAI == false)then
			playerGameData[pid.ID] = {};
			playerGameData[pid.ID].Chat = {}; -- For the chat function
		end
	end

end
function broadCastGroupSetup(game)
	publicGameData.Chat.BroadcastGroup = {};
	publicGameData.Chat.BroadcastGroup[1] = "When a game ends, all chat messages can be made public. Also, check out settings and tweek it to your liking."
	publicGameData.Chat.BroadcastGroup[2] = "Note that messages to the server is rate-limited to 5 calls every 30 seconds per client. Therefore, do not spam chat or group changes: it won't work!"
	publicGameData.Chat.BroadcastGroup[3] = "BETA! Please report any bugs and feedback to TBest. Not everything has been tested yet, so I aplogize for any issues you may run into"

	publicGameData.Chat.BroadcastGroup.NumChat = 3

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
