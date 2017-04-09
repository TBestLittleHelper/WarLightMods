
function Server_Created(game, settings)
    local overriddenBonuses = {};

    for _, bonus in pairs(game.Map.Bonuses) do
		--skip negative bonuses unless AllowNegative was checked
		if (bonus.Amount > 0 or Mod.Settings.AllowNegative) then 
			local numTerritories = numTerritories(bonus);
			local newValue = numTerritories + Mod.Settings.Amount;
				if (Mod.Settings.Multiply) then
					newValue = numTerritories * Mod.Settings.Amount;
				end
				

			-- -1000 to +1000 is the maximum allowed range for overridden bonuses, never go beyond that
			if (newValue < -1000) then newValue = -1000 end;
			if (newValue > 1000) then newValue = 1000 end;
		
			overriddenBonuses[bonus.ID] = newValue;
		end
    end

    settings.OverriddenBonuses = overriddenBonuses;

end

function numTerritories(bonus)
  local count = 0
	for Territories in pairs(bonus.Territories) do 
		count = count + 1 end
  return count
end

