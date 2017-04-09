
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.Amount;
	local initialNegatives = Mod.Settings.ChangeNegavtive;
	local initialMultiply = Mod.Settings.ChangeMultiply;
	if initialValue == nil then initialValue = -1; end
	if initialNegatives == nil then initialNegatives = true; end
	if initialMultiply == nil then initialMultiply = false; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText('Bonuses = #numberOfTerritories +/- N');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(-10)
		.SetSliderMaxValue(10)
		.SetValue(initialValue);

	UI.CreateLabel(vert).SetText("Normally, negative bonuses WILL be modified.  However, you can uncheck the \"Change negative bonuses\" box to preserve them.");
	changeNegative = UI.CreateCheckBox(vert).SetText('Change negative bonuses').SetIsChecked(initialNegatives);
	
	UI.CreateLabel(vert).SetText("Make N work as a multplier. The function is then BonusValue = #numberOfTerritories * N");
	changeMultiply = UI.CreateCheckBox(vert).SetText('Multiplier').SetIsChecked(ChangeMultiply);

end
