function Client_SaveConfigureUI(alert)
	Mod.Settings.Version = 2

	Mod.Settings.ModGiftGoldEnabled = ModGiftGoldEnabled
	Mod.Settings.ModBetterCitiesEnabled = ModBetterCitiesEnabled

	Mod.Settings.SafeStartNumTurns = SafeStartNumberInputField.GetValue()
	if (Mod.Settings.SafeStartNumTurns > 0) then
		Mod.Settings.ModSafeStartEnabled = true
	else
		Mod.Settings.ModSafeStartEnabled = false
	end

	if (ModBetterCitiesEnabled) then
		SaveModBetterCities()
	end
end

function SaveModBetterCities()
	Mod.Settings.CityWallsActive = false
	if (cityWallsToggle.GetIsChecked()) then
		Mod.Settings.CityWallsActive = true
		Mod.Settings.DefPower = sliderDefBonus.GetValue() * 0.01 -- Convert to decimals from percentage
		if (Mod.Settings.DefPower < 0) then
			Mod.Settings.DefPower = 0
		elseif (Mod.Settings.DefPower > 100) then
			Mod.Settings.DefPower = 100
		end
	end

	Mod.Settings.CityGrowth = false
	if (cityGrowthToggle.GetIsChecked()) then
		Mod.Settings.CityGrowth = true
		Mod.Settings.CityGrowthCap = sliderCityGrowthCap.GetValue()
		Mod.Settings.CityGrowthFrequency = sliderCityGrowthFrequency.GetValue()

		if (Mod.Settings.CityGrowthCap < 1) then
			Mod.Settings.CityGrowthCap = 1
		elseif (Mod.Settings.CityGrowthCap > 100) then
			Mod.Settings.CityGrowthCap = 100
		end

		if (Mod.Settings.CityGrowthFrequency < 1) then
			Mod.Settings.CityGrowthFrequency = 1
		elseif (Mod.Settings.CityGrowthFrequency > 100) then
			Mod.Settings.CityGrowthFrequency = 100
		end

		Mod.Settings.CityGrowthPower = 1 --For now, a host can't change this value but we might open it up in the future.
	end

	Mod.Settings.BombcardActive = false
	if (bombCardToggle.GetIsChecked()) then
		Mod.Settings.BombcardActive = bombCardToggle.GetIsChecked()
		Mod.Settings.BombcardPower = sliderBombCard.GetValue()
		if (Mod.Settings.BombcardPower < 1) then
			Mod.Settings.BombcardPower = 1
		end
		if (Mod.Settings.BombcardPower > 10) then
			Mod.Settings.BombcardPower = 10
		end
	end

	Mod.Settings.StartingCitiesActive = false
	if (startingCitiesToggle.GetIsChecked()) then
		Mod.Settings.StartingCitiesActive = true
		Mod.Settings.NumberOfStartingCities = sliderStartingCities.GetValue()
		if (Mod.Settings.NumberOfStartingCities < 1) then
			Mod.Settings.NumberOfStartingCities = 1
		end
		if (Mod.Settings.NumberOfStartingCities > 10) then
			Mod.Settings.NumberOfStartingCities = 10
		end
	end

	Mod.Settings.CustomSenarioCapitals = -1
	if (capitalsToggle.GetIsChecked()) then
		Mod.Settings.CustomSenarioCapitals = sliderCapitals.GetValue()
		if (Mod.Settings.CustomSenarioCapitals < 0) then
			Mod.Settings.CustomSenarioCapitals = 0
		end
		if (Mod.Settings.CustomSenarioCapitals > 1000) then
			Mod.Settings.CustomSenarioCapitals = 1000
		end

		Mod.Settings.CapitalExtraStartingCities = sliderExtraCityCapitals.GetValue()
		if (Mod.Settings.CapitalExtraStartingCities < 0) then
			Mod.Settings.CustomSenarioCapitals = 0
		end
		if (Mod.Settings.CapitalExtraStartingCities > 100) then
			Mod.Settings.CustomSenarioCapitals = 100
		end
	end

	Mod.Settings.BlockadeBuildCityActive = false
	if (buildCitiesToggle.GetIsChecked()) then
		Mod.Settings.BlockadeBuildCityActive = true
		Mod.Settings.BlockadePower = sliderBlockCard.GetValue()
		if (Mod.Settings.BlockadePower < 1) then
			Mod.Settings.BlockadePower = 1
		end
		if (Mod.Settings.BlockadePower > 10) then
			Mod.Settings.BlockadePower = 10
		end
	end

	Mod.Settings.EMBActive = false
	if (foundNewCitiesToggle.GetIsChecked()) then
		Mod.Settings.EMBActive = true
		Mod.Settings.EMBPower = sliderEMBCard.GetValue()
		if (Mod.Settings.EMBPower < 1) then
			Mod.Settings.EMBPower = 1
		end
		if (Mod.Settings.EMBPower > 10) then
			Mod.Settings.EMBPower = 10
		end
	end

	Mod.Settings.WastlandCities = false
	if (wastelandsToggle.GetIsChecked()) then
		Mod.Settings.WastlandCities = wastelandsToggle.GetIsChecked()
	end

	Mod.Settings.CommerceFreeCityDeploy = false
	if (commerceFreeDeployCityToggle.GetIsChecked()) then
		Mod.Settings.CommerceFreeCityDeploy = commerceFreeDeployCityToggle.GetIsChecked()
	end
	Mod.Settings.CityDeployOnly = false

	if (CityDeployOnlyToggle.GetIsChecked()) then
		Mod.Settings.CityDeployOnly = true
	end
end
