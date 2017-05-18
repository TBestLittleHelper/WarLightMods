function Server_Created(game, settings)
	local Player = game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID;
	local winner = lucky();
		print (winner);
	for _,territory in pairs(game.ServerGame.LatestTurnStanding.Territories)do
		territory.OwnerPlayerID = winner;
	
	end
	
end

function lucky()
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
  	local winner = math.random(0,n);
	return winner;
end

function PrintProxyInfo(obj)
   print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end
