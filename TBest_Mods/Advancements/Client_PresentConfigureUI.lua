function Client_PresentConfigureUI(rootParent)
	local initialAdvancement = Mod.Settings.Advancement
	local initialGameSpeed = Mod.Settings.GameSpeed

	if initialGameSpeed == nil then
		initialGameSpeed = 3
	end

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
	if initialAdvancement.Diplomacy == nil then
		initialAdvancement.Diplomacy = true
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)
	UI.CreateLabel(mainContainer).SetText(
		"Select the game speed. A higher value gives a faster game. Most games will work best on the normal (3) game speed. On a big map with 40 players, a game speed of 1 is advisable. "
	)
	GameSpeedInput =
		UI.CreateNumberInputField(mainContainer).SetSliderMinValue(1).SetSliderMaxValue(6).SetValue(initialGameSpeed)

	UI.CreateLabel(mainContainer).SetText("Select the Advancements that you want to incude")
	TechnologyCheckBox = UI.CreateCheckBox(mainContainer).SetText("Technology").SetIsChecked(initialAdvancement.Technology)
	MilitaryCheckBox = UI.CreateCheckBox(mainContainer).SetText("Military").SetIsChecked(initialAdvancement.Military)
	CultureCheckBox = UI.CreateCheckBox(mainContainer).SetText("Culture").SetIsChecked(initialAdvancement.Culture)
	DiplomacyheckBox = UI.CreateCheckBox(mainContainer).SetText("Diplomacy").SetIsChecked(initialAdvancement.Culture)
end
