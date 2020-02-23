function Client_SaveConfigureUI(alert)

	Mod.Settings.BombcardActive = defPowerToggle.GetIsChecked();
    Mod.Settings.StartingCitiesActive = bombCardToggle.GetIsChecked();
    Mod.Settings.BlockadeBuildCityActive = capitalsToggle.GetIsChecked();	
	
    Mod.Settings.DefPower = sliderDefBonus.GetValue() * 0.01; -- Convert to decimals from percantage
    Mod.Settings.BombcardPower = sliderBombCard.GetValue();	
    Mod.Settings.CustomSenarioCapitals = sliderCapitals.GetValue();
end

--wastelands starts with city bool