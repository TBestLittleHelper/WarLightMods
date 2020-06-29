--Called in any game set to manual territory distribution before players select their picks. This hook is not called in any game configured to automatic territory distribution.
function Server_StartDistribution( game, standing)
    playerGameDataSetup(game, standing);
end

function playerGameDataSetup(game, standing)
	--Set the mod boolean flag to be enabled
	publicGameData = Mod.PublicGameData
	publicGameData.GameFinalized = false;
	publicGameData.Diplo = {};
	publicGameData.Chat = {};
	broadCastGroupSetup(game);
	Mod.PublicGameData = publicGameData;
	
	playerGameData = Mod.PlayerGameData;
	
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
	if (Mod.Settings.ModWinningConditionsEnabled)then StartGameWinCon(game, standing) end;

end
function broadCastGroupSetup(game)
	publicGameData.Chat.BroadcastGroup = {};
	publicGameData.Chat.BroadcastGroup[1] = "When a game ends, all chat messages will be made public. Also, check out settings and tweek it to your liking."
	--publicGameData.Chat.BroadcastGroup[1].Sender = 0; --this might be someting we add in the future
	publicGameData.Chat.BroadcastGroup[2] = "Note that messages to the server is rate-limited to 5 calls every 30 seconds per client. Therefore, do not spam chat or group changes: it won't work!"
	publicGameData.Chat.BroadcastGroup.NumChat = 2
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
	--Note that we are skipping territory and bonus check here, since we are at the pick state
	Mod.PlayerGameData = playerGameData;
end

