require("Utilities")

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	--payload = {key = key, TechTreeSelected = TechTreeSelected}
	local privateGameData = Mod.PrivateGameData
	local unlockable = privateGameData[playerID].Advancement.Unlockables[payload.TechTreeSelected][payload.key]
	--Dump(unlockable)
	if
		(unlockable.Unlocked == false and
			unlockable.PreReq <= privateGameData[playerID].Advancement.PreReq[payload.TechTreeSelected])
	 then
		if (unlockable.UnlockPoints <= privateGameData[playerID].Advancement.Points[payload.TechTreeSelected]) then
			print("We can buy it!")
			--Subtract the points from the techtree bank
			privateGameData[playerID].Advancement.Points[payload.TechTreeSelected] =
				privateGameData[playerID].Advancement.Points[payload.TechTreeSelected] - unlockable.UnlockPoints
			--Set unlocked to true
			privateGameData[playerID].Advancement.Unlockables[payload.TechTreeSelected][payload.key].Unlocked = true
			--Add one the the PreReq counter
			privateGameData[playerID].Advancement.PreReq[payload.TechTreeSelected] =
				privateGameData[playerID].Advancement.PreReq[payload.TechTreeSelected] + 1

			if
				(unlockable.Type == "Income" or unlockable.Type == "Attack" or unlockable.Type == "Defence" or
					unlockable.Type == "Loot" or
					unlockable.Type == "DefenceLoot")
			 then
				if (privateGameData[playerID].Bonus[unlockable.Type] == nil) then
					privateGameData[playerID].Bonus[unlockable.Type] = 0
				end
				privateGameData[playerID].Bonus[unlockable.Type] =
					privateGameData[playerID].Bonus[unlockable.Type] + unlockable.Power
			elseif (unlockable.Type == "Structure") then
				local order = {
					playerID = playerID,
					msg = "Built a structure",
					visibleToOpt = {},
					terrModsOpt = {TerritoryID = payload.TerritoryID, Structure = unlockable.Structure},
					setResourcesOpt = nil,
					incomeModsOpt = nil
				}
				table.insert(privateGameData.StartOfTurnOrders, order)
			elseif (unlockable.Type == "Armies") then
				local order = {
					playerID = playerID,
					msg = "Bought " .. unlockable.Power .. " mercinaries",
					visibleToOpt = {},
					terrModsOpt = {TerritoryID = payload.TerritoryID, Armies = unlockable.Power},
					setResourcesOpt = nil,
					incomeModsOpt = nil
				}
				table.insert(privateGameData.StartOfTurnOrders, order)
			elseif (unlockable.Type == "Support" or unlockable.Type == "Sanctions" or unlockable.Type == "Investment") then
				targetPlayerID = payload.PlayerID
				--Can't target this to yourself
				if (targetPlayerID == playerID) then
					return
				end
				--Store what player we are targeting, both in the unlockable and in the bonus
				privateGameData[playerID].Advancement.Unlockables[payload.TechTreeSelected][payload.key].TargetPlayerID =
					targetPlayerID

				privateGameData[playerID].Bonus[unlockable.Type] = {TargetPlayerID = targetPlayerID}

				--Set this back to false, since we can unlock/change the advancement multiple times
				privateGameData[playerID].Advancement.Unlockables[payload.TechTreeSelected][payload.key].Unlocked = false
			else
				print(unlockable.Type)
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
