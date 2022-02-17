function Client_SaveConfigureUI(alert)
	Mod.Settings.Advancments = {
		Technology = TechnologyCheckBox.GetIsChecked(),
		Military = MilitaryCheckBox.GetIsChecked(),
		Culture = CultureCheckBox.GetIsChecked()
	}
	print(TechnologyCheckBox.GetIsChecked())
	if (Mod.Settings.Advancments == nil) then
		alert("You need to enable at least one advancment")
	end
end
