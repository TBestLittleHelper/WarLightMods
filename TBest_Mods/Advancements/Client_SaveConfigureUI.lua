function Client_SaveConfigureUI(alert)
	Mod.Settings.GameSpeed = GameSpeedInput.GetValue()
	if (Mod.Settings.GameSpeed < 0) then
		Mod.Settings.GameSpeed = 0
	elseif (Mod.Settings.GameSpeed > 6) then
		Mod.Settings.GameSpeed = 6
	end

	Mod.Settings.Advancement = {
		Technology = TechnologyCheckBox.GetIsChecked(),
		Military = MilitaryCheckBox.GetIsChecked(),
		Culture = CultureCheckBox.GetIsChecked(),
		Diplomacy = DiplomacyheckBox.GetIsChecked()
	}
	if (Mod.Settings.Advancement == nil) then
		alert("You need to enable at least one advancement")
	end
end
