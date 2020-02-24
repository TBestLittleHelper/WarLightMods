function Client_SaveConfigureUI(alert)
	
	if defPowerToggle ~= nil then 
		Mod.Settings.BombcardActive = bombCardToggle.GetIsChecked();
	else Mod.Settings.BombcardActive = true end;
	
	if defPowerToggle ~= nil then
    Mod.Settings.StartingCitiesActive = defPowerToggle.GetIsChecked();
	else Mod.Settings.StartingCitiesActive = true end
	
	if capitalsToggle ~= nil then
    Mod.Settings.BlockadeBuildCityActive = capitalsToggle.GetIsChecked();	
	else Mod.Settings.BlockadeBuildCityActive = true end
	
    Mod.Settings.DefPower = sliderDefBonus.GetValue() * 0.01; -- Convert to decimals from percantage
    
	Mod.Settings.BombcardPower = sliderBombCard.GetValue();	
    
	Mod.Settings.CustomSenarioCapitals = sliderCapitals.GetValue();
end

--wastelands starts with city bool