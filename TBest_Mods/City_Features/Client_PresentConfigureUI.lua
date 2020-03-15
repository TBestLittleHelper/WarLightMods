function Client_PresentConfigureUI(rootParent)
	showInstructions = false;
	
	initialCityWalls = Mod.Settings.CityWallsActive;
	initialDefPower = Mod.Settings.DefPower;
	
	initialBombcardActive = Mod.Settings.BombcardActive;	
	initialBombcardPower = Mod.Settings.BombcardPower;
	
	initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals;
	
	initialCitiesActive = Mod.Settings.StartingCitiesActive;
	initialWastlandCities = Mod.Settings.WastlandsCities;
	initialCommerceFree = Mod.Settings.CommerceFreeCityDeploy;

	
	initialBuildCityActive = Mod.Settings.CapitalsActive;		
	initialBlockCityActive = Mod.Settings.BlockadeBuildCityActive;
	
	if initialDefPower == nil then initialDefPower = 25; end
    if initialBombcardPower == nil then initialBombcardPower = 2; end
	if initialCustomSenarioCapitals == nil then initialCustomSenarioCapitals = 10; end
	
	if initialCityWalls == nil then initialCityWalls = true; end
	if initialCitiesActive == nil then initialCitiesActive = true; end
	if initialBombcardActive == nil then initialBombcardActive = true; end
	if initialBuildCityActive == nil then initialBuildCityActive = true; end
	if initialWastlandCities == nil then initialWastlandCities = true; end
	if initialBlockCityActive == nil then initialBlockCityActive = true; end
	if initialCommerceFree == nil then initialCommerceFree = true; end
	
	
	horzlist = {};
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	showWallOfTextToggle= UI.CreateCheckBox(horzlist[0]).SetText('Show Advanced Instructions').SetIsChecked(showInstructions).SetOnValueChanged(ShowAdvancedInstructions);	
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[4] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent);

	
	
	horzlist[10] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[20] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[30] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[40] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[50] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[60] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[70] = UI.CreateHorizontalLayoutGroup(rootParent);

	--TODO reorder the settings?
	
	
	cityWallsToggle= UI.CreateCheckBox(horzlist[10]).SetText('City Walls').SetIsChecked(initialCityWalls).SetOnValueChanged(ShowCitySettings);
	horzlist[11] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[12] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	bombCardToggle= UI.CreateCheckBox(horzlist[20]).SetText('Bomb card attack on cities').SetIsChecked(initialBombcardActive).SetOnValueChanged(ShowBombSettings);
	horzlist[21] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[22] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	capitalsToggle= UI.CreateCheckBox(horzlist[30]).SetText('Capitals').SetIsChecked(initialBuildCityActive).SetOnValueChanged(ShowCapitalsSettings);
	horzlist[31] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[32] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	buildCitiesToggle= UI.CreateCheckBox(horzlist[40]).SetText('Use cards to build a city').SetIsChecked(initialBuildCityActive).SetOnValueChanged(ShowBlockSettings);
	horzlist[41] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[42] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	wastelandsToggle= UI.CreateCheckBox(horzlist[50]).SetText('Wastlands starts with a neutral city').SetIsChecked(initialWastlandCities);
	startingCitiesToggle= UI.CreateCheckBox(horzlist[60]).SetText("Distributed territories start with a city").SetIsChecked(initialCitiesActive);
	commerceFreeDeployCityToggle= UI.CreateCheckBox(horzlist[70]).SetText("In commerce game, deploying in a city will refund your gold for the next turn").SetIsChecked(initialCommerceFree);
	
	
	if (showInstructions == true) then
		ShowAdvancedInstructions();
	end
	
	if (initialCityWalls == true) then
		ShowCitySettings();
	end
	
	if (initialBombcardActive == true) then
		ShowBombSettings();
	end
	
	if (initialBuildCityActive == true) then
		ShowCapitalsSettings();
	end
	
	if (initialBlockCityActive == true) then
		ShowBlockSettings();
	end
end


function ShowAdvancedInstructions()
	if(text1 ~= nil) then
		UI.Destroy(text1);
		UI.Destroy(text2);
		UI.Destroy(text3);
		UI.Destroy(text4);
		UI.Destroy(text5);

		text1 = nil;
		else
		text1 = UI.CreateLabel(horzlist[1]).SetText('City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, so for example 1 city gives 50% extra defence and 2 cities gives 100%');
		text2 = UI.CreateLabel(horzlist[2]).SetText('Bomb card can reduce the number of cities on a territory. You can custimize the strength. A city of any size will protect the armies in that city from the bomb card! If enabled you can use blockade and EMB cards to build on an exsisting city');	
		text3 = UI.CreateLabel(horzlist[3]).SetText('If a starting territory has a set number of armies at the begining of a game, they will start with a large city. This is intended to be used in combination with Custom Senario, so that a game creator can make some key territories start with cities.');
		text4 = UI.CreateLabel(horzlist[4]).SetText("Hope you enjoy and don't hesitate to make suggestions for imporovments to me");
		text5 = UI.CreateLabel(horzlist[5]).SetText('If you run into any issues please contact me, TBest. [Click Mod Info, open my profle and send me a mail');

	end
end	


function ShowCitySettings()
	if(textDefBonus ~= nil) then
		UI.Destroy(textDefBonus);
		UI.Destroy(sliderDefBonus);
		
		textDefBonus = nil;
		else
		textDefBonus = UI.CreateLabel(horzlist[11]).SetText('Percantage bonus for each city');
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

function ShowBlockSettings()
	if(textBlockCard ~= nil) then	
		UI.Destroy(textBlockCard);
		UI.Destroy(sliderBlockCard);
		
		textBlockCard = nil;
		else
		textBlockCard= UI.CreateLabel(horzlist[41]).SetText('Blockade and EMB card builds a city by');
		sliderBlockCard = UI.CreateNumberInputField(horzlist[42]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialBombcardPower);
	end
end	