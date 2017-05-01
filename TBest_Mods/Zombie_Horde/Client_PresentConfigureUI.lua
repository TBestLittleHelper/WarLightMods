
function Client_PresentConfigureUI(rootParent)
	local initialValue1 = Mod.Settings.ExtraArmies;
	if initialValue1 == nil then initialValue1 = 5; end
    	if initialZombieID == nil then initialZombieID = 69603; end

    local horz1 = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horz1).SetText('Extra Armies for Zombie in EACH territory per Turn:');
    numberInputField1 = UI.CreateNumberInputField(horz1)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(10)
		.SetValue(initialValue1);
	
	UI.CreateLabel(horz1).SetText('The PlayerID of the Zombie:');
    zombieInputField = UI.CreateNumberInputField(horz1)
		.SetValue(initialValue1);

end
