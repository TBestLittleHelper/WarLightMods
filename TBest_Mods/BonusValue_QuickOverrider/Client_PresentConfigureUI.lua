
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.Amount;
	local initialNegatives = Mod.Settings.ChangeNegavtive;
	local initialMultiply = Mod.Settings.Multiply;
	local initialBonusValue = Mod.Settings.ChangeDefaultBonus;
	local initialValueRandom = Mod.Settings.RandomFactor;
	local initialChangeSuperBonuses = Mod.Settings.ChangeSuperBonuses;
	local initialDefineSuperBonus = Mod.Settings.SuperBonus;
	local initialSmalSuperBonuses = Mod.Settings.SmalSuperBonuses
	
	if initialValue == nil then initialValue = -1; end
	if initialNegatives == nil then initialNegatives = false; end
	if initialMultiply == nil then initialMultiply = false; end
 	if initialBonusValue == nil then initialBonusValue = false; end
	if initialValueRandom == nil then initialValueRandom = 0; end
	if initialChangeSuperBonuses == nil then initialChangeSuperBonuses = false; end
	if initialDefineSuperBonus == nil then initialDefineSuperBonus = 15; end
	if initialSmalSuperBonuses == nil then initialSmalSuperBonuses = false; end
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);
	
	local vert = UI.CreateVerticalLayoutGroup(mainContainer);
	UI.CreateLabel(vert).SetText("By default the formula used is BonusValue = numberOfTerritories + N ");	
	UI.CreateLabel(vert).SetText("X randomely changes each bonus value AFTER the formula by any number from - X to + X");
	UI.CreateLabel(vert).SetText("T defines the minimum territories for a superbonus. By default superbonuses are NOT changed.");	
        	
	local slidersNXT = UI.CreateHorizontalLayoutGroup(mainContainer);
	UI.CreateLabel(slidersNXT).SetText('N: ');
    numberInputField = UI.CreateNumberInputField(slidersNXT)
		.SetSliderMinValue(-5)
		.SetSliderMaxValue(5)
		.SetValue(initialValue);
		
	UI.CreateLabel(slidersNXT).SetText('X: ');
    numberInputFieldRandomFactor = UI.CreateNumberInputField(slidersNXT)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(10)
		.SetValue(initialValueRandom);
		
	UI.CreateLabel(slidersNXT).SetText('T: ');
    numberInputFieldDefineSuperBonus = UI.CreateNumberInputField(slidersNXT)
		.SetSliderMinValue(10)
		.SetSliderMaxValue(20)
		.SetValue(initialDefineSuperBonus);
		
	
	local checkBoxses = UI.CreateVerticalLayoutGroup(mainContainer);
	changeMultiply = UI.CreateCheckBox(checkBoxses).SetText('Multiplier').SetIsChecked(initialMultiply);
	UI.CreateLabel(checkBoxses).SetText("Make N work as a multplier. The function is then BonusValue = numberOfTerritories * N");
	
	changeDefaultBonus = UI.CreateCheckBox(checkBoxses).SetText('Default Bonuse Value').SetIsChecked(initialBonusValue);
	UI.CreateLabel(checkBoxses).SetText("Use the default bonuse values. If this is checked, then the multplier uses BonusValue = defaultBonusValue * N. While the default formula is no longer using numberOfTerritories. Instead N is now a flat change, BonusValue = defaultBonusValue + N.");
	
	local checkBoxsesSuperBonuses = UI.CreateHorizontalLayoutGroup(checkBoxses);
	ChangeSuperBonuses = UI.CreateCheckBox(checkBoxsesSuperBonuses).SetText('Change Superbonuses').SetIsChecked(initialChangeSuperBonuses);
	SmalSuperBonuses = UI.CreateCheckBox(checkBoxsesSuperBonuses).SetText('Small Superbonuses').SetIsChecked(initialsmallSuperBonuses);
	UI.CreateLabel(checkBoxses).SetText("Normally, superbonuses will NOT be modified.");
	UI.CreateLabel(checkBoxses).SetText("Small Superbonuses sets them to 1, IF Change Superbonuses is also cheked.");

	changeNegative = UI.CreateCheckBox(checkBoxses).SetText('Change Negative Bonuses').SetIsChecked(initialNegatives);
	UI.CreateLabel(checkBoxses).SetText("Normally, negative and 0 bonuses will NOT be modified.");

end
