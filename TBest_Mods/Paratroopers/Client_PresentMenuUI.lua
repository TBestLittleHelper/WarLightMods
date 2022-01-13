function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)

	--If the client is using an outdated game version, ask them to update
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.17")) then
	UI.Alert("You must update your app to the latest version to use this mod");
		return;
	end;

	--If a spectator, just alert then return
	if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
		UI.Alert("You can't do anything as a spectator.");
		return;
	end;

	--Window size
	SizeX = 250;
	SizeY = 350;

	setMaxSize(SizeX, SizeY);
	setScrollable(false,false);

	SelectedTerritory = nil;
	Game = game;
	playerID = Game.Us.ID;

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	--Info graphic
	local row1 = UI.CreateHorizontalLayoutGroup(vert);

	PlayCardInfo = UI.CreateButton(row1)
	.SetText("Paratroopers can attack any territory on the map, but never capture it. Each troop cost 2 income")
	.SetColor('#880085')
	.SetPreferredHeight(400)
	.SetInteractable(false);

	--Send paratroopers
	local row2 = UI.CreateHorizontalLayoutGroup(vert);

	PlayCardButtn = UI.CreateButton(row2)
	.SetText("Send Paratroopers")
	.SetColor('#880085')
	.SetOnClick(TargetTerritoryClicked);

	--Input number of paratroopers
	local row3 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row3).SetText("Troops");
	NumArmiesInput = UI.CreateNumberInputField(row3).SetSliderMinValue(1);

	--Max is half of current income. Income check is done ServerSide and orders might get skipped if player can't afford them.
	local maxArmies = math.floor(0.5 * Game.Game.Players[playerID].Income(0, Game.LatestStanding , false, false).Total);
	if (maxArmies < 5) then maxArmies = 5 end;
	NumArmiesInput.SetSliderMaxValue(maxArmies).SetValue(maxArmies);

	local row4 = UI.CreateHorizontalLayoutGroup(vert);
	SubmitBtn = UI.CreateButton(row4).SetText("Confirm").SetOnClick(SubmitClicked);


end;


function TargetTerritoryClicked()
	UI.InterceptNextTerritoryClick(TerritoryClicked);
	PlayCardButtn.SetText("Please click on a territory.  If needed, you can move this dialog out of the way.");
	PlayCardButtn.SetInteractable(false);
end

function TerritoryClicked(terrDetails)
	PlayCardButtn.SetInteractable(true);

	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		PlayCardButtn.SetText("Send Paratroopers");
		SelectedTerritory = nil;
	else
		--Territory was clicked
		PlayCardButtn.SetText("Selected territory: " .. terrDetails.Name);
		SelectedTerritory = terrDetails;
	end
end

function SubmitClicked()
	if (SelectedTerritory == nil) then return; end;

	local msg = NumArmiesInput.GetValue() .. ' paratroopers from ' .. Game.Game.Players[playerID].DisplayName(nil, false) .. ' will attack/transfer ' .. SelectedTerritory.Name;

	local payload = 'Paratroopers_' .. NumArmiesInput.GetValue() .. ',' .. SelectedTerritory.ID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end
