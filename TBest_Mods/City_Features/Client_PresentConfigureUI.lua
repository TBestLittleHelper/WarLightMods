function Client_PresentConfigureUI(rootParent)
	local initialDefPower = Mod.Settings.DefPower;
	local initialBombcardPower = Mod.Settings.BombcardPower;
	local initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals;
	
	if initialDefPower == nil then initialDefPower = 25; end
    if initialBombcardPower == nil then initialBombcardPower = 2; end
	if initialCustomSenarioCapitals == nil then initialCustomSenarioCapitals = 10; end
	
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);
	
	local vert1 = UI.CreateHorizontalLayoutGroup(mainContainer);
	UI.CreateLabel(vert1).SetText('Percantage bonus for each city on a territory is: ');
	numberInputField1 = UI.CreateNumberInputField(vert1)
		.SetSliderMinValue(10)
		.SetSliderMaxValue(50)
		.SetValue(initialDefPower);

	local vert2 = UI.CreateHorizontalLayoutGroup(mainContainer);	
	UI.CreateLabel(vert2).SetText('Bomb card reduces a city by :');
	numberInputField2 = UI.CreateNumberInputField(vert2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(5)
		.SetValue(initialBombcardPower);
	
	local vert3 = UI.CreateHorizontalLayoutGroup(mainContainer);	
	UI.CreateLabel(vert3).SetText('Capitals starts with this many arimes:');
	numberInputField3 = UI.CreateNumberInputField(vert3)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(15)
		.SetValue(initialCustomSenarioCapitals);	
end