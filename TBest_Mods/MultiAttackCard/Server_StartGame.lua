function Server_StartGame(game, standing)
	local playerGameData = Mod.PlayerGameData

	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			playerGameData[player.ID] = {charges = 1}
		end
	end
	Mod.PlayerGameData = playerGameData
end
