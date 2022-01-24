function Server_StartGame(game, standing)
	publicGameData = Mod.PublicGameData
	publicGameData.UndoLastTurn = false
	publicGameData.CanUndoLastTurn = {}

	--Set CanUndoLastTurn[player.ID] to true for all humen players
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			publicGameData.CanUndoLastTurn[player.ID] = true
		end
	end
	Mod.PublicGameData = publicGameData
end
