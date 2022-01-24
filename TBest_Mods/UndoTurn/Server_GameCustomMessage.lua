function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Mod == "Undo") then
		publicGameData = Mod.PublicGameData

		--Check that they can undo last turn
		if (publicGameData.CanUndoLastTurn[playerID]) then
			publicGameData.UndoLastTurn = true
			publicGameData.CanUndoLastTurn[playerID] = false
		end
		Mod.PublicGameData = publicGameData
		Dump(Mod.PublicGameData)
		print(Mod.PublicGameData.CanUndoLastTurn[playerID])
	else
		error("Payload message not understood (" .. payload.Message .. ")")
	end
end

-- TODO cooldown? Only allowe every other turn to be undone?
