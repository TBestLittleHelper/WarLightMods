
function Server_Created(game, settings)
    local overriddenBonuses = {};

    for _, bonus in pairs(game.Map.Bonuses) do
		--skip negative bonuses unless AllowNegative was checked
		if (bonus.Amount > 0 or Mod.Settings.AllowNegative) then 
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
	
			-- -1000 to +1000 is the maximum allowed range for overridden bonuses, never go beyond that
			if (newValue < -1000) then newValue = -1000 end;
			if (newValue > 1000) then newValue = 1000 end;
		
			if (newValue ~= bonus.Amount) then --don't do anything if we're not changing the bonus.  We could leave this check off and it would work, but it show up in Settings as an overridden bonus when it's not.
				overriddenBonuses[bonus.ID] = newValue;
			end

		end
    end

    settings.OverriddenBonuses = overriddenBonuses;

end

--Territories in a bonus
function numTerritories(bonus)
  local count = 0
	for Territories in pairs(bonus.Territories) do 
		count = count + 1 end
  return count
end

