function Server_StartGame(game, standing)		
	--Set the mod boolean flag to be enabled
	local publicGameData = Mod.PublicGameData
	publicGameData.ChatModEnabled = true;
	Mod.PublicGameData = publicGameData;
end
