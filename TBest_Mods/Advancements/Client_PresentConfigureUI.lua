function Client_PresentConfigureUI(rootParent)
	local initialAdvancments = Mod.Settings.Advancments
	if initialAdvancments == nil then
		initialAdvancments = {}
	end
	if initialAdvancments.Technology == nil then
		initialAdvancments.Technology = true
	end
	if initialAdvancments.Military == nil then
		initialAdvancments.Military = true
	end
	if initialAdvancments.Culture == nil then
		initialAdvancments.Culture = true
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)
	UI.CreateLabel(mainContainer).SetText("Select the Advancments trees to be incuded")
	TechnologyCheckBox = UI.CreateCheckBox(mainContainer).SetText("Technology").SetIsChecked(initialAdvancments.Technology)
	MilitaryCheckBox = UI.CreateCheckBox(mainContainer).SetText("Military").SetIsChecked(initialAdvancments.Military)
	CultureCheckBox = UI.CreateCheckBox(mainContainer).SetText("Culture").SetIsChecked(initialAdvancments.Culture)
end
