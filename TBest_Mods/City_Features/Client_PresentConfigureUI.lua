function Client_PresentConfigureUI(rootParent)
	showInstructions = false;
	--City def%
	initialCityWalls = Mod.Settings.CityWallsActive;
	if (Mod.Settings.DefPower ~= nil)then
		initialDefPower = Mod.Settings.DefPower * 100; --This number is stored as a decimal. So *100 to show a %
	else initialDefPower = 25; end
	--City growth
	initialCityGrowth = Mod.Settings.CityGrowth;
	initialCityGrowthCap = Mod.Settings.CityGrowthCap;
	initialCityGrowthPower = Mod.Settings.CityGrowthPower;

	--Bomb card
	initialBombcardActive = Mod.Settings.BombcardActive;	
	initialBombcardPower = Mod.Settings.BombcardPower;
	--Capitals
	initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals;
	initialCapitalsToggle = false;
	if (initialCustomSenarioCapitals ~= nil)then
		if (initialCustomSenarioCapitals == -1)then 
			initialCapitalsToggle = false;
		end;
	end;
	initialCapitalExtraCities = Mod.Settings.CapitalExtraStartingCities;
	--Distributed starting cities
	initialCitiesActive = Mod.Settings.StartingCitiesActive;
	initialNumberOfStartingCities = Mod.Settings.NumberOfStartingCities;
	initialWastlandCities = Mod.Settings.WastlandCities;
	--Commerce city deployment
	initialCommerceFree = Mod.Settings.CommerceFreeCityDeploy;
	initialArmyDeployment = Mod.Settings.CityDeployOnly;
	--Block and EMB card
	initialBuildCityActive = Mod.Settings.CapitalsActive;		
	initialBlockCityActive = Mod.Settings.BlockadeBuildCityActive;
	initialBlockadePower = Mod.Settings.BlockadePower;
	initialEMBActive = Mod.Settings.EMBActive;
	initialEMBPower = Mod.Settings.EMBPower;

--Wastlands and capitals are checked always

	if initialCityWalls == nil then initialCityWalls = true; end
	if initialDefPower == nil then initialDefPower = 25; end
	
	if initialCityGrowth == nil then initialCityGrowth = true; end
	if initialCityGrowthCap == nil then initialCityGrowthCap = 10; end
	if initialCityGrowthPower == nil then initialCityGrowthPower = 1; end
	
	if initialBombcardActive == nil then initialBombcardActive = true; end
	if initialBombcardPower == nil then initialBombcardPower = 2; end
	
	if initialCustomSenarioCapitals == nil then initialCustomSenarioCapitals = 10; end
	if initialCapitalExtraCities == nil then initialCapitalExtraCities = 5; end
	
	if initialCitiesActive == nil then initialCitiesActive = true; end
	if initialNumberOfStartingCities == nil then initialNumberOfStartingCities = 1; end
	if initialWastlandCities == nil then initialWastlandCities = true; end

	if initialCommerceFree == nil then initialCommerceFree = true; end
	if initialArmyDeployment == nil then initialArmyDeployment = false; end

	if initialBuildCityActive == nil then initialBuildCityActive = true; end
	if initialBlockCityActive == nil then initialBlockCityActive = true; end
	if initialBlockadePower == nil then initialBlockadePower = 1; end
	if initialEMBActive == nil then initialEMBActive = true; end
	if initialEMBPower == nil then initialEMBPower = 1; end
	
	
	horzlist = {};
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent);
	--Instructions text
	showWallOfTextToggle= UI.CreateCheckBox(horzlist[0]).SetText('Show Advanced Instructions').SetIsChecked(showInstructions).SetOnValueChanged(ShowAdvancedInstructions);	
	horzlist[1] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[4] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	--Options
	horzlist[10] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[15] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[20] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[30] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[40] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[45] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[50] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[60] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[70] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[80] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	cityWallsToggle= UI.CreateCheckBox(horzlist[10]).SetText('City Walls').SetIsChecked(initialCityWalls).SetOnValueChanged(ShowCitySettings);
	horzlist[11] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	cityGrowthToggle= UI.CreateCheckBox(horzlist[15]).SetText('City Growth').SetIsChecked(initialCityGrowth).SetOnValueChanged(ShowGrowthSettings);
	horzlist[16] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	bombCardToggle= UI.CreateCheckBox(horzlist[20]).SetText('Bomb card attack on cities').SetIsChecked(initialBombcardActive).SetOnValueChanged(ShowBombSettings);
	horzlist[21] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	capitalsToggle= UI.CreateCheckBox(horzlist[30]).SetText('Capitals').SetIsChecked(initialCapitalsToggle).SetOnValueChanged(ShowCapitalsSettings);
	horzlist[31] = UI.CreateHorizontalLayoutGroup(rootParent);
	horzlist[32] = UI.CreateHorizontalLayoutGroup(rootParent);

	
	buildCitiesToggle= UI.CreateCheckBox(horzlist[40]).SetText('Use Block and EMB cards to improve a city').SetIsChecked(initialBlockCityActive).SetOnValueChanged(ShowBlockSettings);
	horzlist[41] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	foundNewCitiesToggle= UI.CreateCheckBox(horzlist[45]).SetText('Use EMB to found a new city').SetIsChecked(initialEMBActive).SetOnValueChanged(ShowEMBSettings);
	horzlist[46] = UI.CreateHorizontalLayoutGroup(rootParent);
	
	wastelandsToggle= UI.CreateCheckBox(horzlist[50]).SetText('Wastlands starts with a neutral city').SetIsChecked(initialWastlandCities);
	
	startingCitiesToggle= UI.CreateCheckBox(horzlist[60]).SetText("Distributed territories start with a city")
		.SetIsChecked(initialCitiesActive)
		.SetOnValueChanged(ShowStartingCitiesSettings);
	horzlist[61] = UI.CreateHorizontalLayoutGroup(rootParent);

	
	commerceFreeDeployCityToggle= UI.CreateCheckBox(horzlist[70]).SetText("Deploying in a city will give you twice as many armies. But the city level is reduced by 1").SetIsChecked(initialCommerceFree);
	CityDeployOnlyToggle= UI.CreateCheckBox(horzlist[80]).SetText("All army deployments not made in a city of 1 or greater are skipped. Make sure to not create games that can get stuck!").SetIsChecked(initialArmyDeployment);

	
	if (showInstructions == true) then
		ShowAdvancedInstructions();
	end
	
	if (initialCityWalls == true) then
		ShowCitySettings();
	end
	
	if (initialCityGrowth == true) then
		ShowGrowthSettings();
	end
	
	if (initialBombcardActive == true) then
		ShowBombSettings();
	end
	
	if (initialCapitalsToggle == true) then
		ShowCapitalsSettings();
	end
	
	if (initialBlockCityActive == true) then
		ShowBlockSettings();
	end
	
	if (initialEMBActive == true) then
		ShowEMBSettings();
	end
	
	if (initialCitiesActive == true) then
		ShowStartingCitiesSettings();
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
		text2 = UI.CreateLabel(horzlist[2]).SetText('Bomb card can reduce the number of cities on a territory. You can customize the strength. A city of any size will protect the armies in that city from the bomb card! If enabled you can use blockade and EMB cards to build on an exsisting city. EMB can also be used to create a new city! Also a city of size 0, is still a city and can be rebuilt using the either card.');	
		text3 = UI.CreateLabel(horzlist[3]).SetText('If a starting territory has a set number of armies at the begining of a game, they will start with a large city. This is intended to be used in combination with Custom Senario, so that a game creator can make some key territories start with cities.');
		text4 = UI.CreateLabel(horzlist[4]).SetText("Hope you enjoy and don't hesitate to make suggestions for imporovments to me");
		text5 = UI.CreateLabel(horzlist[5]).SetText('If you run into any issues please contact me, TBest. [Click Mod Info, open my profle and send me a mail]');

	end
end	


function ShowCitySettings()
	if(textDefBonus ~= nil) then
		UI.Destroy(textDefBonus);
		UI.Destroy(sliderDefBonus);
		
		textDefBonus = nil;
		else
		textDefBonus = UI.CreateLabel(horzlist[11]).SetText('Percantage bonus for each city:');
		sliderDefBonus = UI.CreateNumberInputField(horzlist[11]).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(initialDefPower);
	end
end	

function ShowGrowthSettings()
	if(textGrowth ~= nil) then
		UI.Destroy(textGrowth);
		UI.Destroy(sliderCityGrowthCap);
		
		textGrowth = nil;
		else
		textGrowth = UI.CreateLabel(horzlist[16]).SetText('The max size a city can naturaly grow:');
		sliderCityGrowthCap = UI.CreateNumberInputField(horzlist[16]).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(initialCityGrowthCap);
	end
end	

function ShowBombSettings()
	if(textBombCard ~= nil) then	
		UI.Destroy(textBombCard);
		UI.Destroy(sliderBombCard);
		
		textBombCard = nil;
		else
		textBombCard= UI.CreateLabel(horzlist[21]).SetText('Bomb card reduces a city by:');
		sliderBombCard = UI.CreateNumberInputField(horzlist[21]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialBombcardPower);
	end
end	

function ShowCapitalsSettings()
	if(textCapitals ~= nil) then
		UI.Destroy(textCapitals);
		UI.Destroy(sliderCapitals);
		UI.Destroy(textExtraCities);
		UI.Destroy(sliderExtraCityCapitals);
		
		textCapitals = nil;
		else
		
		textCapitals= UI.CreateLabel(horzlist[31]).SetText('Capitals starts with this many arimes:');
		sliderCapitals = UI.CreateNumberInputField(horzlist[31]).SetSliderMinValue(0).SetSliderMaxValue(15).SetValue(initialCustomSenarioCapitals);
		textExtraCities = UI.CreateLabel(horzlist[32]).SetText('Capitals starts with this many cities:');
		sliderExtraCityCapitals = UI.CreateNumberInputField(horzlist[32]).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(initialCapitalExtraCities);
	end
end	

function ShowBlockSettings()
	if(textBlockCard ~= nil) then	
		UI.Destroy(textBlockCard);
		UI.Destroy(sliderBlockCard);
		
		textBlockCard = nil;
		else
		textBlockCard= UI.CreateLabel(horzlist[41]).SetText('Blockade and EMB card builds a city by:');
		sliderBlockCard = UI.CreateNumberInputField(horzlist[41]).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(initialBlockadePower);
	end
end	

function ShowEMBSettings()
	if(textEMBCard ~= nil) then	
		UI.Destroy(textEMBCard);
		UI.Destroy(sliderEMBCard);
		
		textEMBCard = nil;
		else
		textEMBCard= UI.CreateLabel(horzlist[46]).SetText('Emergency Blockade Card can found a new city:');
		sliderEMBCard = UI.CreateNumberInputField(horzlist[46]).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(initialEMBPower);
	end
end	


function ShowStartingCitiesSettings()
	if(textStartingCities ~= nil) then	
		UI.Destroy(textStartingCities);
		UI.Destroy(sliderStartingCities);
		
		textStartingCities = nil;
		else
		textStartingCities= UI.CreateLabel(horzlist[61]).SetText('Number of starting cities for distributed territories:');
		sliderStartingCities = UI.CreateNumberInputField(horzlist[61]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialNumberOfStartingCities);
	end
end	