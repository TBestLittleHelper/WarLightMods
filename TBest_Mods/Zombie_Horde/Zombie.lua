function Zombie(game, standing)
	for _, territory in pairs(standing.Territories) do
		if (territory.OwnerPlayerID ~= 0) then --not nutral
				if (territory.OwnerPlayerID <= Mod.Settings.ZombieTeam) then --AI's ID goes from 1 and up
					local numArmies = territory.NumArmies.NumArmies;
					local ZombieStrength = Mod.Settings.ZombieStrength;
						if (ZombieStrength < 0) then ZombieStrength = 0 end;
						if (ZombieStrength > 100000) then ZombieStrength = 100000 end;			
				territory.NumArmies = Armies(ZombieStrength);

			end
		end
	end
end
	

--	Mod.Settings.ZombieStrength 
 --	Mod.Settings.ZombieStarts
--	Mod.Settings.ZombieTeam