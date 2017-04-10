function Zombie(game, standing)
	for _, territory in pairs(standing.Territories) do
		if (territory.OwnerPlayerID ~= 0) then --not nutral (change to WL.PlayerID.Neutral etc once WL update)
				if (territory.OwnerPlayerID <= Mod.Settings.ZombieTeam) then --AI's ID starts from 1 and up
					local player = territory.OwnerPlayerID; --TODO
					local numArmies = territory.NumArmies.NumArmies;
					local ZombieStrength = Mod.Settings.ZombieStrength;
					
	
					
						if (ZombieStrength < 0) then ZombieStrength = 0 end;
						if (ZombieStrength > 100000) then ZombieStrength = 100000 end;			
				territory.NumArmies = Armies(ZombieStrength); --changed to WL.Armies.Create for next update

			end
		end
	end
end


function numberOfBonuses(OwnerPlayerID)
local count = 0;
local bonusCap = false;
	for _, bonus in pairs(game.Map.Bonuses) do
		--check if owner
	end
	if (count > Mod.Settings.StartingBonuses) then bonusCap = true end;
	return bonusCap;
end
