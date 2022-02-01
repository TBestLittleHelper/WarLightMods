require("PresentConfigureModBetterCities")

function Client_PresentConfigureUI(rootParent)
	ModGiftGoldEnabled = Mod.Settings.ModGiftGoldEnabled
	ModBetterCitiesEnabled = Mod.Settings.ModBetterCitiesEnabled
	local turnsInitial = Mod.Settings.SafeStartNumTurns

	if ModGiftGoldEnabled == nil then
		ModGiftGoldEnabled = false
	end
	if ModBetterCitiesEnabled == nil then
		ModBetterCitiesEnabled = false
	end
	if SafeStartEnabled == nil then
		SafeStartEnabled = false
	end

	UI.CreateLabel(rootParent).SetText("Turn on/off major individual parts of the modpack.")

	horzlist = {}
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[4] = UI.CreateVerticalLayoutGroup(rootParent) --Used for BetterCities Mod
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[6] = UI.CreateHorizontalLayoutGroup(rootParent)

	--Safe Start
	if turnsInitial == nil then
		turnsInitial = 0
	end
	local horz = UI.CreateHorizontalLayoutGroup(horzlist[6])
	UI.CreateLabel(horz).SetText("Safe Start lasts for this many turns")
	SafeStartNumberInputField =
		UI.CreateNumberInputField(horz).SetSliderMinValue(0).SetSliderMaxValue(30).SetValue(turnsInitial)

	--Instructions text
	showOptionsToggle =
		UI.CreateCheckBox(horzlist[0]).SetText("Show Options").SetIsChecked(true).SetOnValueChanged(ShowOptions)
	ShowOptions()
end

function ShowOptions()
	if (GiftGoldCheckBox ~= nil) then
		UI.Destroy(GiftGoldCheckBox)
		UI.Destroy(BetterCitiesCheckBox)
		if (vertlistBetterCities ~= nil) then
			for i = 0, 25, 1 do
				UI.Destroy(vertlistBetterCities[i])
			end
			vertlistBetterCities = nil
		end
		GiftGoldCheckBox = nil
	else
		GiftGoldCheckBox =
			UI.CreateCheckBox(horzlist[1]).SetText("Gift Gold Mod").SetIsChecked(ModGiftGoldEnabled).SetOnValueChanged(
			SaveConfig
		)
		BetterCitiesCheckBox =
			UI.CreateCheckBox(horzlist[3]).SetText("Better Cities").SetIsChecked(ModBetterCitiesEnabled).SetOnValueChanged(
			SaveConfig
		)
		--Call saveconfig to display any child settings
		SaveConfig()
	end
end

function SaveConfig()
	ModGiftGoldEnabled = GiftGoldCheckBox.GetIsChecked()
	ModBetterCitiesEnabled = BetterCitiesCheckBox.GetIsChecked()

	if (ModBetterCitiesEnabled) then
		if (vertlistBetterCities == nil) then
			vertlistBetterCities = {}
			for i = 0, 25, 1 do
				vertlistBetterCities[i] = UI.CreateHorizontalLayoutGroup(horzlist[4])
			end
			PresentModBetterCitiesSettings()
		end
	else
		if (vertlistBetterCities ~= nil) then
			for i = 0, 25, 1 do
				UI.Destroy(vertlistBetterCities[i])
			end
			vertlistBetterCities = nil
		end
	end
end
