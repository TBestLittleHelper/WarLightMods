function Client_SaveConfigureUI(alert)
	Mod.Settings.ModGiftGoldEnabled= ModGiftGoldEnabled  
	Mod.Settings.ModDiplomacyEnabled= ModDiplomacyEnabled
	Mod.Settings.ModBetterCitiesEnabled= ModBetterCitiesEnabled 
	if (ModBetterCitiesEnabled) then SaveModBetterCities() end;
	Mod.Settings.ModWinningConditionsEnabled= ModWinningConditionsEnabled 
	if (ModWinningConditionsEnabled)then SaveModWinCon(alert)end;
end	


function SaveModBetterCities()
	Mod.Settings.CityWallsActive = false;
	if (cityWallsToggle.GetIsChecked()) then 
		Mod.Settings.CityWallsActive = true;
		Mod.Settings.DefPower = sliderDefBonus.GetValue() * 0.01; -- Convert to decimals from percentage
		if (Mod.Settings.DefPower < 0) then Mod.Settings.DefPower = 0; end
		if (Mod.Settings.DefPower > 100) then Mod.Settings.DefPower = 100; end			
	end;
	
	Mod.Settings.CityGrowth = false;
	if (cityGrowthToggle.GetIsChecked()) then 
		Mod.Settings.CityGrowth = true;
		Mod.Settings.CityGrowthCap = sliderCityGrowthCap.GetValue();
		if (Mod.Settings.CityGrowthCap < 1) then Mod.Settings.DefPower = 1; end
		if (Mod.Settings.CityGrowthCap > 100) then Mod.Settings.DefPower = 100; end			
		Mod.Settings.CityGrowthPower = 1; --For now, a host can't change this value but we might open it up in the future.
	end;
	
	Mod.Settings.BombcardActive = false;
	if (bombCardToggle.GetIsChecked()) then 
		Mod.Settings.BombcardActive = bombCardToggle.GetIsChecked();
		Mod.Settings.BombcardPower = sliderBombCard.GetValue();
		if (Mod.Settings.BombcardPower < 1) then Mod.Settings.BombcardPower = 1; end
		if (Mod.Settings.BombcardPower > 10) then Mod.Settings.BombcardPower = 10; end
	end
	
	Mod.Settings.StartingCitiesActive = false;
	if (startingCitiesToggle.GetIsChecked()) then
		Mod.Settings.StartingCitiesActive = true;
		Mod.Settings.NumberOfStartingCities = sliderStartingCities.GetValue();
		if (Mod.Settings.NumberOfStartingCities < 1) then Mod.Settings.NumberOfStartingCities = 1; end
		if (Mod.Settings.NumberOfStartingCities > 10) then Mod.Settings.NumberOfStartingCities = 10; end
	end
	
	Mod.Settings.CustomSenarioCapitals = -1;
	if (capitalsToggle.GetIsChecked()) then
		Mod.Settings.CustomSenarioCapitals = sliderCapitals.GetValue();	
		if (Mod.Settings.CustomSenarioCapitals < 0) then Mod.Settings.CustomSenarioCapitals = 0; end
		if (Mod.Settings.CustomSenarioCapitals > 1000) then Mod.Settings.CustomSenarioCapitals = 1000; end

		Mod.Settings.CapitalExtraStartingCities = sliderExtraCityCapitals.GetValue();
		if (Mod.Settings.CapitalExtraStartingCities < 0) then Mod.Settings.CustomSenarioCapitals = 0; end
		if (Mod.Settings.CapitalExtraStartingCities > 100) then Mod.Settings.CustomSenarioCapitals = 100; end
	end
	
    Mod.Settings.BlockadeBuildCityActive = false;
	if (buildCitiesToggle.GetIsChecked()) then
		Mod.Settings.BlockadeBuildCityActive = true;
		Mod.Settings.BlockadePower = sliderBlockCard.GetValue();
		if (Mod.Settings.BlockadePower < 1) then Mod.Settings.BlockadePower = 1; end
		if (Mod.Settings.BlockadePower > 10) then Mod.Settings.BlockadePower = 10; end

	end
	
	Mod.Settings.EMBActive = false;
	if (foundNewCitiesToggle.GetIsChecked()) then
		Mod.Settings.EMBActive = true;
		Mod.Settings.EMBPower = sliderEMBCard.GetValue();
		if (Mod.Settings.EMBPower < 1) then Mod.Settings.EMBPower = 1; end
		if (Mod.Settings.EMBPower > 10) then Mod.Settings.EMBPower = 10; end

	end
	
    Mod.Settings.WastlandCities = false;
	if (wastelandsToggle.GetIsChecked()) then
		Mod.Settings.WastlandCities = wastelandsToggle.GetIsChecked();
	end;
	
	Mod.Settings.CommerceFreeCityDeploy = false;
	if (commerceFreeDeployCityToggle.GetIsChecked()) then
		Mod.Settings.CommerceFreeCityDeploy = commerceFreeDeployCityToggle.GetIsChecked();
	end;
	Mod.Settings.CityDeployOnly = false;
	
	if (CityDeployOnlyToggle.GetIsChecked())then
		Mod.Settings.CityDeployOnly = true;
	end;
end

function SaveModWinCon(alert)
	Alert = alert;
  	Mod.Settings.Conditionsrequiredforwin = inputConditionsrequiredforwin.GetValue();
	InRange(Mod.Settings.Conditionsrequiredforwin);
	TakenSettings = 0;
	Mod.Settings.Capturedterritories = inputCapturedterritories.GetValue();
	InRange(Mod.Settings.Capturedterritories);
	Mod.Settings.Lostterritories = inputLostterritories.GetValue();
	InRange(Mod.Settings.Lostterritories);
	Mod.Settings.Ownedterritories = inputOwnedterritories.GetValue();
	InRange(Mod.Settings.Ownedterritories);
	Mod.Settings.Capturedbonuses = inputCapturedbonuses.GetValue();
	InRange(Mod.Settings.Capturedbonuses);
	Mod.Settings.Lostbonuses = inputLostbonuses.GetValue();
	InRange(Mod.Settings.Lostbonuses);
	Mod.Settings.Ownedbonuses = inputOwnedbonuses.GetValue();
	InRange(Mod.Settings.Ownedbonuses);
	Mod.Settings.Killedarmies = inputKilledarmies.GetValue();
	InRange(Mod.Settings.Killedarmies);
	Mod.Settings.Lostarmies = inputLostarmies.GetValue();
	InRange(Mod.Settings.Lostarmies);
	Mod.Settings.Ownedarmies = inputOwnedarmies.GetValue();
	InRange(Mod.Settings.Ownedarmies);
	Mod.Settings.Eleminateais = inputEleminateais.GetValue();
	InRange(Mod.Settings.Eleminateais);
	Mod.Settings.Eleminateplayers = inputEleminateplayers.GetValue();
	InRange(Mod.Settings.Eleminateplayers);
	Mod.Settings.Eleminateaisandplayers = inputEleminateaisandplayers.GetValue();
	InRange(Mod.Settings.Eleminateaisandplayers);
	Mod.Settings.terrcondition = {};
	
	local num = 1;
	for _,terrcondition in pairs(inputterrcondition)do
		if(terrcondition.Terrname ~= nil and terrcondition.Terrname.GetText() ~= "")then
			Mod.Settings.terrcondition[num] = {};
			Mod.Settings.terrcondition[num].Terrname = terrcondition.Terrname.GetText();
			Mod.Settings.terrcondition[num].Turnnum = terrcondition.Turnnum.GetValue();
			if(Mod.Settings.terrcondition[num].Turnnum>10)then
				alert("The number of turns per territory can't be higher than 10 to prevent the game from stucking");
			end
			if(Mod.Settings.terrcondition[num].Turnnum<0)then
				alert("Numbers can't be negative");
			end
			TakenSettings = TakenSettings + 1;
			num = num + 1;
		end
	end
	
	if(Mod.Settings.Eleminateaisandplayers > 39 or Mod.Settings.Eleminateplayers > 39 or Mod.Settings.Eleminateais > 39)then
		alert("this many players can't be in a game");
	end
	if(TakenSettings < Mod.Settings.Conditionsrequiredforwin)then
		alert("there are more conditions required to win than conditions set");
	end
	if(Mod.Settings.Conditionsrequiredforwin == 0)then
		alert("You need at least one win condition.");
	end
end
function InRange(setting)
	if(setting>100000)then
		Alert("Numbers can't be higher then 100000");
	end
	if(setting<0)then
		Alert("Numbers can't be negative");
	end
	if(setting ~= 0 and TakenSettings ~= nil)then
		TakenSettings = TakenSettings + 1;
	end
end