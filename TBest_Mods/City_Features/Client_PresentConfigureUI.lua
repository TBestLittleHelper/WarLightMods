function Client_PresentConfigureUI(rootParent)
	showInstructions = false;
	
	initialDefPower = Mod.Settings.DefPower;
	initialBombcardPower = Mod.Settings.BombcardPower;
	initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals;
	
	initialBombcardActive = Mod.Settings.BombcardActive;
	initialCitiesActive = Mod.Settings.StartingCitiesActive;
	initialBuildCityActive = Mod.Settings.BlockadeBuildCityActive;		
	
	if initialDefPower == nil then initialDefPower = 25; end
    if initialBombcardPower == nil then initialBombcardPower = 2; end
	if initialCustomSenarioCapitals == nil then initialCustomSenarioCapitals = 10; end
	
	if initialCitiesActive == nil then initialCitiesActive = true; end
	if initialBombcardActive == nil then initialBombcardActive = true; end
	if initialBuildCityActive == nil then initialBuildCityActive = true; end
	
	horzlist = {};
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[10] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[20] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[30] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	showWallOfTextToggle= UI.CreateCheckBox(horzlist[0]).SetText('Show Advanced Instructions').SetIsChecked(showInstructions).SetOnValueChanged(ShowAdvancedInstructions);	
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[4] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	defPowerToggle= UI.CreateCheckBox(horzlist[10]).SetText('City Walls').SetIsChecked(initialCitiesActive).SetOnValueChanged(ShowCitySettings);
	horzlist[11] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[12] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	
	
	bombCardToggle= UI.CreateCheckBox(horzlist[20]).SetText('Bomb card destory cities').SetIsChecked(initialBombcardActive).SetOnValueChanged(ShowBombSettings);
	horzlist[21] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[22] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	
	capitalsToggle= UI.CreateCheckBox(horzlist[30]).SetText('Capitals').SetIsChecked(initialBuildCityActive).SetOnValueChanged(ShowCapitalsSettings);
	horzlist[31] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[32] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	
	
	if (showInstructions == true) then
		ShowAdvancedInstructions();
	end
	
	if (initialCitiesActive == true) then
		ShowCitySettings();
	end
	
	if (initialBombcardActive == true) then
		ShowBombSettings();
	end
	
	if (initialBuildCityActive == true) then
		ShowCapitalsSettings();
	end
end


function ShowAdvancedInstructions()
	if(text1 ~= nil) then
		UI.Destroy(text1);
		UI.Destroy(text2);
		UI.Destroy(text3);
		UI.Destroy(text4);
		
		text1 = nil;
		else
		text1 = UI.CreateLabel(horzlist[1]).SetText('City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, so for example 1 city gives 50% extra defence and 2 cities gives 100%');
		text2 = UI.CreateLabel(horzlist[2]).SetText('Bomb card can reduce the number of cities on a territory. You can custimize the strength. A city of any size will protect the armies in that city from the bomb card!');	
		text3 = UI.CreateLabel(horzlist[3]).SetText('If a starting territory has a set number of armies at the begining of a game, they will start with a large city. This is intended to be used in combination with Custom Senario, so that a game creator can make some key territories start with cities.');
		text4 = UI.CreateLabel(horzlist[4]).SetText('If you run into any issues please contact me, TBest. [Click Mod Info, open my profle and send me a mail]');
		
	end
end	


function ShowCitySettings()
	if(textDefBonus ~= nil) then
		UI.Destroy(textDefBonus);
		UI.Destroy(sliderDefBonus);
		
		textDefBonus = nil;
		else
		textDefBonus = UI.CreateLabel(horzlist[11]).SetText('Percantage bonus for each city on a territory is');
		sliderDefBonus = UI.CreateNumberInputField(horzlist[12]).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(initialDefPower);
	end
end	

function ShowBombSettings()
	if(textBombCard ~= nil) then	
		UI.Destroy(textBombCard);
		UI.Destroy(sliderBombCard);
		
		textBombCard = nil;
		else
		textBombCard= UI.CreateLabel(horzlist[21]).SetText('Bomb card reduces a city by');
		sliderBombCard = UI.CreateNumberInputField(horzlist[22]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialBombcardPower);
	end
end	

function ShowCapitalsSettings()
	if(textCapitals ~= nil) then
		UI.Destroy(textCapitals);
		UI.Destroy(sliderCapitals);
		
		textCapitals = nil;
		else
		
		textCapitals= UI.CreateLabel(horzlist[31]).SetText('Capitals starts with this many arimes');
		sliderCapitals = UI.CreateNumberInputField(horzlist[32]).SetSliderMinValue(0).SetSliderMaxValue(15).SetValue(initialCustomSenarioCapitals);
	end
end	
