function PresentModBetterCitiesSettings()
	--City def%
	initialCityWalls = Mod.Settings.CityWallsActive
	if (Mod.Settings.DefPower ~= nil) then
		initialDefPower = Mod.Settings.DefPower * 100 --This number is stored as a decimal. So *100 to show a %
	else
		initialDefPower = 25
	end
	--City growth
	initialCityGrowth = Mod.Settings.CityGrowth
	initialCityGrowthCap = Mod.Settings.CityGrowthCap
	initialCityGrowthPower = Mod.Settings.CityGrowthPower
	initialCityGrowthFrequency = Mod.Settings.CityGrowthFrequency

	--Bomb card
	initialBombcardActive = Mod.Settings.BombcardActive
	initialBombcardPower = Mod.Settings.BombcardPower
	--Capitals
	initialCustomSenarioCapitals = Mod.Settings.CustomSenarioCapitals
	initialCapitalsToggle = false
	if (initialCustomSenarioCapitals ~= nil) then
		if (initialCustomSenarioCapitals == -1) then
			initialCapitalsToggle = false
		end
	end
	initialCapitalExtraCities = Mod.Settings.CapitalExtraStartingCities
	--Distributed starting cities
	initialCitiesActive = Mod.Settings.StartingCitiesActive
	initialNumberOfStartingCities = Mod.Settings.NumberOfStartingCities
	initialWastlandCities = Mod.Settings.WastlandCities
	--Commerce city deployment
	initialCommerceFree = Mod.Settings.CommerceFreeCityDeploy
	initialArmyDeployment = Mod.Settings.CityDeployOnly
	--Block and EMB card
	initialBuildCityActive = Mod.Settings.CapitalsActive
	initialBlockCityActive = Mod.Settings.BlockadeBuildCityActive
	initialBlockadePower = Mod.Settings.BlockadePower
	initialEMBActive = Mod.Settings.EMBActive
	initialEMBPower = Mod.Settings.EMBPower

	--Wastlands and capitals are checked always

	if initialCityWalls == nil then
		initialCityWalls = true
	end
	if initialDefPower == nil then
		initialDefPower = 25
	end

	if initialCityGrowth == nil then
		initialCityGrowth = true
	end
	if initialCityGrowthCap == nil then
		initialCityGrowthCap = 10
	end
	if initialCityGrowthPower == nil then
		initialCityGrowthPower = 1
	end
	if initialCityGrowthFrequency == nil then 
		initialCityGrowthFrequency = 5
	end;

	if initialBombcardActive == nil then
		initialBombcardActive = true
	end
	if initialBombcardPower == nil then
		initialBombcardPower = 2
	end

	if initialCustomSenarioCapitals == nil then
		initialCustomSenarioCapitals = 10
	end
	if initialCapitalExtraCities == nil then
		initialCapitalExtraCities = 5
	end

	if initialCitiesActive == nil then
		initialCitiesActive = true
	end
	if initialNumberOfStartingCities == nil then
		initialNumberOfStartingCities = 1
	end
	if initialWastlandCities == nil then
		initialWastlandCities = true
	end

	if initialCommerceFree == nil then
		initialCommerceFree = true
	end
	if initialArmyDeployment == nil then
		initialArmyDeployment = false
	end

	if initialBuildCityActive == nil then
		initialBuildCityActive = true
	end
	if initialBlockCityActive == nil then
		initialBlockCityActive = true
	end
	if initialBlockadePower == nil then
		initialBlockadePower = 1
	end
	if initialEMBActive == nil then
		initialEMBActive = true
	end
	if initialEMBPower == nil then
		initialEMBPower = 1
	end
    
    --Instructions text
	text1 =
	UI.CreateLabel(vertlistBetterCities[1]).SetText(
	"IMPORTANT: When using this mod it's strongely recomended that you make price to build cities extremely exspensive to the point where players can't build cities using gold."
)
text2 =
	UI.CreateLabel(vertlistBetterCities[2]).SetText(
	"City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, so for example 1 city gives 50% extra defence and 2 cities gives 100%. Bomb card can reduce the number of cities on a territory. You can customize the strength. A city of any size will protect the armies in that city from the bomb card! If enabled you can use blockade and EMB cards to build on an exsisting city. EMB can also be used to create a new city! Also a city of size 0, is still a city and can be rebuilt using the either card."
)
text3 =
	UI.CreateLabel(vertlistBetterCities[3]).SetText(
	"If a starting territory has a set number of armies at the begining of a game, they will start with a large city. This is intended to be used in combination with Custom Senario, so that a game creator can make some key territories start with cities."
)
	cityWallsToggle =
		UI.CreateCheckBox(vertlistBetterCities[4]).SetText("City Walls").SetIsChecked(initialCityWalls)
	textDefBonus = UI.CreateLabel(vertlistBetterCities[5]).SetText("Percantage bonus for each city:")
		sliderDefBonus =
			UI.CreateNumberInputField(vertlistBetterCities[6]).SetSliderMinValue(10).SetSliderMaxValue(50).SetValue(initialDefPower)

	cityGrowthToggle =
		UI.CreateCheckBox(vertlistBetterCities[7]).SetText("Natural City Growth").SetIsChecked(initialCityGrowth)
	textGrowth = UI.CreateLabel(vertlistBetterCities[8]).SetText("The max size a city can naturaly grow:")
	sliderCityGrowthCap =
		UI.CreateNumberInputField(vertlistBetterCities[8]).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(initialCityGrowthCap)
	textGrowth = UI.CreateLabel(vertlistBetterCities[9]).SetText("How often cities grows (Turns+1 % [modulos] frequency )")
	sliderCityGrowthFrequency =	UI.CreateNumberInputField(vertlistBetterCities[9]).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(initialCityGrowthFrequency)
	

	bombCardToggle =
		UI.CreateCheckBox(vertlistBetterCities[10]).SetText("Bomb card damages cities").SetIsChecked(initialBombcardActive)
	textBombCard = UI.CreateLabel(vertlistBetterCities[11]).SetText("Bomb card reduces a city by:")
	sliderBombCard =
		UI.CreateNumberInputField(vertlistBetterCities[11]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(initialBombcardPower)

	capitalsToggle =
		UI.CreateCheckBox(vertlistBetterCities[12]).SetText("Capitals").SetIsChecked(initialCapitalsToggle)
	textCapitals = UI.CreateLabel(vertlistBetterCities[13]).SetText("Capitals starts with this many arimes:")
	sliderCapitals =
		UI.CreateNumberInputField(vertlistBetterCities[13]).SetSliderMinValue(0).SetSliderMaxValue(15).SetValue(
		initialCustomSenarioCapitals
	)
	textExtraCities = UI.CreateLabel(vertlistBetterCities[14]).SetText("Capitals starts with this many cities:")
	sliderExtraCityCapitals =
		UI.CreateNumberInputField(vertlistBetterCities[14]).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(
		initialCapitalExtraCities
	)

	buildCitiesToggle =
		UI.CreateCheckBox(vertlistBetterCities[15]).SetText("Use Block and EMB cards to improve a city").SetIsChecked(
		initialBlockCityActive
	)
	textBlockCard = UI.CreateLabel(vertlistBetterCities[16]).SetText("Blockade and EMB card improves a city by:")
	sliderBlockCard =
		UI.CreateNumberInputField(vertlistBetterCities[16]).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(initialBlockadePower)




	foundNewCitiesToggle =
		UI.CreateCheckBox(vertlistBetterCities[17]).SetText("Use EMB to found a new city").SetIsChecked(initialEMBActive)
	textEMBCard = UI.CreateLabel(vertlistBetterCities[18]).SetText("Emergency Blockade Card can create a new city:")
	sliderEMBCard =
		UI.CreateNumberInputField(vertlistBetterCities[18]).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(initialEMBPower)

	wastelandsToggle =
		UI.CreateCheckBox(vertlistBetterCities[19]).SetText("Wastlands starts with a neutral city").SetIsChecked(initialWastlandCities)

	startingCitiesToggle =
		UI.CreateCheckBox(vertlistBetterCities[20]).SetText("Distributed player territories starts with a city").SetIsChecked(initialCitiesActive)
	textStartingCities = UI.CreateLabel(vertlistBetterCities[21]).SetText("Size of the starting cities:")
	sliderStartingCities =
		UI.CreateNumberInputField(vertlistBetterCities[21]).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(
		initialNumberOfStartingCities
	)

	commerceFreeDeployCityToggle =
		UI.CreateCheckBox(vertlistBetterCities[22]).SetText(
		"Deploying in a city will give you twice as many armies. But the city level is reduced by 1"
	).SetIsChecked(initialCommerceFree)

	CityDeployOnlyToggle =
		UI.CreateCheckBox(vertlistBetterCities[23]).SetText(
		"All army deployments not made in a city of 1 or greater are skipped. Make sure to not create games that can get stuck!"
	).SetIsChecked(initialArmyDeployment)
end