function Server_Created(game, settings)
--TODO remove all but one player territori
--TODO change settings to AutoDist.

  local playersSet = {}
	  for _, territory in pairs(standing.Territories) do
		  if (not territory.IsNeutral) then
			  playersSet[territory.OwnerPlayerID] = true
  		end
	  end
	
  	local playersTable = {}
	  local n = 0;
	  for key, _ in pairs(playersSet) do
		  playersTable[n] = key
		  n = n + 1;
	  end	
  local winner = math.random(0,n);
	
end

function PrintProxyInfo(obj)
   print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end
