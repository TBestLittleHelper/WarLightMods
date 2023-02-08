require("Utilities")

--TODO Cities grow? From Dig cite, to mine? to City?
--TODO addNewOrder: A function that you can call to add a GameOrder to the start of the turn. You may call this function multiple times if you wish to add multiple orders. Pass a single GameOrder as the first argument to this function. Optionally, you can also pass "true" as a second argument to this function to make your new order get skipped if the order this hook was called on gets skipped, either by your mod or another mod. This second argument was added in 5.17.0.

function Server_AdvanceTurn_Start(game, addNewOrder)
	oldVersion = false
	if (Mod.Settings.Version ~= 2) then
		oldVersion = true
		return
	end

	if (Mod.Settings.ModBetterCitiesEnabled) then
		BetterCities_Server_AdvanceTurn_Start(game, addNewOrder)
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (oldVersion) then
		return
	end

	orderSkiped = false
	if (Mod.Settings.ModSafeStartEnabled) then
		SafeStart_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
		if (orderSkiped) then
			return
		end
	end

	if (Mod.Settings.ModBetterCitiesEnabled) then
		BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
		if (orderSkiped) then
			return
		end
	end
end
function Server_AdvanceTurn_End(game, addNewOrder)
	if (oldVersion) then
		return
	end

	--Add a turn 'chat' msg to show that a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)
end

function AlertPlayer(playerID, msg, game)
	if (game.Game.players[playerID].IsAI) then
		return
	end

	local playerData = Mod.PlayerGameData
	if (playerData[playerID] == nil) then
		playerData[playerID] = {}
	end
	local payload = {}
	payload.Message = msg
	payload.ID = NewIdentity()

	local alerts = playerData[playerID].Alerts or {}
	table.insert(alerts, payload)
	playerData[playerID].Alerts = alerts
	Mod.PlayerGameData.Diplo = playerData
end

--Better Cities functions
function BetterCities_Server_AdvanceTurn_Start(game, addNewOrder)
	if (Mod.Settings.CityGrowth == false) then
		return
	end --City growth is off

	--The turns cities can grow.
	if ((game.Game.NumberOfTurns + 1) % Mod.Settings.CityGrowthFrequency == 0) then
		local cityCap = Mod.Settings.CityGrowthCap
		local cityGrowth = Mod.Settings.CityGrowthPower

		local standing = game.ServerGame.LatestTurnStanding
		local CurrentIndex = 1
		local NewOrders = {}

		--As of now WarZone only has one type of structure.
		local structure = {}
		local Cities = WL.StructureType.City
		for _, territory in pairs(standing.Territories) do
			--Can be 0, if a territory has been bombed. We don't want that city to grow.
			if not (territory.Structures == nil or territory.Structures[WL.StructureType.City] == 0 or territory.Structures[WL.StructureType.City] == nil) then
				local terrMod = WL.TerritoryModification.Create(territory.ID)
				structure[Cities] = territory.Structures[WL.StructureType.City] + cityGrowth
				if (structure[Cities] <= cityCap) then
					terrMod.SetStructuresOpt = structure
					NewOrders[CurrentIndex] = terrMod
					CurrentIndex = CurrentIndex + 1
				end
			end
		end
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Smaller cities have grown", nil, NewOrders))
	end
end
function BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == "GameOrderDeploy") then
		local terrStructures = game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures;
		--if city is already destroyed (0) or is not present (nil), return or skip according to Mod.Settings
		if (terrStructures == nil) then
			--If mod settings say city deploy only, skip. Else return
			if (Mod.Settings.CityDeployOnly) then
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
				orderSkiped = true
			end
			return
		else

			if (terrStructures[WL.StructureType.City] == 0 or terrStructures[WL.StructureType.City] == nil) then
				if (Mod.Settings.CityDeployOnly) then
					skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
					orderSkiped = true
				end
				return
			end
		end

		--Extra armies when deploying in city, but a city is reduced.
		if (Mod.Settings.CommerceFreeCityDeploy == true) then
			local NewOrders = {}
			local terrMod = WL.TerritoryModification.Create(order.DeployOn)
			--Reduce structure/cities by 1.
			local structure = {}
			local Cities = WL.StructureType.City
			structure[Cities] =
				terrStructures[WL.StructureType.City] - 1
			terrMod.SetStructuresOpt = structure
			--Add the deploy
			terrMod.SetArmiesTo =
				game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].NumArmies.NumArmies + order.NumArmies * 2
			NewOrders[1] = terrMod
			--If not a commerce game, skip the original order and create a new one.
			--Add the deploy order to the game and skip the original order.
			if (game.Settings.CommerceGame == false) then
				addNewOrder(
					WL.GameOrderEvent.Create(
						order.PlayerID,
						"Deploy " ..
							order.NumArmies .. " in " .. game.Map.Territories[order.DeployOn].Name .. " using local city resources.",
						{},
						NewOrders
					)
				)
			end
			--We want to keep the gold cost if commerce. Instead of skipping the order, we keep the original too.
			if (game.Settings.CommerceGame) then
				addNewOrder(
					WL.GameOrderEvent.Create(
						order.PlayerID,
						"Deployed an extra " ..
							order.NumArmies .. " in " .. game.Map.Territories[order.DeployOn].Name .. " using local city resources.",
						{},
						NewOrders
					)
				)
			end
			orderSkiped = true
		end
		return
	end
	--Give a X% def. bonus per city on defending territory
	if (order.proxyType == "GameOrderAttackTransfer" and Mod.Settings.CityWallsActive == true) then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil or game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] == nil) then
				if (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] > 0) then
					local DefBonus =
						game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * Mod.Settings.DefPower
					local attackersKilled = result.AttackingArmiesKilled.NumArmies + result.AttackingArmiesKilled.NumArmies * DefBonus

					--Minimum kill 1 attacking army
					if (attackersKilled == 0) then
						--Max armies lost is equal to actualArmies
						attackersKilled = 1
					elseif (result.ActualArmies.NumArmies - attackersKilled < 0) then
						--Note : At the moment we don't dmg special units
						--That would be a very rare edge case, we might want to handle in the future
						attackersKilled = result.ActualArmies.NumArmies
					else
						--round up, always
						attackersKilled = math.ceil(attackersKilled)
					end

					--Write to GameOrderResult	 (result)
					local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled)
					result.AttackingArmiesKilled = NewAttackingArmiesKilled
					local msg = "The city has " .. tostring(DefBonus * 100) .. "% fortification bonus"
					addNewOrder(
						WL.GameOrderEvent.Create(
							game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID,
							msg,
							{order.PlayerID}
						)
					)
					orderSkiped = true
				end
			end
		end
		return
	end

	--Bomb cards reduces cities by the given X strength.
	if (order.proxyType == "GameOrderPlayCardBomb" and Mod.Settings.BombcardActive == true) then
		local terrStructures = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures;
		if not (terrStructures == nil) then
			--if city is already destroyed, or there are no city structures: return
			if (terrStructures[WL.StructureType.City] == 0 or terrStructures[WL.Structures.City] == nil) then
				return
			end

			local structure = {}
			local NewOrders = {}
			local Cities = WL.StructureType.City
			structure[Cities] =
				game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] -
				Mod.Settings.BombcardPower
			local msg = "City was bombed"
			if (structure[Cities] < 1) then
				--We can't set to nil, so we set to zero
				structure[Cities] = 0
				msg = "The City is destroyed! It is now a ruin and won't grow before it's been rebuilt."
			end
			local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID)
			terrMod.SetStructuresOpt = structure
			NewOrders[1] = terrMod

			--Add the new order event. Discard the card played. Skip the normal card effect.
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {}, NewOrders))
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID))
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
			orderSkiped = true
		end
		return
	end

	--If we blockade or emergency blockade on a city we own. We build on that city
	if (order.proxyType == "GameOrderPlayCardBlockade" or order.proxyType == "GameOrderPlayCardAbandon") then
		if (Mod.Settings.BlockadeBuildCityActive == false) then
			return
		end
		--If there is a structure present
		local terrStructures = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures;
		if not (terrStructures == nil) then
			--Check that the player controls the territory
			if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
				return
			end
			--A city at size zero won't grow by itself. Or a city that does not exsist, since it's a diffrent structure here
			if (terrStructures[WL.StructureType.City] == 0 or terrStructures[WL.Structures.City] == nil) then
				return
			end

			local structure = {}
			local NewOrders = {}
			local Cities = WL.StructureType.City
			structure[Cities] =
				game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] +
				Mod.Settings.BlockadePower
			local msg = "The City's defenses have been increased!"
			local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID)
			terrMod.SetStructuresOpt = structure
			NewOrders[1] = terrMod

			--Add the new order event. Discard the card played. This skips the normal card effect.
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {}, NewOrders))
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID))
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
			orderSkiped = true
			return
		end
	end

	--EMB card setting
	if (order.proxyType == "GameOrderPlayCardAbandon" and Mod.Settings.EMBActive == true) then
		--This check should not be needed for EMB, but we have it anyway as it may increase mod compatibility
		--Check if we own the territory, else return
		if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
			return
		end
		--Check for nil on latestTurnStanding. This is for founding a new city, so has to be nil
		if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures ~= nil) then
			return
		end

		local structure = {}
		local NewOrders = {}
		local Cities = WL.StructureType.City
		structure[Cities] = Mod.Settings.EMBPower

		local msg = "A new city has been founded!"
		local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID)
		terrMod.SetStructuresOpt = structure
		NewOrders[1] = terrMod

		--Add the new order event. Discard the card played. This skips the normal card effect.
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {}, NewOrders))
		addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID))
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
		orderSkiped = true
		return
	end
end

function getterrid(game, name)
	for _, terr in pairs(game.Map.Territories) do
		if (terr.Name == name) then
			return terr.ID
		end
	end
	return -1
end

--SafeStart
--https://github.com/FizzerWL/ExampleMods/blob/master/SafeStartMod/Server_AdvanceTurn.lua
function SafeStart_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder) --
	--[[if (order.proxyType == 'GameOrderAttackTransfer' and order.PlayerID == 4569) then
		print('NumTurns=' .. game.Game.NumberOfTurns .. ' Mod.Settings.NumTurns=' .. tostring(Mod.Settings.NumTurns) .. ' From=' .. game.Map.Territories[order.From].Name .. ' to=' .. game.Map.Territories[order.To].Name .. ' IsAttack=' .. tostring(result.IsAttack) .. ' DestinationOwner=' .. tostring(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID));
	end ]] if
		(game.Game.NumberOfTurns < Mod.Settings.SafeStartNumTurns and -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
			order.proxyType == "GameOrderAttackTransfer" and --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
			result.IsAttack and --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
			not IsDestinationNeutral(game, order))
	 then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage) --skip it
		orderSkiped = true
		local msg =
			"Safe start mod skipped attack to " ..
			game.Map.Territories[order.To].Name .. " from " .. game.Map.Territories[order.From].Name
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {}, {}))
	end
end

function IsDestinationNeutral(game, order)
	local terrID = order.To --The order has "To" and "From" which are territory IDs
	local terrOwner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID --LatestTurnStanding always shows the current state of the game.
	return terrOwner == WL.PlayerID.Neutral
end

function TurnDivider(turnNumber)
	local playerGameData = Mod.PlayerGameData
	local ChatArrayIndex

	local ChatInfo = {}
	ChatInfo.Sender = -1 --The Mod is the sender
	ChatInfo.Chat = " ------ End of turn " .. turnNumber + 1 .. " ------"

	--For All playerGameData.Chat
	for playerID, player in pairs(playerGameData) do
		--For ALL groups
		if (playerGameData[playerID].Chat ~= nil) then
			for TargetGroupID, group in pairs(playerGameData[playerID].Chat) do
				--ADD a turn chat
				if (playerGameData[playerID].Chat[TargetGroupID] == nil) then
					ChatArrayIndex = 1
				else
					ChatArrayIndex = #playerGameData[playerID].Chat[TargetGroupID] + 1
				end
				playerGameData[playerID].Chat[TargetGroupID].NumChat = ChatArrayIndex
				playerGameData[playerID].Chat[TargetGroupID][ChatArrayIndex] = {}
				playerGameData[playerID].Chat[TargetGroupID][ChatArrayIndex] = ChatInfo
			end
		end
	end
	--Save playerGameData
	Mod.PlayerGameData = playerGameData
end
