
function Server_Created(game, settings)
    local overriddenBonuses = {};

    for _, bonus in pairs(game.Map.Bonuses) do
		--skip negative bonuses unless ChangeNegavtive was checked
		if (bonus.Amount > 0 or Mod.Settings.ChangeNegavtive) then
			--skip superbonuses
			if (isSuperBonus(bonus) == false ) then
				local newValue = newBonusValue(bonus);
				if (newValue ~= bonus.Amount) then --don't do anything if we're not changing the bonus.
					overriddenBonuses[bonus.ID] = newValue;
				end
			--handels superbonuses if ChangeSuperBonuses was checked
			else if (Mod.Settings.ChangeSuperBonuses) then
				local newSuperBonusValue = 1; --small superbonuses are set to 1, hence defoult value
					if (Mod.Settings.SmalSuperBonuses == false) then
						newSuperBonusValue = newBonusValue(bonus);
					end
					if (newSuperBonusValue ~= bonus.Amount) then --don't do anything if we're not changing the bonus.
						overriddenBonuses[bonus.ID] = newSuperBonusValue;
					end
				end
			end	
		end
    end
    settings.OverriddenBonuses = overriddenBonuses;
end

--counts Territories in a bonus
function numTerritories(bonus)
  local count = 0
	for Territories in pairs(bonus.Territories) do 
		count = count + 1 end
  return count
end
--true if SuperBonus as defined by Mod.Settings.SuperBonus
function isSuperBonus(bonus)
  local count = 0
	for Territories in pairs(bonus.Territories) do 
		count = count + 1
		if (count >= (Mod.Settings.SuperBonus)) then
			return true 
		end
	end
	return false
end	
--determines bonusValue
function newBonusValue(bonus)
	local bonusValue;
		--if we use defoult Bonuse value, treat it as bonusValue. Else we use numTerritories
			if (Mod.Settings.ChangeDefaultBonus) then
				bonusValue = bonus.Amount;
			else
				bonusValue = numTerritories(bonus);
			end
			local newValue = bonusValue + Mod.Settings.Amount;

			--if we multiply
			if (Mod.Settings.Multiply) then
					newValue = bonusValue * Mod.Settings.Amount;
			end
				
			--If there is a random factor, apply it AFTER N
			if (Mod.Settings.RandomFactor ~= 0) then
				local rndAmount = math.random(-Mod.Settings.RandomFactor, Mod.Settings.RandomFactor);
				newValue = newValue + rndAmount;	
			end
			
				-- -1000 to +1000 is the maximum allowed range for overridden bonuses, never go beyond that
			if (newValue < -1000) then newValue = -1000 end;	
			if (newValue > 1000) then newValue = 1000 end;
	return newValue
end
	
