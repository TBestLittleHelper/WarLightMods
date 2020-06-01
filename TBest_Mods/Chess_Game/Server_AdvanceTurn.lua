require 'Chess'

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	local standing = game.ServerGame.LatestTurnStanding;
	--If it's not our turn, skip the order.
	--TODO maybe make this always support premoves. Now it will only work, if the move order align
	if (myTurn(order.From) and order.proxyType == 'GameOrderAttackTransfer')then 
		makeMove(standing,game,order,result)
	else
	skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
	end;
end



function placeholder()
	if (game.Game.NumberOfTurns == 2) then
		
		--For all territores
		for _, territory in pairs(standing.Territories) do
		--	print('************')
			local connected = game.Map.Territories[territory.ID].Name .. " : ";
			--For all connections
			for _, connID in pairs (game.Map.Territories[territory.ID].ConnectedTo)do
				connected = connected .. (game.Map.Territories[connID.ID].Name .. " ")
				
			end
	--		print(connected);
		end
	end;
end;


