
function Client_PresentConfigureUI(rootParent)
	local initialZombieStrength = Mod.Settings.ZombieStrength;
	local initialZombieStarts = Mod.Settings.ZombieStarts;
	local initialZombieTeam = Mod.Settings.ZombieTeam;
	
	if initialZombieStrength == nil then initialZombieStrength = 1000; end
	if initialZombieStarts == nil then initialZombieStarts = 4; end
	if initialZombieTeam == nil then initialZombieTeam = 1; end
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);

	local zombiesStats = UI.CreateHorizontalLayoutGroup(mainContainer);
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(mainContainer).SetText("By default the Zoombie(s) starts with 4 stacks of 1000");	

	UI.CreateLabel(zombiesStats).SetText('Stacks');
    numberInputZombieStarts = UI.CreateNumberInputField(zombiesStats)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(initialZombieStarts);
	
	UI.CreateLabel(zombiesStats).SetText('Armies');
    numberInputField = UI.CreateNumberInputField(zombiesStats)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(5000)
		.SetValue(initialZombieStrength);
		
	local zombiesSettings = UI.CreateHorizontalLayoutGroup(mainContainer);
		
	UI.CreateLabel(zombiesSettings).SetText('Number of Zombies');
    numberInputZombieTeam = UI.CreateNumberInputField(zombiesSettings)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(40)
		.SetValue(initialZombieTeam);
	
	UI.CreateLabel(mainContainer).SetText("The Zoombie 'Team' is the number of AI's that will be turned into zombies. Note that you MUST invite the AI's. You can have normal AI's.");
	UI.CreateLabel(mainContainer).SetText("The AI's that are on Team A are turned into Zombies first. Then Team B etc.");

end
