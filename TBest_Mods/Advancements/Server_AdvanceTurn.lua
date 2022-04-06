require("Utilities")

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- Global variables in AdvanceTurn are availible for all the hooks in this file
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData

	for _, order in pairs(privateGameData.StartOfTurnOrders) do
		local terrModsOpt = nil
		Dump(order)
		if (order.terrModsOpt) then
			local terrModsOpt = {}
			local terrMod = WL.TerritoryModification.Create(order.terrModsOpt.TerritoryID)
			--If setting structure
			if (order.terrModsOpt.Structure ~= nil) then
				local newStructure = {[order.terrModsOpt.Structure] = 1}
				terrMod.SetStructuresOpt = newStructure
				terrModsOpt[1] = terrMod
			elseif (order.terrModsOpt.Armies ~= nil) then
				--If adding armies, add a deploy order
				addNewOrder(
					WL.GameOrderDeploy.Create(order.playerID, order.terrModsOpt.Armies, order.terrModsOpt.TerritoryID, true)
				)
			end
			--We always have the event order. So that order.msg get's shown
			addNewOrder(WL.GameOrderEvent.Create(order.playerID, order.msg, order.visibleToOpt, terrModsOpt))
		end
	end
	privateGameData.StartOfTurnOrders = {}

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
			Technology = privateGameData[playerID].Advancement.Points.Technology,
			Military = privateGameData[playerID].Advancement.Points.Military,
			Culture = privateGameData[playerID].Advancement.Points.Culture
		}
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == "GameOrderAttackTransfer") then
		if (result.IsAttack) then
			local AttackerPlayerID = game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID

			players[AttackerPlayerID].AttacksMade = players[AttackerPlayerID].AttacksMade + 1

			local attackersKilled =
				DefenceBoost(
				result.AttackingArmiesKilled.NumArmies,
				game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID,
				AttackerPlayerID
			)
			local defendersKilled = AttackBoost(result.DefendingArmiesKilled.NumArmies, AttackerPlayerID)

			--Make sure we don't kill more then actualArmies
			if (result.ActualArmies.NumArmies < attackersKilled) then
				attackersKilled = result.ActualArmies.NumArmies
			end
			--TODO make sure we don't kill more then actual defending armies?

			--Write to GameOrderResult	 (result)
			local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled)
			local NewDefendersArmiesKilled = WL.Armies.Create(defendersKilled)
			result.AttackingArmiesKilled = NewAttackingArmiesKilled
			result.DefendingArmiesKilled = NewDefendersArmiesKilled

			--We are takeing extra care to make the mod more compatible with other mods. Therfore, using  addNewOrder's second argument will mean we won't count the attack if another mod skips this order. Thus all point progress will be counted from the new custom order
			local payload = "Advancements_," .. attackersKilled .. "," .. defendersKilled
			addNewOrder(WL.GameOrderCustom.Create(AttackerPlayerID, "", payload), true)
		end
	end

	if (order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "Advancements_")) then
		local payloadSplit = split(order.Payload, ",")
		local attackersKilled = payloadSplit[2]
		local defendersKilled = payloadSplit[3]
		players[order.PlayerID].ArmiesLost = players[order.PlayerID].ArmiesLost + attackersKilled
		players[order.PlayerID].ArmiesDefeated = players[order.PlayerID].ArmiesDefeated + defendersKilled

		players[order.PlayerID].AttacksMade = players[order.PlayerID].AttacksMade + 1

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
				--While there can be more then 1 structure per territory, we want to encourage players to not stack them.
				players[terr.OwnerPlayerID].StructuresOwned = players[terr.OwnerPlayerID].StructuresOwned + 1
			end
		end
	end

	--Give out points and bonus
	for playerID, _ in pairs(players) do
		--Income bonus
		if (privateGameData[playerID].Bonus.Income ~= nil) then
			local incomeMod = WL.IncomeMod.Create(playerID, privateGameData[playerID].Bonus.Income, "Income from advancements")
			local msg = "Added bonus income"
			addNewOrder(WL.GameOrderEvent.Create(playerID, msg, {}, {}, nil, {incomeMod}))
		end
		--Investment bonus
		if (privateGameData[playerID].Bonus.Investment ~= nil) then
			local incomeMod = WL.IncomeMod.Create(playerID, privateGameData[playerID].Bonus.Investment, "Income from investment")
			local msg = "Added investment income"
			addNewOrder(WL.GameOrderEvent.Create(playerID, msg, {}, {}, nil, {incomeMod}))
		end
		--Loot bonus (income from defeated armies)
		if (privateGameData[playerID].Bonus.Loot ~= nil and players[playerID].ArmiesDefeated > 0) then
			local incomeMod =
				WL.IncomeMod.Create(
				playerID,
				privateGameData[playerID].Bonus.Loot * players[playerID].ArmiesDefeated,
				"Income from Loot"
			)
			local msg = "Added Loot income"
			addNewOrder(WL.GameOrderEvent.Create(playerID, msg, {}, {}, nil, {incomeMod}))
		end

		local techPoints = privateGameData[playerID].Advancement.Points.Technology
		local cultPoints = privateGameData[playerID].Advancement.Points.Culture
		local miliPoints = privateGameData[playerID].Advancement.Points.Military

		--Technology points. A point per turn; if over min income; a point per structure owned
		if (Mod.Settings.Advancement.Technology) then
			if (Mod.PublicGameData.Advancement.Technology.Progress.MinIncome <= players[playerID].Income) then
				techPoints = techPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Technology.Progress.TurnsEnded == 1) then
				techPoints = techPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Technology.Progress.StructuresOwned <= players[playerID].StructuresOwned) then
				techPoints = techPoints + players[playerID].StructuresOwned
			end
			privateGameData[playerID].Advancement.Points.Technology = techPoints
		end

		--Culture points. A point if under max Armies; under max territories
		if (Mod.Settings.Advancement.Culture) then
			if (Mod.PublicGameData.Advancement.Culture.Progress.MaxArmiesOwned >= players[playerID].ArmiesOwned) then
				cultPoints = cultPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Culture.Progress.MaxTerritoriesOwned >= players[playerID].TerritoriesOwned) then
				cultPoints = cultPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Culture.Progress.AttacksMade <= players[playerID].AttacksMade) then
				cultPoints = cultPoints + 1
			end
			privateGameData[playerID].Advancement.Points.Culture = cultPoints
		end

		--Military points. A point for min territories owned; x+ armiesLost, x+ armies defeated
		if (Mod.Settings.Advancement.Military) then
			if (Mod.PublicGameData.Advancement.Military.Progress.MinTerritoriesOwned <= players[playerID].TerritoriesOwned) then
				miliPoints = miliPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Military.Progress.ArmiesLost <= players[playerID].ArmiesLost) then
				miliPoints = miliPoints + 1
			end
			if (Mod.PublicGameData.Advancement.Military.Progress.ArmiesDefeated <= players[playerID].ArmiesDefeated) then
				miliPoints = miliPoints + 1
			end
			privateGameData[playerID].Advancement.Points.Military = miliPoints
		end

		if (not players[playerID].IsAI) then --For all non-AI players
			if (Mod.Settings.Advancement.Diplomacy) and (privateGameData[playerID].Bonus ~= nil) then
				--TODO diplomacy targets a player, so we must check that the player is still in PlayingPlayers / a valid playerID

				if (privateGameData[playerID].Bonus.Support ~= nil) then
					--Support gives the target 1 diplomacy point
					local targetPlayerID = privateGameData[playerID].Bonus.Support.TargetPlayerID
					privateGameData[targetPlayerID].Advancement.Points.Diplomacy =
						1 + privateGameData[targetPlayerID].Advancement.Points.Diplomacy
					local msg = playerID + " supported you! You earned 1 diplomacy point"
					addNewOrder(WL.GameOrderEvent.Create(targetPlayerID, msg, {playerID}))
				end
				if (privateGameData[playerID].Bonus.Investment ~= nil) then
					--Increase playerID income, and increase targetPlayerID income more
					local targetPlayerID = privateGameData[playerID].Bonus.Investment.TargetPlayerID
					local targetInvestment = 20
					local playerInvestment = 10

					local incomeModTarget = WL.IncomeMod.Create(targetPlayerID, targetInvestment, "Investment by " .. playerID)
					local incomeModPlayer = WL.IncomeMod.Create(playerID, playerInvestment, "Investment in " .. targetPlayerID)
					local msgTarget = "Investments from " .. playerID
					local msgPlayer = "Investments in " .. targetPlayerID
					addNewOrder(WL.GameOrderEvent.Create(targetPlayerID, msgTarget, {}, {}, nil, {incomeModTarget}))
					addNewOrder(WL.GameOrderEvent.Create(playerID, msgPlayer, {}, {}, nil, {incomeModPlayer}))
				end

				if (privateGameData[playerID].Bonus.Sanctions ~= nil) then
					--Reduce playerID income, and reduce targetPlayerID income more
					local targetPlayerID = privateGameData[playerID].Bonus.Sanctions.TargetPlayerID
					local targetSanction = 20
					local playerSanctionCost = 10

					local incomeModTarget = WL.IncomeMod.Create(targetPlayerID, targetSanction, "Sanctions by " .. playerID)
					local incomeModPlayer = WL.IncomeMod.Create(playerID, playerSanctionCost, "Cost of sanctioning " .. targetPlayerID)
					local msgTarget = "Sanctions from " .. playerID
					local msgPlayer = "Cost of sanctioning " .. targetPlayerID
					addNewOrder(WL.GameOrderEvent.Create(targetPlayerID, msgTarget, {}, {}, nil, {incomeModTarget}))
					addNewOrder(WL.GameOrderEvent.Create(playerID, msgPlayer, {}, {}, nil, {incomeModPlayer}))
				end
			end

			--For testing, give humans some extra points
			--privateGameData[playerID].Advancement.Points.Technology = techPoints + 100 -- TODO for testing, remove
			--privateGameData[playerID].Advancement.Points.Culture = cultPoints + 100
			--privateGameData[playerID].Advancement.Points.Military = miliPoints + 100
			privateGameData[playerID].Advancement.Points.Diplomacy = 100

			playerGameData[playerID] = privateGameData[playerID]
		else
			--We need to "help" the AI to unlock uppgrades. For now, we will just give them Income/Attack/Defence boost
			if privateGameData[playerID].Bonus.Income == nil then
				privateGameData[playerID].Bonus.Income = 0
			end
			if (Mod.Settings.Advancement.Technology) then
				if privateGameData[playerID].Advancement.Points.Technology >= 10 then
					privateGameData[playerID].Advancement.Points.Technology = techPoints - 10
					privateGameData[playerID].Bonus.Income = privateGameData[playerID].Bonus.Income + 2
				end
			end
			if (Mod.Settings.Advancement.Culture) then
				if privateGameData[playerID].Advancement.Points.Culture >= 10 then
					privateGameData[playerID].Advancement.Points.Culture = cultPoints - 10
					privateGameData[playerID].Bonus.Income = privateGameData[playerID].Bonus.Income + 2
				end
			end
			if (Mod.Settings.Advancement.Military) then
				if privateGameData[playerID].Advancement.Points.Military >= 10 then
					privateGameData[playerID].Advancement.Points.Military = miliPoints - 10
					privateGameData[playerID].Bonus.Income = privateGameData[playerID].Bonus.Income + 2
				end
			end
			if (Mod.Settings.Advancement.Diplomacy) then
				if privateGameData[playerID].Advancement.Points.Diplomacy >= 10 then
					privateGameData[playerID].Advancement.Points.Diplomacy =
						privateGameData[playerID].Advancement.Points.Diplomacy - 10
					privateGameData[playerID].Bonus.Income = privateGameData[playerID].Bonus.Income + 2
				end
			end
		end
	end

	Mod.PlayerGameData = playerGameData
	Mod.PrivateGameData = privateGameData
end

function AttackBoost(ArmiesDefeated, playerID)
	if (privateGameData[playerID].Bonus.Attack ~= nil) then
		local boost = privateGameData[playerID].Bonus.Attack * 0.01 --From a percentage to a decimal
		return ArmiesDefeated + (ArmiesDefeated * boost)
	end

	return ArmiesDefeated
end

function DefenceBoost(ArmiesDefeated, defenderPlayerID, attackerPlayerID)
	if (defenderPlayerID == WL.PlayerID.Neutral) then
		if (privateGameData[attackerPlayerID].Bonus.FreeNeutralCapture ~= nil) then
			ArmiesDefeated = 0
		end
		return ArmiesDefeated
	elseif (privateGameData[defenderPlayerID].Bonus.Defence ~= nil) then
		local boost = privateGameData[defenderPlayerID].Bonus.Defence * 0.01 --From a percentage to a decimal
		return ArmiesDefeated + math.floor((ArmiesDefeated * boost) + 0.05) --Round to int
	end

	return ArmiesDefeated
end
