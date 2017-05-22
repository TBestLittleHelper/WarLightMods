--TODO remove Slider from ZombieID

function Client_PresentConfigureUI(rootParent)
	local initialValue1 = Mod.Settings.ExtraArmies;
	local initialZombieID = Mod.Settings.ZombieID;
	local initialRandomZombie = Mod.Settings.RandomZombie;
	local initialZombieWin = Mod.Settings.ZombieWin;
	
	if initialValue1 == nil then initialValue1 = 5; end
    	if initialZombieID == nil then initialZombieID = 69603; end
	if initialRandomZombie == nil then initialRandomZombie = false; end
	if initialZombieWin == nil then initialZombieWin = false; end
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);
	
	local vert1 = UI.CreateHorizontalLayoutGroup(mainContainer);
	UI.CreateLabel(vert1).SetText('Extra Armies for Zombie in EACH territory per Turn:');
	numberInputField1 = UI.CreateNumberInputField(vert1)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(10)
		.SetValue(initialValue1);

	local vert2 = UI.CreateHorizontalLayoutGroup(mainContainer);	
	UI.CreateLabel(vert2).SetText('The PlayerID of the Zombie:');
	zombieInputField = UI.CreateNumberInputField(vert2)
		.SetValue(initialZombieID);
	
	local vert3 = UI.CreateHorizontalLayoutGroup(mainContainer);
	UI.CreateLabel(vert3).SetText('Check this and a random player is turned into a Zombie');
	local checkBoxses = UI.CreateVerticalLayoutGroup(mainContainer);
	RandomZombieBox = UI.CreateCheckBox(checkBoxses).SetText('RandomZombie').SetIsChecked(initialRandomZombie);
	
	local vert4 = UI.CreateHorizontalLayoutGroup(mainContainer);
	UI.CreateLabel(vert4).SetText('Check this and the Zombie can win the game');
	local checkBoxses = UI.CreateVerticalLayoutGroup(mainContainer);
	ZombieWinBox = UI.CreateCheckBox(checkBoxses).SetText('ZombieWIn').SetIsChecked(initialZombieWin);
	
end
