require("Utilities")

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	--payload = {key = key, TechTreeSelected = TechTreeSelected}

	local privateGameData = Mod.PrivateGameData
	local unlockable = privateGameData[playerID].Advancment.Unlockables[payload.TechTreeSelected][payload.key]
	Dump(unlockable)
	if
		(unlockable.Unlocked == false and
			unlockable.PreReq <= privateGameData[playerID].Advancment.PreReq[payload.TechTreeSelected])
	 then
		if (unlockable.UnlockPoints <= privateGameData[playerID].Advancment.Points[payload.TechTreeSelected]) then
			print("We can buy it!") -- TODO make this code more readable
			--Subtract the points from the techtree bank
			privateGameData[playerID].Advancment.Points[payload.TechTreeSelected] =
				privateGameData[playerID].Advancment.Points[payload.TechTreeSelected] - unlockable.UnlockPoints
			--Set unlocked to true
			privateGameData[playerID].Advancment.Unlockables[payload.TechTreeSelected][payload.key].Unlocked = true
			--Add one the the PreReq counter
			privateGameData[playerID].Advancment.PreReq[payload.TechTreeSelected] =
				privateGameData[playerID].Advancment.PreReq[payload.TechTreeSelected] + 1

			if (unlockable.Type == "Income" or unlockable.Type == "Attack" or unlockable.Type == "Defence") then
				if (privateGameData[playerID].Bonus[unlockable.Type] == nil) then
					privateGameData[playerID].Bonus[unlockable.Type] = 0
				end
				privateGameData[playerID].Bonus[unlockable.Type] =
					privateGameData[playerID].Bonus[unlockable.Type] + unlockable.Power
			elseif (unlockable.Type == "Structure") then
				print(payload.TerritoryID)
			else
				return --If we don't know the unlockable.Type, return
			end

			Mod.PrivateGameData = privateGameData
			--If not an AI, sync to playerGameData
			if not (game.ServerGame.Game.Players[playerID].IsAI) then
				local playerGameData = Mod.PlayerGameData
				playerGameData[playerID] = Mod.PrivateGameData[playerID]
				Mod.PlayerGameData = playerGameData
			end
			return
		end
	end
end
