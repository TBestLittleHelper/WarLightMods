--WIP add Zombie as a Mod.Setting
--Determine Zombie at game start

function Server_StartGame(game, standing)
	local playersSet = {}
	if (Mod.Settings.RandomZombie == true) then
		for _, territory in pairs(standing.Territories) do
	  		if (not territory.IsNeutral) then
	  			playersSet[territory.OwnerPlayerID] = true
	  		end
  		end
		local winner = lucky(playersSet);
		Mod.Settings.RandomZombie = winner;
end
	
function lucky(playersSet)
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
  	local winner = math.random(0,n);
	return playersTable[winner];
end
