function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)	
	if(order.proxyType == 'GameOrderPlayCardSanctions') then
		if(order.PlayerID == order.SanctionedPlayerID) then
			skipThisOrder(WL.ModOrderControl.Skip)
		end
	end
end
