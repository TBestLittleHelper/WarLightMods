--Called in any game set to manual territory distribution before players select their picks. This hook is not called in any game configured to automatic territory distribution.
function Server_StartDistribution(game, standing)
	if (Mod.Settings.Version ~= 1) then
		return
	end

	playerGameDataSetup(game, standing)
end

function playerGameDataSetup(game, standing)
	--Set the mod boolean flag to be enabled
	publicGameData = Mod.PublicGameData
	publicGameData.GameFinalized = false
	publicGameData.Chat = {}
	broadCastGroupSetup(game)
	Mod.PublicGameData = publicGameData

	playerGameData = Mod.PlayerGameData

	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			playerGameData[player.ID] = {}
			playerGameData[player.ID].Chat = {} -- For the chat function
		end
	end
	Mod.PlayerGameData = playerGameData
end
function broadCastGroupSetup(game)
	publicGameData.Chat.BroadcastGroup = {}
	publicGameData.Chat.BroadcastGroup[1] =
		"When a game ends, all chat messages will be made public. Also, check out settings and tweek it to your liking."
	--publicGameData.Chat.BroadcastGroup[1].Sender = 0; --this might be someting we add in the future
	publicGameData.Chat.BroadcastGroup[2] =
		"Note that messages to the server are rate-limited. Therefore, do not spam chat messages or group changes: it won't work!"
	publicGameData.Chat.BroadcastGroup.NumChat = 2
end
