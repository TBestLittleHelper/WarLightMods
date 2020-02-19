function Server_Created(game, settings)
	--settings.CommerceGame  = true;
	--CommerceArmyCostMultiplier  =1;
	--We can let host chose the army multiplier.
	settings.CommerceCityBaseCost  = 100;
	--Set cost of city high, to prevent players buliding cities
	--At the moment, can build cities is not a writable setting
end