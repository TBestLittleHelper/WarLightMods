
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.Amount;
	local initialNegatives = Mod.Settings.ChangeNegavtive;
	local initialMultiply = Mod.Settings.ChangeMultiply;
	local initialBonusValue = Mod.Settings.ChangeDefaultBonus;
	local initialValueRandom = Mod.Settings.RandomFactor;
	
	if initialValue == nil then initialValue = -1; end
	if initialNegatives == nil then initialNegatives = true; end
	if initialMultiply == nil then initialMultiply = false; end
 	if initialBonusValue == nil then initialBonusValue = false; end
	if initialValueRandom == nil then initialValueRandom = 0; end
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText("By default the formula used is BonusValue = numberOfTerritories + N ");	
	UI.CreateLabel(vert).SetText("X randomely changes each bonus value AFTER the formula by any number from - X to + X");

    local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText('N: ');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(-5)
		.SetSliderMaxValue(5)
		.SetValue(initialValue);
		
	UI.CreateLabel(horz).SetText('X: ');
    numberInputFieldRandomFactor = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(10)
		.SetValue(initialValueRandom);

	changeNegative = UI.CreateCheckBox(vert).SetText('Change negative bonuses').SetIsChecked(initialNegatives);
	UI.CreateLabel(vert).SetText("Normally, negative bonuses WILL be modified.  However, you can uncheck the \"Change negative bonuses\" box to preserve bonuses that are 0, or lower.");
	
	changeMultiply = UI.CreateCheckBox(vert).SetText('Multiplier').SetIsChecked(initialMultiply);
	UI.CreateLabel(vert).SetText("Make N work as a multplier. The function is then BonusValue = numberOfTerritories * N");
	
	changeDefaultBonus = UI.CreateCheckBox(vert).SetText('Default bonuse value').SetIsChecked(initialBonusValue);
	UI.CreateLabel(vert).SetText("Use the default bonuse values. If this is checked, then the multplier uses BonusValue = defaultBonusValue * N. While the default formula is no longer using numberOfTerritories. Instead N is now a flat change, BonusValue = defaultBonusValue + N.");
	
end
