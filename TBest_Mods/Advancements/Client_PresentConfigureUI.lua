function Client_PresentConfigureUI(rootParent)
	local initialAdvancement = Mod.Settings.Advancement
	if initialAdvancement == nil then
		initialAdvancement = {}
	end
	if initialAdvancement.Technology == nil then
		initialAdvancement.Technology = true
	end
	if initialAdvancement.Military == nil then
		initialAdvancement.Military = true
	end
	if initialAdvancement.Culture == nil then
		initialAdvancement.Culture = true
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)
	UI.CreateLabel(mainContainer).SetText("Select the Advancements trees to be incuded")
	TechnologyCheckBox = UI.CreateCheckBox(mainContainer).SetText("Technology").SetIsChecked(initialAdvancement.Technology)
	MilitaryCheckBox = UI.CreateCheckBox(mainContainer).SetText("Military").SetIsChecked(initialAdvancement.Military)
	CultureCheckBox = UI.CreateCheckBox(mainContainer).SetText("Culture").SetIsChecked(initialAdvancement.Culture)
end
