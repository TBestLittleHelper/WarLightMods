function Client_PresentConfigureUI(rootParent)
	 showSettings = false;
	
	--TODO compere with mod settings here.
	 initialDefPower = Mod.Settings.DefPower;
	 initialBombcardPower = Mod.Settings.BombcardPower;
	 initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals;
	
	 initialBombcardActive = Mod.Settings.BombcardActive;
	 initialCitiesActive = Mod.Settings.StartingCitiesActive;
	 initialBuildCityActive = Mod.Settings.BlockadeBuildCityActive;		
	
	if initialDefPower == nil then initialDefPower = 25; end
    if initialBombcardPower == nil then initialBombcardPower = 2; end
	if initialCustomSenarioCapitals == nil then initialCustomSenarioCapitals = 10; end
	
	if initialCitiesActive == nil then initialCitiesActive = true; end
	if initialBombcardActive == nil then initialBombcardActive = true; end
	if initialBuildCityActive == nil then initialBuildCityActive = true; end
			
	horzlist = {};
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	showSettingsToggle= UI.CreateCheckBox(horzlist[0]).SetText('Change Advanced Settings').SetIsChecked(showSettings).SetOnValueChanged(ShowAdvancedSettingsFunction);	
	
	defPowerToggle= UI.CreateCheckBox(horzlist[1]).SetText('City Walls').SetIsChecked(initialCitiesActive)
	bombCardToggle= UI.CreateCheckBox(horzlist[2]).SetText('Bomb card destory cities').SetIsChecked(initialBombcardActive)
	capitalsToggle= UI.CreateCheckBox(horzlist[3]).SetText('Capitals').SetIsChecked(initialBuildCityActive)

	
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[6] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[7] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[8] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[9] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[10] = UI.CreateHorizontalLayoutGroup(rootParent);

	
	if (showSettings == true) then
		ShowAdvancedSettingsFunction();
	end
end


function ShowAdvancedSettingsFunction()
	if(textDefBonus ~= nil) then
		UI.Destroy(textDefBonus);
		UI.Destroy(sliderDefBonus);
	
		UI.Destroy(textBombCard);
		UI.Destroy(sliderBombCard);

		UI.Destroy(textCapitals);
		UI.Destroy(sliderCapitals);
		
		textDefBonus = nil;
		else
		textDefBonus = UI.CreateLabel(horzlist[5]).SetText('Percantage bonus for each city on a territory is');
		sliderDefBonus = UI.CreateNumberInputField(horzlist[6]).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(initialDefPower);
		
		textBombCard= UI.CreateLabel(horzlist[7]).SetText('Bomb card reduces a city by');
		sliderBombCard = UI.CreateNumberInputField(horzlist[8]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialBombcardPower);
		
		textCapitals= UI.CreateLabel(horzlist[9]).SetText('Capitals starts with this many arimes');
		sliderCapitals = UI.CreateNumberInputField(horzlist[10]).SetSliderMinValue(0).SetSliderMaxValue(15).SetValue(initialCustomSenarioCapitals);
	end
end	
