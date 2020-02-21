function Server_Created(game, settings)
	--CommerceGame is not writable. It might be in the future
	--settings.CommerceGame = true;
	--CommerceArmyCostMultiplier  =1;
	--We can let host chose the army multiplier.
	settings.CommerceCityBaseCost  = 150;
	settings.Commanders   = false;
	--Set cost of city high, to prevent players building cities
	--At the moment, can build cities is not a writable setting
	
end