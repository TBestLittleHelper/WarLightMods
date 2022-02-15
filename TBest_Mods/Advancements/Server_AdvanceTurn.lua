require("Utilities")

-- Global variables in AdvanceTurn are availible for all the hooks in this file
function Server_AdvanceTurn_Start(game, addNewOrder)
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData

	players = {}
	for playerID, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		players[playerID] = {}
		players[playerID].IsAI = player.IsAI
		players[playerID].TerritoriesOwned = 0
		players[playerID].StructuresOwned = 0
		players[playerID].ArmiesOwned = 0
		players[playerID].ArmiesDefeated = 0
		players[playerID].ArmiesLost = 0
		players[playerID].AttacksMade = 0

		players[playerID].Income = player.Income(0, game.ServerGame.LatestTurnStanding, true, false).Total --bypass army cap but count sanc card
		players[playerID].Points = {
			Technology = privateGameData[playerID].Advancment.Points.Technology,
			Military = privateGameData[playerID].Advancment.Points.Military,
			Culture = privateGameData[playerID].Advancment.Points.Culture
		}
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == "GameOrderAttackTransfer") then
		if (result.IsAttack) then
			local DefenceBoost = DefenceBoost()
			local AttackBoost = AttackBoost()
			players[order.PlayerID].AttacksMade = players[order.PlayerID].AttacksMade + 1

			local attackersKilled = result.AttackingArmiesKilled.NumArmies + DefenceBoost
			local defendersKilled = result.DefendingArmiesKilled.NumArmies + AttackBoost

			--Make sure we don't kill more then actualArmies
			if (result.ActualArmies.NumArmies < attackersKilled) then
				attackersKilled = result.ActualArmies.NumArmies
			end
			--TODO make sure we don't kill more then actual defending armies

			--Write to GameOrderResult	 (result)
			local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled)
			local NewDefendersArmiesKilled = WL.Armies.Create(defendersKilled)
			result.AttackingArmiesKilled = NewAttackingArmiesKilled
			result.DefendingArmiesKilled = NewDefendersArmiesKilled

			--We are takeing extra care to make the mod more compatible with other mods. Therfore, using  addNewOrder's second argument will mean we won't count the attack if another mod skips this order. Thus all point progress will be counted from the new custom order
			local msg =
				"The attacker had " ..
				tostring(AttackBoost) .. " attack boost. The defender had " .. tostring(DefenceBoost) .. " defence boost."
			local payload = "Advancments_," .. attackersKilled .. "," .. defendersKilled
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, msg, payload), true)
		end
	end

	if (order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "Advancments_")) then
		Dump(order)
		local payloadSplit = split(order.Payload, ",")
		local attackersKilled = payloadSplit[2]
		local defendersKilled = payloadSplit[3]
		players[order.PlayerID].ArmiesLost = players[order.PlayerID].ArmiesLost + attackersKilled
		players[order.PlayerID].ArmiesDefeated = players[order.PlayerID].ArmiesDefeated + defendersKilled

		players[order.PlayerID].AttacksMade = players[playerID].AttacksMade + 1

		--We use GameOrderCustom to record the information of a non-skipped order. We don't need the order itself and can SkipAndSupressSkippedMessage

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	--Loop all territories and count how many a player owns
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if (terr.IsNeutral == false) then
			players[terr.OwnerPlayerID].TerritoriesOwned = players[terr.OwnerPlayerID].TerritoriesOwned + 1
			players[terr.OwnerPlayerID].ArmiesOwned = players[terr.OwnerPlayerID].ArmiesOwned + terr.NumArmies.NumArmies
			if (terr.Structures ~= nil) then
				players[terr.OwnerPlayerID].StructuresOwned =
					players[terr.OwnerPlayerID].StructuresOwned + countStructures(terr.Structures)
			end
		end
	end

	--Give out points and boost
	for playerID, _ in pairs(players) do
		local techPoints = privateGameData[playerID].Advancment.Points.Technology
		local cultPoints = privateGameData[playerID].Advancment.Points.Culture
		local miliPoints = privateGameData[playerID].Advancment.Points.Military

		--Technology points. A point per turn; if over min income; a point per structure owned
		if (Mod.PublicGameData.Advancment.Technology.Progress.MinIncome <= players[playerID].Income) then
			techPoints = techPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Technology.Progress.TurnsEnded == 1) then
			techPoints = techPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Technology.Progress.StructuresOwned <= players[playerID].StructuresOwned) then
			techPoints = techPoints + players[playerID].StructuresOwned
		end

		--Culture points. A point if under max Armies; under max territories
		if (Mod.PublicGameData.Advancment.Culture.Progress.MaxArmiesOwned >= players[playerID].ArmiesOwned) then
			cultPoints = cultPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Culture.Progress.MaxTerritoriesOwned >= players[playerID].TerritoriesOwned) then
			cultPoints = cultPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Culture.Progress.AttacksMade <= players[playerID].AttacksMade) then
			cultPoints = cultPoints + 1
		end

		--Military points. A point for min territories owned; x+ armiesLost, x+ armies defeated
		if (Mod.PublicGameData.Advancment.Military.Progress.MinTerritoriesOwned <= players[playerID].TerritoriesOwned) then
			miliPoints = miliPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Military.Progress.ArmiesLost <= players[playerID].ArmiesLost) then
			miliPoints = miliPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Military.Progress.ArmiesDefeated <= players[playerID].ArmiesDefeated) then
			miliPoints = miliPoints + 1
		end

		privateGameData[playerID].Advancment.Points.Technology = techPoints
		privateGameData[playerID].Advancment.Points.Culture = cultPoints
		privateGameData[playerID].Advancment.Points.Military = miliPoints

		print(playerID, techPoints, cultPoints, miliPoints)
		if (not players[playerID].IsAI) then --Can't use playerGameData for AI's.
			playerGameData[playerID] = privateGameData[playerID]
		end
	end

	Mod.PlayerGameData = playerGameData
	Mod.PrivateGameData = privateGameData
	--local incomeMod = WL.IncomeMod.Create(playerID, cost, msg)
	--addNewOrder(WL.GameOrderEvent.Create(playerID, msg, nil, {}, nil, {incomeMod}))
end

--todo
function AttackBoost()
	return 2
end
--TODO
function DefenceBoost()
	return 1
end
--TODO test
function countStructures(Structures)
	local count = 0
	for key, value in pairs(Structures) do
		count = count + value
	end

	return count
end
