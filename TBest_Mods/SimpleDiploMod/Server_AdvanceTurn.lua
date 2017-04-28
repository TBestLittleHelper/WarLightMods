--TODO
--Give players 1 card if they have no cards. Prvent stuck games
--Make AI's able to declere war?

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (game.Game.NumberOfTurns < Mod.Settings.NumTurns  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		and order.proxyType == 'GameOrderAttackTransfer'  --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
		and result.IsAttack  --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
		and not IsDestinationNeutral(game, order)) then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)
			if (isAtWar(game, order) == false) then --not at war? skip the attack
				skipThisOrder(WL.ModOrderControl.Skip);
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'You are not at war with ' .. order.To, {}));
			end

	end

end

function IsDestinationNeutral(game, order)
	local terrID = order.To; --The order has "To" and "From" which are territory IDs
	local terrOwner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID; --LatestTurnStanding always shows the current state of the game.
	return terrOwner == WL.PlayerID.Neutral;
end

function isAtWar(game, order)
	local terrDefender = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID; --The player defending
	if (game.ActiveCard ~= nill) then --if active cards
		for _, CardID in pairs (game.ActiveCard) do --look at spy cards	
		
			print ("running_isAtWar");
			print (game.CardID);
		if(CardID == GameOrderPlayCardSpy) then
			if(CardID.TargetPlayerID == terrDefender) then				
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,'Is at war with ' .. terrDefender));
			return true;
			end
		end
		end
	end
	return false;
end	
