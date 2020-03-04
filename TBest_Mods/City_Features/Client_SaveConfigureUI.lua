function Client_SaveConfigureUI(alert)
	
	Mod.Settings.CityWallsActive = false;
	if (cityWallsToggle.GetIsChecked()) then 
		if (cityWallsToggle.GetIsChecked()) then
			Mod.Settings.CityWallsActive = true;
			Mod.Settings.DefPower = sliderDefBonus.GetValue() * 0.01; -- Convert to decimals from percentage
			if (Mod.Settings.DefPower < 0) then Mod.Settings.DefPower = 0; end
			if (Mod.Settings.DefPower > 100) then Mod.Settings.DefPower = 100; end
			
		end
	end;
	
	Mod.Settings.BombcardActive = false;
	if (bombCardToggle.GetIsChecked()) then 
		Mod.Settings.BombcardActive = bombCardToggle.GetIsChecked();
		Mod.Settings.BombcardPower = sliderBombCard.GetValue();
		if (Mod.Settings.BombcardPower < 1) then Mod.Settings.BombcardPower = 1; end
		if (Mod.Settings.BombcardPower > 10) then Mod.Settings.BombcardPower = 10; end

	end
	
	Mod.Settings.StartingCitiesActive = false;
	if (startingCitiesToggle.GetIsChecked()) then
		Mod.Settings.StartingCitiesActive = true;
		--Mod.Settings.NumberOfStartingCities TODO
	end
	
	Mod.Settings.CustomSenarioCapitals = -1;
	if (capitalsToggle.GetIsChecked()) then
		Mod.Settings.CustomSenarioCapitals = sliderCapitals.GetValue();	
				if (Mod.Settings.CustomSenarioCapitals < 0) then Mod.Settings.CustomSenarioCapitals = 0; end
		if (Mod.Settings.CustomSenarioCapitals > 1000) then Mod.Settings.CustomSenarioCapitals = 1000; end

		--TODO Mod.Settings.CapitalExtraStartingCities
	end
	
    Mod.Settings.BlockadeBuildCityActive = false;
	if (buildCitiesToggle.GetIsChecked()) then
		Mod.Settings.BlockadeBuildCityActive = capitalsToggle.GetIsChecked();	
		Mod.Settings.BlockadePower = sliderBlockCard.GetValue();
		if (Mod.Settings.BlockadePower < 1) then Mod.Settings.BlockadePower = 1; end
		if (Mod.Settings.BlockadePower > 10) then Mod.Settings.BlockadePower = 10; end

	end
	
    Mod.Settings.WastlandCities = false;
	if (wastelandsToggle.GetIsChecked()) then
		Mod.Settings.WastlandCities = wastelandsToggle.GetIsChecked();
	end;
	
	Mod.Settings.CommerceFreeCityDeploy = false;
	if (commerceFreeDeployCityToggle.GetIsChecked()) then
		Mod.Settings.CommerceFreeCityDeploy = commerceFreeDeployCityToggle.GetIsChecked();
	end;

end	
