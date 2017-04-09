
function Client_SaveConfigureUI(alert)
	Mod.Settings.Amount = numberInputField.GetValue();
 	Mod.Settings.ChangeNegavtive = changeNegative.GetIsChecked();
	Mod.Settings.Multiply = changeMultiply.GetIsChecked();
	Mod.Settings.ChangeDefaultBonus = changeDefaultBonus.GetIsChecked();
end
