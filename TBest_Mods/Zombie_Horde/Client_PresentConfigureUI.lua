
function Client_PresentConfigureUI(rootParent)
	local initialZombieStrength = Mod.Settings.ZombieStrength;
	local initialZombieStarts = Mod.Settings.ZombieStarts;
	local initialZombieTeam = Mod.Settings.ZombieTeam;
	local initialStartingBonuses = Mod.Settings.StartingBonuses;
	
	if initialZombieStrength == nil then initialZombieStrength = 200; end
	if initialZombieStarts == nil then initialZombieStarts = 100; end
	if initialZombieTeam == nil then initialZombieTeam = 1; end
	if initialStartingBonuses == nil then initialStartingBonuses = 1; end
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(mainContainer).SetText("See Mod Info for explanation of what a Zombie game is.");

	local zombiesStats = UI.CreateHorizontalLayoutGroup(mainContainer);
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(mainContainer).SetText("By default the Zoombie(s) starts with one random bonus filled with stack(s) of 1000");	

	UI.CreateLabel(zombiesStats).SetText('Bonus Income');
    numberInputZombieStarts = UI.CreateNumberInputField(zombiesStats)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(initialZombieStarts);
	
	UI.CreateLabel(zombiesStats).SetText('Stacks size');
    numberInputField = UI.CreateNumberInputField(zombiesStats)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(500)
		.SetValue(initialZombieStrength);
		
	local zombiesSettings = UI.CreateHorizontalLayoutGroup(mainContainer);
		
	UI.CreateLabel(zombiesSettings).SetText('Number of Zombies');
    numberInputZombieTeam = UI.CreateNumberInputField(zombiesSettings)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(initialZombieTeam);
		
	UI.CreateLabel(zombiesSettings).SetText('Number of starting Bonuses');
    numberInputStartingBonuses = UI.CreateNumberInputField(zombiesSettings)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(initialZombieTeam);
	
	UI.CreateLabel(mainContainer).SetText("The number of AI's that will be turned into zombies. Note that you MUST invite the AI's. You can have non-zombie AI's by having extra AI's in game");
	UI.CreateLabel(mainContainer).SetText("The AI's that are on Team A are turned into Zombies first. Then Team B etc.");

end
