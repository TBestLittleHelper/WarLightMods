function Client_PresentSettingsUI(rootParent)
	if (Mod.Settings.Version ~= 2) then
		return
	end

	vert = UI.CreateVerticalLayoutGroup(rootParent)
	if (Mod.Settings.ModSafeStartEnabled) then
		UI.CreateLabel(vert).SetText(
			"Cannot attack other players for the first " .. Mod.Settings.SafeStartNumTurns .. " turns"
		)
	end
	if (Mod.Settings.ModGiftGoldEnabled) then
		UI.CreateLabel(vert).SetText("Gift Gold Mod is on")
	end
	if (Mod.Settings.ModBetterCitiesEnabled) then
		UI.CreateLabel(vert).SetText("Better Cities is on")
		ModBetterCitiesPresentSettings(rootParent)
	end
end

function ModBetterCitiesPresentSettings(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent)
	if (Mod.Settings.StartingCitiesActive) then
		UI.CreateLabel(vert).SetText("Number of cities in distributed territories : " .. Mod.Settings.NumberOfStartingCities)
	end
	if (Mod.Settings.CityWallsActive) then
		UI.CreateLabel(vert).SetText(
			"Percantage bonus for each city on a territory is :  " .. Mod.Settings.DefPower * 100 .. "%"
		)
	end
	if (Mod.Settings.CityGrowth) then
		UI.CreateLabel(vert).SetText("City growth cap is : " .. Mod.Settings.CityGrowthCap)
		UI.CreateLabel(vert).SetText("City growth frequency is : " .. Mod.Settings.CityGrowthFrequency)
		UI.CreateLabel(vert).SetText("City growth power is : " .. Mod.Settings.CityGrowthPower)
	end
	if (Mod.Settings.CustomSenarioCapitals > 0) then
		UI.CreateLabel(vert).SetText(
			"Capitals had this many armies in the custom senario distribution : " .. Mod.Settings.CustomSenarioCapitals
		)
		UI.CreateLabel(vert).SetText("Capitals started with " .. Mod.Settings.CapitalExtraStartingCities .. " cities")
	end
	if (Mod.Settings.BombcardActive) then
		UI.CreateLabel(vert).SetText("Bomb card reduces each city by : " .. Mod.Settings.BombcardPower)
	end
	if (Mod.Settings.BlockadeBuildCityActive) then
		UI.CreateLabel(vert).SetText(
			"Blocade and Emergency Blocade card increase a city by  : " .. Mod.Settings.BlockadePower
		)
	end
	if (Mod.Settings.EMBActive) then
		UI.CreateLabel(vert).SetText("Emergency Blocade card can found a new city of size  : " .. Mod.Settings.EMBPower)
	end
	if (Mod.Settings.WastlandCities) then
		UI.CreateLabel(vert).SetText("Wastlands starts with a city")
	end
	if (Mod.Settings.CommerceFreeCityDeploy) then
		UI.CreateLabel(vert).SetText(
			"Deploying armies on a city will give you twice as many armies. BUT will reduce your city by 1."
		)
	end
	if (Mod.Settings.CityDeployOnly) then
		UI.CreateLabel(vert).SetText("You can only deploy in cities")
	end
end

function CreateLine(settingname, completed, variable, default)
	local lab = UI.CreateLabel(root)
	if (completed == nil) then
		completed = -1
	end
	if (variable == nil) then
		--lab.SetText(settingname .. completed .. '/' .. default);
		lab.SetText(settingname .. default)
	else
		--lab.SetText(settingname .. completed .. '/' .. variable);
		lab.SetText(settingname .. variable)
	end
	if (variable ~= default) then
		lab.SetColor("#FF0000")
	end
end
