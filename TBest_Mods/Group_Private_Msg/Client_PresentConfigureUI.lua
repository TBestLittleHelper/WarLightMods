require("PresentConfigureModBetterCities")
require("PresentConfigureModWinCon")

function Client_PresentConfigureUI(rootParent)
	ModGiftGoldEnabled = Mod.Settings.ModGiftGoldEnabled
	ModDiplomacyEnabled = Mod.Settings.ModDiplomacyEnabled
	ModBetterCitiesEnabled = Mod.Settings.ModBetterCitiesEnabled
	ModWinningConditionsEnabled = Mod.Settings.ModWinningConditionsEnabled

	if ModGiftGoldEnabled == nil then
		ModGiftGoldEnabled = false
	end
	if ModDiplomacyEnabled == nil then
		ModDiplomacyEnabled = false
	end
	if ModBetterCitiesEnabled == nil then
		ModBetterCitiesEnabled = false
	end
	if ModWinningConditionsEnabled == nil then
		ModWinningConditionsEnabled = false
	end

	UI.CreateLabel(rootParent).SetText("Turn on/off major individual parts of the modpack.")

	horzlist = {}
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[4] = UI.CreateVerticalLayoutGroup(rootParent) --Used for BetterCities Mod
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent)
	horzlist[6] = UI.CreateVerticalLayoutGroup(rootParent) --Used for WinCon mod


	--Instructions text
	showOptionsToggle =
		UI.CreateCheckBox(horzlist[0]).SetText("Show Options").SetIsChecked(true).SetOnValueChanged(ShowOptions)
	ShowOptions();		
end

function ShowOptions()
	if (GiftGoldCheckBox ~= nil) then
		UI.Destroy(GiftGoldCheckBox)
		UI.Destroy(DiplomacyCheckBox)
		UI.Destroy(BetterCitiesCheckBox)
		if (vertlistBetterCities ~= nil)then
			for i=0,25,1 do UI.Destroy(vertlistBetterCities[i]) end
			vertlistBetterCities = nil;
		end;
		UI.Destroy(WinningConditionsCheckBox)
		if (vertlistWinCon ~= nil)then
			for i=0,25,1 do UI.Destroy(vertlistWinCon[i]) end
			vertlistWinCon = nil;
		end;

		GiftGoldCheckBox = nil
	else
		GiftGoldCheckBox =
			UI.CreateCheckBox(horzlist[1]).SetText("Gift Gold Mod").SetIsChecked(ModGiftGoldEnabled).SetOnValueChanged(
			SaveConfig
		)
		DiplomacyCheckBox =
			UI.CreateCheckBox(horzlist[2]).SetText("Diplomacy Mod").SetIsChecked(ModDiplomacyEnabled).SetOnValueChanged(
			SaveConfig
		)
		BetterCitiesCheckBox =
			UI.CreateCheckBox(horzlist[3]).SetText("Better Cities").SetIsChecked(ModBetterCitiesEnabled).SetOnValueChanged(
			SaveConfig
		)
		WinningConditionsCheckBox =
			UI.CreateCheckBox(horzlist[5]).SetText("Winning Conditions").SetIsChecked(ModWinningConditionsEnabled).SetOnValueChanged(
			SaveConfig
		)

		--Call saveconfig to display any child settings
		SaveConfig();
	end	
end

function SaveConfig()
	ModGiftGoldEnabled = GiftGoldCheckBox.GetIsChecked()
	ModDiplomacyEnabled = DiplomacyCheckBox.GetIsChecked()
	ModBetterCitiesEnabled = BetterCitiesCheckBox.GetIsChecked()
	ModWinningConditionsEnabled = WinningConditionsCheckBox.GetIsChecked()

	if (ModBetterCitiesEnabled) then
		if (vertlistBetterCities == nil)then
			vertlistBetterCities = {}   
			for i=0,25,1 do vertlistBetterCities[i] = UI.CreateHorizontalLayoutGroup(horzlist[4]) end
			PresentModBetterCitiesSettings()
		end
	else
		if (vertlistBetterCities ~= nil)then
			for i=0,25,1 do UI.Destroy(vertlistBetterCities[i]) end
			vertlistBetterCities = nil;
		end;
	end

	if (ModWinningConditionsEnabled) then
		if (vertlistWinCon == nil)then
			vertlistWinCon = {}   
			for i=0,25,1 do vertlistWinCon[i] = UI.CreateHorizontalLayoutGroup(horzlist[6]) end
			PresentModWinConSettings()
		end
	else
		if (vertlistWinCon ~= nil)then
			for i=0,25,1 do UI.Destroy(vertlistWinCon[i]) end
			vertlistWinCon = nil;
		end;
	end
end
