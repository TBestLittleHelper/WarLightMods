
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.Amount;
	local initialNegatives = Mod.Settings.ChangeNegavtive;
	if initialValue == nil then initialValue = -1; end
	if initialNegatives == nil then initialNegatives = true; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText('Bonuses = #numberOfTerritories +/- n');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(-10)
		.SetSliderMaxValue(10)
		.SetValue(initialValue);

	UI.CreateLabel(vert).SetText("Normally, negative bonuses WILL be modified.  However, you can uncheck the \"Change negative bonuses\" box to preserve them.");

	changeNegative = UI.CreateCheckBox(vert).SetText('Change negative bonuses').SetIsChecked(initialNegatives);

end