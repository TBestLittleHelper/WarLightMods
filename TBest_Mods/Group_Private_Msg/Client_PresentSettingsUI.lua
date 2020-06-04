function Client_PresentSettingsUI(rootParent)
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	if (Mod.Settings.ModGiftGoldEnabled) then 
		UI.CreateLabel(vert).SetText('Gift Gold Mod is on');
	end
	if (Mod.Settings.ModDiplomacyEnabled) then
		UI.CreateLabel(vert).SetText('Dimplomacy is on');
	end;
	if (Mod.Settings.ModBetterCitiesEnabled)then
		UI.CreateLabel(vert).SetText('Better Cities is on');
		ModBetterCitiesPresentSettings(rootParent);
	end;
	if (Mod.Settings.ModWinningConditionsEnabled)then
		UI.CreateLabel(vert).SetText('Winning Conditions is on');
		ModWinConPresentSettings(rootParent);
	end;
end;


function ModBetterCitiesPresentSettings(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	if (Mod.Settings.StartingCitiesActive) then
		UI.CreateLabel(vert).SetText('Number of cities in distributed territories : ' .. Mod.Settings.NumberOfStartingCities);
	end
	if(Mod.Settings.CityWallsActive) then
		UI.CreateLabel(vert).SetText('Percantage bonus for each city on a territory is :  ' .. Mod.Settings.DefPower*100 .. '%');
	end
	if(Mod.Settings.CityGrowth)then
		UI.CreateLabel(vert).SetText('City growth cap is : ' .. Mod.Settings.CityGrowthCap)
		UI.CreateLabel(vert).SetText('City growth frequency is : ' ..  Mod.Settings.CityGrowthFrequency)
		UI.CreateLabel(vert).SetText('City growth power is : ' .. Mod.Settings.CityGrowthPower)
	end
	if (Mod.Settings.CustomSenarioCapitals > 0) then
		UI.CreateLabel(vert).SetText('Capitals had this many armies in the custom senario distribution : ' .. Mod.Settings.CustomSenarioCapitals);
		UI.CreateLabel(vert).SetText('Capitals started with ' .. Mod.Settings.CapitalExtraStartingCities .. ' cities');
	end
	if (Mod.Settings.BombcardActive) then
		UI.CreateLabel(vert).SetText('Bomb card reduces each city by : ' .. Mod.Settings.BombcardPower);
	end
	if (Mod.Settings.BlockadeBuildCityActive) then
		UI.CreateLabel(vert).SetText('Blocade and Emergency Blocade card increase a city by  : ' .. Mod.Settings.BlockadePower);
	end
	if (Mod.Settings.EMBActive) then
		UI.CreateLabel(vert).SetText('Emergency Blocade card can found a new city of size  : ' .. Mod.Settings.EMBPower);
	end
	if (Mod.Settings.WastlandCities) then
		UI.CreateLabel(vert).SetText('Wastlands starts with a city');
	end
	if (Mod.Settings.CommerceFreeCityDeploy) then
		UI.CreateLabel(vert).SetText('Deploying armies on a city will give you twice as many armies. BUT will reduce your city by 1.');
	end
	if (Mod.Settings.CityDeployOnly) then
		UI.CreateLabel(vert).SetText('You can only deploy in cities');
	end
end

function ModWinConPresentSettings( rootParent )
	root = rootParent;
	UI.CreateLabel(rootParent).SetText('To view your progress go under menu').SetColor('#FF0000');
	UI.CreateLabel(rootParent).SetText('To win, you need to complete ' .. Mod.Settings.Conditionsrequiredforwin .. ' of this red conditions').SetColor('#FF0000');
	CreateLine('Captured this many territories : ',Mod.PlayerGameData.Capturedterritories, Mod.Settings.Capturedterritories,0);
	CreateLine('Lost this many territories : ',Mod.PlayerGameData.Lostterritories, Mod.Settings.Lostterritories,0);
	CreateLine('Owns this many territories : ',Mod.PlayerGameData.Ownedterritories, Mod.Settings.Ownedterritories,0);
	CreateLine('Captured this many bonuses : ',Mod.PlayerGameData.Capturedbonuses, Mod.Settings.Capturedbonuses,0);
	CreateLine('Lost this many bonuses : ',Mod.PlayerGameData.Lostbonuses, Mod.Settings.Lostbonuses,0);
	CreateLine('Owns this many bonuses : ',Mod.PlayerGameData.Ownedbonuses, Mod.Settings.Ownedbonuses,0);
	CreateLine('Killed this many armies : ',Mod.PlayerGameData.Killedarmies, Mod.Settings.Killedarmies,0);
	CreateLine('Lost this many armies : ',Mod.PlayerGameData.Lostarmies, Mod.Settings.Lostarmies,0);
	CreateLine('Owns this many armies : ',Mod.PlayerGameData.Ownedarmies, Mod.Settings.Ownedarmies,0);
	CreateLine('Eliminated this many AIs : ',Mod.PlayerGameData.Eleminateais, Mod.Settings.Eleminateais,0);
	CreateLine('Eliminated this many players : ',Mod.PlayerGameData.Eleminateplayers, Mod.Settings.Eleminateplayers,0);
	CreateLine('Eliminated this many AIs and players : ',Mod.PlayerGameData.Eleminateaisandplayers, Mod.Settings.Eleminateaisandplayers,0);
	if(Mod.Settings.terrcondition ~= nil)then
		local hasterr = false;
		for _,condition in pairs(Mod.Settings.terrcondition)do
			hasterr = true;
			UI.CreateLabel(rootParent).SetText("You need to hold the territory " .. condition.Terrname .. " for " .. condition.Turnnum .. " turns").SetColor('#FF0000');
		end
		if(hasterr == true)then
			UI.CreateLabel(rootParent).SetText("If you lose one of the territories, the condition restarts, when you get it again").SetColor('#FF0000');
		end
	end
end
function CreateLine(settingname,completed,variable,default)
	local lab = UI.CreateLabel(root);
	if(completed == nil)then
		completed = -1;
	end
	if(variable == nil)then
		--lab.SetText(settingname .. completed .. '/' .. default);
		lab.SetText(settingname .. default);
	else
		--lab.SetText(settingname .. completed .. '/' .. variable);
		lab.SetText(settingname .. variable);
	end
	if(variable ~= default)then
		lab.SetColor('#FF0000');
	end
end