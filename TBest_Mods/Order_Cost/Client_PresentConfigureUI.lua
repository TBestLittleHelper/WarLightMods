function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.FreeOrders
	if initialValue == nil then
		initialValue = 3
	end

	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent)

	local sliderFreeOrders = UI.CreateHorizontalLayoutGroup(mainContainer)
	UI.CreateLabel(sliderFreeOrders).SetText("Number of free orders")
	numberInputField =
		UI.CreateNumberInputField(sliderFreeOrders).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(initialValue)
end
