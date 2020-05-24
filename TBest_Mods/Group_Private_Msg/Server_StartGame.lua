function Server_StartGame(game, standing)		
	--Set the mod boolean flag to be enabled
	local publicGameData = Mod.PublicGameData
	publicGameData.ChatModEnabled = true;
	publicGameData.GameFinalized = false;
	Mod.PublicGameData = publicGameData;
end
