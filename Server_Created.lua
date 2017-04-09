
function Server_Created(game, settings)
    local overriddenBonuses = {};

    for _, bonus in pairs(game.Map.Bonuses) do
		--skip negative bonuses unless AllowNegative was checked
		if (bonus.Amount > 0 or Mod.Settings.AllowNegative) then 
			local numTerritories = numTerritories(bonus);				
			local newValue = numTerritories + Mod.Settings.Amount;

			-- -100 to +100 is the maximum allowed range for overridden bonuses, never go beyond that
			if (newValue < -100) then newValue = -100 end;
			if (newValue > 100) then newValue = 100 end;
		
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

