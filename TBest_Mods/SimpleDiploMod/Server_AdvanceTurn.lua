--TODO
--Give players 1 card if they have no cards. Prvent stuck games
--Make AI's able to declere war? Make AI alwasy being at war?
--Add WL.GameOrderEvent when a player declers war (aka plays spycard) 	addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,'Is at war with ' .. terrDefender));
--IF spy is played, play a spy on the SpiedPlayer to the Spying player, so war is mutal

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;

	
    if (game.Game.NumberOfTurns < Mod.Settings.NumTurns  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		and order.proxyType == 'GameOrderAttackTransfer'  --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
		and result.IsAttack  --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
		and not IsDestinationNeutral(game, order)) then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)
			if (isAtWar(game, order) == false) then --not at war? skip the attack
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'You are not at war with the owner of ' .. order.To, {}));
			end
	end
	 if (game.Game.NumberOfTurns < Mod.Settings.NumTurns  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		and order.proxyType == 'GameOrderPlayCardSpy') then  --look at spycard
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,' Declered war with ' .. order.TargetPlayerID, {}));	
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'You are not at war with the owner of ' .. order.To, {}));

	end
end

function IsDestinationNeutral(game, order)
	local terrID = order.To; --The order has "To" and "From" which are territory IDs
	local terrOwner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID; --LatestTurnStanding always shows the current state of the game.
	return terrOwner == WL.PlayerID.Neutral;
end

function isAtWar(game, order)
	local terrDefender = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID; --The player defending
	if (standing.ActiveCards ~= nill) then --if there are active cards
		for _, card in pairs (standing.ActiveCards) do 	
			if(card.Card.CardID == WL.CardID.Spy) then --look only at spy cards
				if(card.Card.TargetPlayerID == terrDefender) then	
					return true;	--if we are at war
				end
			end
		end
	end
	return false;
end
