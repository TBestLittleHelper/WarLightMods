--TODO
--Give players 1 card if they have no cards. Prvent stuck games
--


function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	--[[if (order.proxyType == 'GameOrderAttackTransfer' and order.PlayerID == 4569) then
		print('NumTurns=' .. game.Game.NumberOfTurns .. ' Mod.Settings.NumTurns=' .. tostring(Mod.Settings.NumTurns) .. ' From=' .. game.Map.Territories[order.From].Name .. ' to=' .. game.Map.Territories[order.To].Name .. ' IsAttack=' .. tostring(result.IsAttack) .. ' DestinationOwner=' .. tostring(game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID));
	end ]]--

    if (game.Game.NumberOfTurns < Mod.Settings.NumTurns  -- are we at the start of the game, within our defined range?  (without this check, we'd affect the entire game, not just the start)
		and order.proxyType == 'GameOrderAttackTransfer'  --is this an attack/transfer order?  (without this check, we'd stop deployments or cards)
		and result.IsAttack  --is it an attack? (without this check, transfers wouldn't be allowed within your own territory or to teammates)
		and not IsDestinationNeutral(game, order) or isAtWar) then --is the destination owned by neutral? (without this check we'd stop people from attacking neutrals)
		skipThisOrder(WL.ModOrderControl.Skip);

	end

end

function IsDestinationNeutral(game, order)
	local terrID = order.To; --The order has "To" and "From" which are territory IDs
	local terrOwner = game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID; --LatestTurnStanding always shows the current state of the game.
	return terrOwner == WL.PlayerID.Neutral;
end

function isAtWar(game, order)
	local TOterrID = order.To; --The order has "To" and "From" which are territory IDs
	local FromTerrID = order.From; 
	local terrDefender = game.ServerGame.LatestTurnStanding.Territories[TOterrID].OwnerPlayerID; --The player defending
	local terrAttacker = game.ServerGame.LatestTurnStanding.Territories[FromterrID].OwnerPlayerID; --The player attacking
	for _, GameOrderPlayCard in pairs (game.ServerGame.LatestTurnStanding.ActiveCard) do
		if(GameOrderPlayCard == GameOrderPlayCardSpy) then
			if(GameOrderPlayCard.TargetPlayerID == terrDefender) then
				
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID,'Is at war with ' .. terrDefender));
			return true;
			end
		end
	end
	return false;
end	
