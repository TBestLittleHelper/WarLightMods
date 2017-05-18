
function Client_PresentConfigureUI(rootParent)
	local turnsInitial = Mod.Settings.NumTurns;
	local timeToWarInitial = Mod.Settings.TimeToWar;
	
	if turnsInitial == nil then turnsInitial = 10; end
    	if timeToWarInitial == nil then timeToWarInitial = 0; end
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText("This mod will only be active until turn");
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(50)
		.SetSliderMaxValue(100)
		.SetValue(turnsInitial);
	
	local horz1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz1).SetText("Turns from decering war, until you can attack");
	timeToWarInitial = UI.CreateNumberInputField(horz1)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(5)
		.SetValue(timeToWarInitial);

end
