function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.NumPortals
	if initialValue == nil then
		initialValue = 1
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)

	local sliderNumPortals = UI.CreateHorizontalLayoutGroup(mainContainer)
	UI.CreateLabel(sliderNumPortals).SetText("Number of Portals")
	numberInputField =
		UI.CreateNumberInputField(sliderNumPortals).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(initialValue)
end
