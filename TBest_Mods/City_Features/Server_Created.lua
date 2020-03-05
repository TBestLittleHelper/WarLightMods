function Server_Created(game, settings)
	--CommerceGame is not writable.
	--settings.CommerceGame = true;
	
	--CommerceArmyCostMultiplier  =1;
	--We can let the host chose the army multiplier.
	
	--Set cost of city high, to prevent players building cities
	--At the moment, can build cities is not a writable setting
	settings.CommerceCityBaseCost  = 500;
end