require ('Server_GameCustomMessage');
require('Utilities');

function Server_AdvanceTurn_Start(game, addNewOrder)
	if (Mod.Settings.Version ~= 1)then return end;

	if (Mod.Settings.ModDiplomacyEnabled)then
		--Remember in a global variable all alliances that are breaking this turn
		AlliancesBreakingThisTurn = {};
	end;
	if (Mod.Settings.ModBetterCitiesEnabled)then
		BetterCities_Server_AdvanceTurn_Start(game, addNewOrder)
	end;
	if (Mod.Settings.ModWinningConditionsEnabled)then
		WinConGameWon = false;
		WinCon_Server_AdvanceTurn_Start(game, addNewOrder)
	end;
end;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (Mod.Settings.Version ~= 1)then return end;

	orderSkiped = false;
	if (Mod.Settings.ModSafeStartEnabled)then
		SafeStart_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
		if (orderSkiped)then return end;
	end;

	if (Mod.Settings.ModDiplomacyEnabled)then
		Diplomacy_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder);
		if (orderSkiped)then return end;
	end;
	
	if (Mod.Settings.ModBetterCitiesEnabled)then
		BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder);
		if (orderSkiped)then return end;
	end;

	if (Mod.Settings.ModWinningConditionsEnabled)then
		WinCon_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
		if (orderSkiped)then return end;
	end;
end;
function Server_AdvanceTurn_End (game, addNewOrder)	
	if (Mod.Settings.Version ~= 1)then return end;

	--Add a turn 'chat' msg to show that a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)

	if (Mod.Settings.ModDiplomacyEnabled)then	
		Diplomacy_Server_AdvanceTurn_End(game, addNewOrder)
	end;
	if (Mod.Settings.ModWinningConditionsEnabled)then
		WinCon_Server_AdvanceTurn_End (game,addNewOrder)
	end;
end

--Diplomacy mod functions
function Diplomacy_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		--Check if the players are allied
		if (PlayersAreAllied(game, game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID)) then
			skipThisOrder(WL.ModOrderControl.Skip);
			orderSkiped = true;
		end
	elseif (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'Diplomacy2_')) then
		local payloadSplit = split(order.Payload, '_'); 
		local msg = payloadSplit[2];
		if (msg == 'BreakAlliance') then
			local allianceBreak = {};
			allianceBreak.OurPlayerID = order.PlayerID;
			allianceBreak.OtherPlayerID = tonumber(payloadSplit[3]);
			AlliancesBreakingThisTurn[#AlliancesBreakingThisTurn + 1] = allianceBreak;

			--Don't show the break order here. Instead, we'll insert it ourselves at the bottom in Server_AdvanceTurn_End
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			orderSkiped = true;

			--Insert a message into player data for the target so that they know to alert the player.
			local ourPlayerName = game.Game.Players[allianceBreak.OurPlayerID].DisplayName(nil, false);
			print(ourPlayerName .. ' has broken their alliance with' .. allianceBreak.OtherPlayerID);
			AlertPlayer(allianceBreak.OtherPlayerID, ourPlayerName .. ' has broken their alliance with you' , game);
		end
	end
end
function Diplomacy_Server_AdvanceTurn_End(game, addNewOrder)
	--break any alliances that we saw break orders for	
	local gameData = Mod.PublicGameData;
	for _, allianceBreak in pairs(AlliancesBreakingThisTurn) do

		gameData.Alliances = filter(gameData.Alliances or {}, function(alliance) return not AllianceMatchesPlayers(alliance, allianceBreak.OurPlayerID, allianceBreak.OtherPlayerID) end);

		--Add an order so everyone is aware of the breakage
		local ourPlayerName = game.Game.Players[allianceBreak.OurPlayerID].DisplayName(nil, false);
		local otherPlayerName = game.Game.Players[allianceBreak.OtherPlayerID].DisplayName(nil, false);
		local msg = ourPlayerName .. ' broke alliance with ' .. otherPlayerName;
		addNewOrder(WL.GameOrderEvent.Create(allianceBreak.OurPlayerID, msg));
	end
	Mod.PublicGameData = gameData;
end

function AlertPlayer(playerID, msg, game)
	if (game.Game.Players[playerID].IsAI)then return end;

	local playerData = Mod.PlayerGameData;
	if (playerData[playerID] == nil) then
		playerData[playerID] = {};
	end
	local payload = {};
	payload.Message = msg;
	payload.ID = NewIdentity();

	local alerts = playerData[playerID].Alerts or {};
	table.insert(alerts, payload);
	playerData[playerID].Alerts = alerts;
	Mod.PlayerGameData.Diplo = playerData;
end
function AllianceMatchesPlayers(alliance, playerOne, playerTwo)
	return (alliance.PlayerOne == playerOne and alliance.PlayerTwo == playerTwo)
		or (alliance.PlayerOne == playerTwo and alliance.PlayerTwo == playerOne);
end
function PlayersAreAllied(game, playerOne, playerTwo)
	if (playerOne == playerTwo) then return false end; --never allied with yourself.
	return first(Mod.PublicGameData.Alliances or {}, function(alliance) return AllianceMatchesPlayers(alliance, playerOne, playerTwo) end) ~= nil;
end

--Better Cities functions
function BetterCities_Server_AdvanceTurn_Start(game, addNewOrder) 
	if (Mod.Settings.CityGrowth == false)then return end; --City growth is off

	--The turns cities can grow.
	if ((game.Game.NumberOfTurns+1) % Mod.Settings.CityGrowthFrequency == 0) then
		local cityCap = Mod.Settings.CityGrowthCap;
		local cityGrowth = Mod.Settings.CityGrowthPower;
	
		local standing = game.ServerGame.LatestTurnStanding;
		local CurrentIndex=1;
		local NewOrders={};
		
		--As of now WarZone only has one type of structure.
		local structure = {}
		local Cities = WL.StructureType.City
		for _, territory in pairs(standing.Territories) do
			--Can be 0, if a territory has been bombed. We don't want that city to grow.
			if not(territory.Structures == nil or territory.Structures[WL.StructureType.City] == 0) then
				local terrMod = WL.TerritoryModification.Create(territory.ID);		
				structure[Cities] = territory.Structures[WL.StructureType.City] +cityGrowth;
				if (structure[Cities] <= cityCap) then
					terrMod.SetStructuresOpt   = structure
					NewOrders[CurrentIndex]=terrMod;
					CurrentIndex=CurrentIndex+1;
				end
			end
		end					
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"Smaller cities have grown",nil,NewOrders));
	end
end
function BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == 'GameOrderDeploy') then
		--if city is already destroyed (0) or is not present (nil), return or skip according to Mod.Settings	
		if (game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures == nil) then
			--If mod settings say city deploy only, skip. Else return
			if (Mod.Settings.CityDeployOnly)then 
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
				orderSkiped = true;
			end;	
			return;			
		else if (game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures[WL.StructureType.City] == 0) then					
				if (Mod.Settings.CityDeployOnly)then 
					skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
					orderSkiped = true;
				end;	
				return;
			end;
		end;	
		
		--Extra armies when deploying in city, but a city is reduced. 
		if (Mod.Settings.CommerceFreeCityDeploy == true) then
			local NewOrders={};	
			local terrMod = WL.TerritoryModification.Create(order.DeployOn);	
			--Reduce structure/cities by 1.
			local structure = {}
			local Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].Structures[WL.StructureType.City] -1;
			terrMod.SetStructuresOpt = structure;
			--Add the deploy
			terrMod.SetArmiesTo  = game.ServerGame.LatestTurnStanding.Territories[order.DeployOn].NumArmies.NumArmies + order.NumArmies *2;
			NewOrders[1]=terrMod;
			--If not a commerce game, skip the original order and create a new one. 
			--Add the deploy order to the game and skip the original order.
			if (game.Settings.CommerceGame == false)then
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,"Deploy " .. order.NumArmies .. " in " .. game.Map.Territories[order.DeployOn].Name .. " using local city resources.", {}, NewOrders));
			end;
			--We want to keep the gold cost if commerce. Instead of skipping the order, we keep the original too.
			if (game.Settings.CommerceGame) then
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,"Deployed an extra " .. order.NumArmies .. " in " .. game.Map.Territories[order.DeployOn].Name .. " using local city resources.", {}, NewOrders))
			end;
			orderSkiped = true;	
		end	
		return;
	end
	--Give a X% def. bonus per city on defending territory 
	if (order.proxyType == 'GameOrderAttackTransfer' and Mod.Settings.CityWallsActive == true)  then
		if (result.IsAttack) then
			if not (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures == nil) then	
				if (game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] > 0) then
					local DefBonus = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.City] * Mod.Settings.DefPower;
					local attackersKilled = result.AttackingArmiesKilled.NumArmies +  result.AttackingArmiesKilled.NumArmies * DefBonus
					
					--Minimum kill 1 attacking army
					if(attackersKilled == 0) then
						attackersKilled = 1					
					--Max armies lost is equal to actualArmies
					elseif (result.ActualArmies.NumArmies - attackersKilled < 0) then
						attackersKilled = result.ActualArmies.NumArmies;
						--Note : At the moment we don't dmg special units
						--That would be a very rare edge case, we might want to handle in the future
					else
						--round up, always
						attackersKilled = math.ceil(attackersKilled);
					end
					
					--Write to GameOrderResult	 (result)
					local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled) 
					result.AttackingArmiesKilled = NewAttackingArmiesKilled
					local msg = "The city has " .. tostring(DefBonus*100) .. "% fortification bonus";
					addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID,msg,{order.PlayerID}));
					orderSkiped = true;
				end
			end
		end
		return;
	end;
		
	--Bomb cards reduces cities by the given X strength.
	if(order.proxyType == 'GameOrderPlayCardBomb' and Mod.Settings.BombcardActive == true) then
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			--if city is already destroyed, return
			if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] == 0) then
				return;
			end
			
			local structure = {}
			local NewOrders={};
			local Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] -Mod.Settings.BombcardPower;
			local msg = "City was bombed";
			if (structure[Cities] < 1) then
				--We can't set to nil, so we set to zero
				structure[Cities] = 0;
				msg = "The City is destroyed! It is now a ruin and won't grow before it's been rebuilt."
			end
			local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			
			--Add the new order event. Discard the card played. Skip the normal card effect.		
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID));			
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			orderSkiped = true;
		end
		return;
	end;
		
	--If we blockade or emergency blockade on a city we own. We build on that city
	if(order.proxyType == 'GameOrderPlayCardBlockade' or order.proxyType == 'GameOrderPlayCardAbandon') then
		if (Mod.Settings.BlockadeBuildCityActive == false) then return end;
		--If there is a structure present
		if not(game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures == nil) then
			--Check that the player controls the territory
			if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
				return;
			end;
			--A city at size zero won't grow by itself. 
			if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] == 0) then
				return;
			end;
			
			
			local structure = {}
			local NewOrders={};
			local Cities = WL.StructureType.City
			structure[Cities] = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures[WL.StructureType.City] +Mod.Settings.BlockadePower;
			local msg = "The City's defenses have been increased!";
			local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
			terrMod.SetStructuresOpt   = structure
			NewOrders[1]=terrMod;
			
			--Add the new order event. Discard the card played. This skips the normal card effect.
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
			addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID));			
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);		
			orderSkiped = true;
			return;
		end		
	end
	
	--EMB card setting
	if(order.proxyType == 'GameOrderPlayCardAbandon' and Mod.Settings.EMBActive == true) then
		--This check should not be needed for EMB, but we have it anyway as it may increase mod compatibility
		--Check if we own the territory, else return
		if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
			return;
		end;
		--Check for nil on latestTurnStanding. This is for founding a new city, so has to be nil
		if (game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].Structures ~= nil)then return;end;
		
		local structure = {}
		local NewOrders={};
		local Cities = WL.StructureType.City 
		structure[Cities] = Mod.Settings.EMBPower
			
		local msg = "A new city has been founded!";
		local terrMod = WL.TerritoryModification.Create(order.TargetTerritoryID);	
		terrMod.SetStructuresOpt   = structure
		NewOrders[1]=terrMod;	
		
		--Add the new order event. Discard the card played. This skips the normal card effect.
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,msg,{},NewOrders));
		addNewOrder(WL.GameOrderDiscard.Create(order.PlayerID, order.CardInstanceID));			
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);		
		orderSkiped = true;
		return;
	end	
end

--WinCon functions
function WinCon_Server_AdvanceTurn_Start(game, addNewOrder)
	playerGameData = Mod.PlayerGameData;
	recalculate = {};
end;
--TODO we can do checkwin much better and faster
function WinCon_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if(order.PlayerID == WL.PlayerID.Neutral)then
		return;
	end
	if (WinConGameWon)then return end;

	if(order.proxyType == "GameOrderDeploy")then
		if(game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
			playerGameData[order.PlayerID].WinCon.Ownedarmies = playerGameData[order.PlayerID].WinCon.Ownedarmies+order.NumArmies;
			checkwin(order.PlayerID,addNewOrder,game);
		end
	end
	if(order.proxyType == "GameOrderPlayCardBomb")then
		local targetterr = order.TargetTerritoryID;
		if(game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
			playerGameData[order.PlayerID].WinCon.Killedarmies = playerGameData[order.PlayerID].WinCon.Killedarmies+game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies/2;
			checkwin(order.PlayerID,addNewOrder,game);
		end
		local player2 = game.ServerGame.LatestTurnStanding.Territories[targetterr].OwnerPlayerID;
		if(player2 ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[player2].IsAI == false)then
			playerGameData[player2].WinCon.Lostarmies = playerGameData[player2].WinCon.Lostarmies+game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies/2
			playerGameData[player2].WinCon.Ownedarmies = playerGameData[player2].WinCon.Ownedarmies - game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies/2
			checkwin(order.PlayerID,addNewOrder,game)
		end
	end
	if(order.proxyType == "GameOrderPlayCardAbandon" or order.proxyType == "GameOrderPlayCardBlockade")then
		local targetterr = order.TargetTerritoryID;
		if(playerGameData[order.PlayerID].WinCon.HoldTerritories == nil)then
			playerGameData[order.PlayerID].WinCon.HoldTerritories = {};
		end
		if(playerGameData[order.PlayerID].WinCon.HoldTerritories[targetterr] == nil)then
			playerGameData[order.PlayerID].WinCon.HoldTerritories[targetterr] = nil;
		end
		if(game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
			playerGameData[order.PlayerID].WinCon.Ownedarmies = playerGameData[order.PlayerID].WinCon.Ownedarmies - game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.PlayerID].WinCon.Lostarmies = playerGameData[order.PlayerID].WinCon.Lostarmies+game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.PlayerID].WinCon.Killedarmies = playerGameData[order.PlayerID].WinCon.Killedarmies+game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.PlayerID].WinCon.Lostterritories = playerGameData[order.PlayerID].WinCon.Lostterritories + 1;
			playerGameData[order.PlayerID].WinCon.Ownedterritories = playerGameData[order.PlayerID].WinCon.Ownedterritories - 1;
			for _,boni in pairs(game.Map.Territories[targetterr].PartOfBonuses)do
				local Match = true;
				for _,terrid in pairs(game.Map.Bonuses[boni].Territories)do
					if(terrid ~= targetterr)then
						local terrowner = game.ServerGame.LatestTurnStanding.Territories[terrid].OwnerPlayerID;
						if(terrowner ~= order.PlayerID)then
							Match = false;
						end
					end
				end
				if(Match == true)then
					playerGameData[order.PlayerID].WinCon.Lostbonuses = playerGameData[order.PlayerID].WinCon.Lostbonuses + 1;
					playerGameData[order.PlayerID].WinCon.Ownedbonuses = playerGameData[order.PlayerID].WinCon.Ownedbonuses - 1;
				end
			end
			checkwin(order.PlayerID,addNewOrder,game);
		end
	end
	if(order.proxyType == "GameOrderPlayCardGift")then
		local targetterr = order.TerritoryID;
		local toowner = order.GiftTo;
		if(playerGameData[order.PlayerID].WinCon.HoldTerritories == nil)then
			playerGameData[order.PlayerID].WinCon.HoldTerritories = {};
		end
		if(playerGameData[order.PlayerID].WinCon.HoldTerritories[targetterr] == nil)then
			playerGameData[order.PlayerID].WinCon.HoldTerritories[targetterr] = nil;
		end
		for _,boni in pairs(game.Map.Territories[targetterr].PartOfBonuses)do
			local Match = true;
			local Match2 = true;
			for _,terrid in pairs(game.Map.Bonuses[boni].Territories)do
				if(terrid ~= targetterr)then
					local terrowner = game.ServerGame.LatestTurnStanding.Territories[terrid].OwnerPlayerID;
					if(terrowner ~= toowner)then
						Match2 = false;
					end
					if(terrowner ~= order.PlayerID)then
						Match = false;
					end
				end
			end
			if(Match == true and game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
				playerGameData[order.PlayerID].WinCon.Lostbonuses = playerGameData[order.PlayerID].WinCon.Lostbonuses+1;
				playerGameData[order.PlayerID].WinCon.Ownedbonuses = playerGameData[order.PlayerID].WinCon.Ownedbonuses - 1;
			end
			if(Match2 == true and toowner ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[toowner].IsAI == false)then
				playerGameData[toowner].WinCon.Lostbonuses = playerGameData[toowner].WinCon.Capturedbonuses + 1;
				playerGameData[toowner].WinCon.Ownedbonuses = playerGameData[toowner].WinCon.Ownedbonuses + 1;
			end
		end
		if(game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
			playerGameData[order.PlayerID].WinCon.Ownedarmies = playerGameData[order.PlayerID].WinCon.Ownedarmies - game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.PlayerID].WinCon.Lostarmies = playerGameData[order.PlayerID].WinCon.Lostarmies+game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.PlayerID].WinCon.Lostterritories = playerGameData[order.PlayerID].WinCon.Lostterritories + 1;
			playerGameData[order.PlayerID].WinCon.Ownedterritories = playerGameData[order.PlayerID].WinCon.Ownedterritories - 1;
			checkwin(order.PlayerID,addNewOrder,game);
		end
		if(game.ServerGame.Game.Players[order.GiftTo].IsAI == false)then
			playerGameData[order.GiftTo].WinCon.Ownedarmies = playerGameData[order.GiftTo].WinCon.Ownedarmies - game.ServerGame.LatestTurnStanding.Territories[targetterr].NumArmies.NumArmies;
			playerGameData[order.GiftTo].WinCon.Ownedterritories = playerGameData[order.GiftTo].WinCon.Ownedterritories + 1;
			checkwin(order.GiftTo,addNewOrder,game);
		end
	end
	if(order.proxyType == "GameOrderAttackTransfer")then
		if(result.IsAttack)then
			local toowner = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID;
			if(result.IsSuccessful)then
				for _,boni in pairs(game.Map.Territories[order.To].PartOfBonuses)do
					local Match = true;
					local Match2 = true;
					for _,terrid in pairs(game.Map.Bonuses[boni].Territories)do
						if(terrid ~= order.To)then
							local terrowner = game.ServerGame.LatestTurnStanding.Territories[terrid].OwnerPlayerID;
							if(terrowner ~= toowner)then
								Match2 = false;
							end
							if(terrowner ~= order.PlayerID)then
								Match = false;
							end
						end
					end
					if(Match == true and game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
						playerGameData[order.PlayerID].WinCon.Capturedbonuses = playerGameData[order.PlayerID].WinCon.Capturedbonuses+1;
						playerGameData[order.PlayerID].WinCon.Ownedbonuses = playerGameData[order.PlayerID].WinCon.Ownedbonuses+1;
					end
					if(Match2 == true and toowner ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[toowner].IsAI == false)then
						playerGameData[toowner].WinCon.Lostbonuses = playerGameData[toowner].WinCon.Lostbonuses + 1;
						playerGameData[toowner].WinCon.Ownedbonuses = playerGameData[toowner].WinCon.Ownedbonuses - 1;
					end
				end
			end
			if(game.ServerGame.Game.Players[order.PlayerID].IsAI == false)then
				if(result.IsSuccessful)then
					playerGameData[order.PlayerID].WinCon.Capturedterritories = playerGameData[order.PlayerID].WinCon.Capturedterritories+1;
					playerGameData[order.PlayerID].WinCon.Ownedterritories = playerGameData[order.PlayerID].WinCon.Ownedterritories+1;
					local Match = true;
					for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
						if(terr.OwnerPlayerID == toowner and terr.ID ~= order.To)then
							Match = false;
						end
					end
					if(Match == true)then
						if(toowner ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[toowner].IsAI == false)then
							playerGameData[order.PlayerID].WinCon.Eleminateplayers = playerGameData[order.PlayerID].WinCon.Eleminateplayers+1;
						else
							playerGameData[order.PlayerID].WinCon.Eleminateais = playerGameData[order.PlayerID].WinCon.Eleminateais+1;
						end
						playerGameData[order.PlayerID].WinCon.Eleminateaisandplayers = playerGameData[order.PlayerID].WinCon.Eleminateaisandplayers+1;
					end
					if(playerGameData[order.PlayerID].WinCon.HoldTerritories == nil)then
						playerGameData[order.PlayerID].WinCon.HoldTerritories = {};
					end
					if(playerGameData[order.PlayerID].WinCon.HoldTerritories[order.To] == nil)then
						playerGameData[order.PlayerID].WinCon.HoldTerritories[order.To] = 0;
					end
				end
				playerGameData[order.PlayerID].WinCon.Ownedarmies = playerGameData[order.PlayerID].WinCon.Ownedarmies - result.AttackingArmiesKilled.NumArmies;
				playerGameData[order.PlayerID].WinCon.Lostarmies = playerGameData[order.PlayerID].WinCon.Lostarmies+result.AttackingArmiesKilled.NumArmies;
				playerGameData[order.PlayerID].WinCon.Killedarmies = playerGameData[order.PlayerID].WinCon.Killedarmies+result.DefendingArmiesKilled.NumArmies;
				checkwin(order.PlayerID,addNewOrder,game);
			end
			if(toowner ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[toowner].IsAI == false)then
				if(result.IsSuccessful)then
					playerGameData[toowner].WinCon.Lostterritories = playerGameData[toowner].WinCon.Lostterritories+1;
					playerGameData[toowner].WinCon.Ownedterritories = playerGameData[toowner].WinCon.Ownedterritories-1;
					if(playerGameData[toowner].WinCon.HoldTerritories == nil)then
						playerGameData[toowner].WinCon.HoldTerritories = {};
					end
					if(playerGameData[toowner].WinCon.HoldTerritories[order.To] == nil)then
						playerGameData[toowner].WinCon.HoldTerritories[order.To] = nil;
					end
				end
				playerGameData[toowner].WinCon.Ownedarmies = playerGameData[toowner].WinCon.Ownedarmies - result.DefendingArmiesKilled.NumArmies;
				playerGameData[toowner].WinCon.Killedarmies = playerGameData[toowner].WinCon.Killedarmies+result.AttackingArmiesKilled.NumArmies;
				playerGameData[toowner].WinCon.Lostarmies = playerGameData[toowner].WinCon.Lostarmies+result.DefendingArmiesKilled.NumArmies;
				checkwin(toowner,addNewOrder,game);
			end
		end
	end
	
end
function WinCon_Server_AdvanceTurn_End (game,addNewOrder)

	if (WinConGameWon)then return end;
	if (Mod.Settings.terrcondition == nil)then return end;

	for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories)do
		if(terr.OwnerPlayerID ~= WL.PlayerID.Neutral and game.ServerGame.Game.Players[terr.OwnerPlayerID].IsAI == false)then
			if(playerGameData[terr.OwnerPlayerID].WinCon.HoldTerritories[terr.ID] == nil)then
				playerGameData[terr.OwnerPlayerID].WinCon.HoldTerritories[terr.ID] = 0;
			end
			playerGameData[terr.OwnerPlayerID].WinCon.HoldTerritories[terr.ID] = playerGameData[terr.OwnerPlayerID].WinCon.HoldTerritories[terr.ID] + 1;
			checkwin(terr.OwnerPlayerID,addNewOrder,game)
			if (WinConGameWon)then return end;
		end
	end
	Mod.PlayerGameData = playerGameData;
end
function checkwin(pid,addNewOrder,game)
	local completed = 0;
	local required = Mod.Settings.Conditionsrequiredforwin;
	if(Mod.Settings.Capturedterritories ~= 0)then
		if(playerGameData[pid].WinCon.Capturedterritories >= Mod.Settings.Capturedterritories)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Lostterritories ~= 0)then
		if(playerGameData[pid].WinCon.Lostterritories >= Mod.Settings.Lostterritories)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Ownedterritories ~= 0)then
		if(playerGameData[pid].WinCon.Ownedterritories >= Mod.Settings.Ownedterritories)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Capturedbonuses ~= 0)then
		if(playerGameData[pid].WinCon.Capturedbonuses >= Mod.Settings.Capturedbonuses)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Lostbonuses ~= 0)then
		if(playerGameData[pid].WinCon.Lostbonuses >= Mod.Settings.Lostbonuses)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Ownedbonuses ~= 0)then
		if(playerGameData[pid].WinCon.Ownedbonuses >= Mod.Settings.Ownedbonuses)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Killedarmies ~= 0)then
		if(playerGameData[pid].WinCon.Killedarmies >= Mod.Settings.Killedarmies)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Lostarmies ~= 0)then
		if(playerGameData[pid].WinCon.Lostarmies >= Mod.Settings.Lostarmies)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Ownedarmies ~= 0)then
		if(playerGameData[pid].WinCon.Ownedarmies >= Mod.Settings.Ownedarmies)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Eleminateais ~= 0)then
		if(playerGameData[pid].WinCon.Eleminateais >= Mod.Settings.Eleminateais)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Eleminateplayers ~= 0)then
		if(playerGameData[pid].WinCon.Eleminateplayers >= Mod.Settings.Eleminateplayers)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.Eleminateaisandplayers ~= 0)then
		if(playerGameData[pid].WinCon.Eleminateaisandplayers >= Mod.Settings.Eleminateaisandplayers)then
			completed = completed + 1;
		end
	end
	if(Mod.Settings.terrcondition ~= nil)then
		for _,condition in pairs(Mod.Settings.terrcondition)do
			if(playerGameData[pid].WinCon.HoldTerritories ~= nil)then
				local terrid = getterrid(game,condition.Terrname);
				if(terrid ~= -1)then
					if(playerGameData[pid].WinCon.HoldTerritories[terrid] ~= nil)then
						if(playerGameData[pid].WinCon.HoldTerritories[terrid] >= tonumber(condition.Turnnum))then
							completed = completed + 1;
						end
					end
				end
			end
		end
	end
	if(completed >= required)then
		local num = 1;
		local effect = {}
		for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
			effect[num] = WL.TerritoryModification.Create(terr.ID);
			effect[num].SetOwnerOpt = pid;
			num = num +1;
		end
		WinConGameWon = true;
		addNewOrder(WL.GameOrderEvent.Create(pid, "Win", nil, effect));
	end
end
function getterrid(game,name)
	for _,terr in pairs(game.Map.Territories)do
		if(terr.Name == name)then
			return terr.ID;
		end
	end
	return -1;
end


--SafeStart
--https://github.com/FizzerWL/ExampleMods/blob/master/SafeStartMod/Server_AdvanceTurn.lua
function SafeStart_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	--[[if (order.proxyType == 'GameOrderAttackTransfer' and order.PlayerID == 4569) then
		print('NumTurns=' .. game.Game.NumberOfTurns .. ' Mod.Settings.NumTurns=' .. tostring(Mod.Settings.NumTurns) .. ' From=' .. game.Map.Territories[order.From].Name .. ' to=' .. game.Map.Territories[order.To].Name .. ' IsAttack=' .. tostring(result.IsAttack) .. ' DestinationOwner=' .. tostring(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID));
	end ]]--

    if (game.Game.NumberOfTurns < Mod.Settings.SafeStartNumTurns  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		and order.proxyType == 'GameOrderAttackTransfer'  --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
		and result.IsAttack  --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
		and not IsDestinationNeutral(game, order)) then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --skip it
		orderSkiped = true;
		local msg = 'Safe start mod skipped attack to ' .. game.Map.Territories[order.To].Name .. ' from ' .. game.Map.Territories[order.From].Name;
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {}, {}));
	end

end

function IsDestinationNeutral(game, order)
	local terrID = order.To; --The order has "To" and "From" which are territory IDs
	local terrOwner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID; --LatestTurnStanding always shows the current state of the game.
	return terrOwner == WL.PlayerID.Neutral;
end