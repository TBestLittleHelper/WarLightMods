function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.PickablePercent
	if initialValue == nil then
		initialValue = 50
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)

	local sliderPickablePercent = UI.CreateHorizontalLayoutGroup(mainContainer)
	UI.CreateLabel(sliderPickablePercent).SetText("Percent of pickable territories availible")
	numberInputField =
		UI.CreateNumberInputField(sliderPickablePercent).SetSliderMinValue(1).SetSliderMaxValue(99).SetValue(initialValue)
end
