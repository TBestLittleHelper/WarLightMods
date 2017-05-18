function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;

	if (game.Game.NumberOfTurns < Mod.Settings.NumTurns) then  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		if ( order.proxyType == 'GameOrderAttackTransfer'  --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
		and result.IsAttack  --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
		and not IsDestinationNeutral(game, order)) then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)
			if (isAtWar(game, order) == false) then --not at war? skip the attack
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'You are not at war with the owner of ' .. game.Map.Territories[order.To].Name, {}));
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			end
		end
	end
		if (order.proxyType == 'GameOrderPlayCardSpy') then
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.PlayerID .. ' is now at war with ' .. order.TargetPlayerID, nil)); --Order is public	
		end
	--play a spy card, so we can remeber the event
	if (order.proxyType == 'GameOrderCustom') then
		local payloadSplit = split(order.Payload, ','); 
		local numTurn = tonumber(payloadSplit[1])
		local targetPlayerID = tonumber(payloadSplit[2]);
		local cardInstanceID = order.PlayerID .. targetPlayerID .. game.Game.NumberOfTurns;
	--create a spy card, then play it
	WL.NoParameterCardInstance.Create(cardInstanceID, WL.CardID.Spy);
	addNewOrder(WL.GameOrderPlayCardSpy.Create(thisCard, order.PlayerID, targetPlayerID);
	skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent,
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
