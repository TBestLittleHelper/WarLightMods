function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game;

	setMaxSize(900, 600);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Us == nil) then
		UI.CreateLabel(vert).SetText("You cannot do anything since you're not in the game");
		return;
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Declere war on this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);


	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Offer peace treaty to this player this territory: ");
	TargetTerritoryBtn = UI.CreateButton(row2).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	local row3 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row3).SetText("Offer this player an allience: ");
	TargetPlayerBtn = UI.CreateButton(row3).SetText("Select player...").SetOnClick(TargetPlayerClicked);


end


function TargetPlayerClicked()
	local options = map(Game.Game.Players, PlayerButton);
	UI.PromptFromList("Select the player you'd like to give armies to", options);
end
function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;
	end
	return ret;
end

function CheckCreateFinalStep()
	if (SubmitBtn == nil) then

		local row3 = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row3).SetText("How many armies would you like to gift: ");
		NumArmiesInput = UI.CreateNumberInputField(row3).SetSliderMinValue(1);

		SubmitBtn = UI.CreateButton(vert).SetText("Gift").SetOnClick(SubmitClicked);
	end

	local maxArmies = Game.LatestStanding.Territories[TargetTerritoryID].NumArmies.NumArmies;
	NumArmiesInput.SetSliderMaxValue(maxArmies).SetValue(maxArmies);
end

function SubmitClicked()
	local msg = 'Gifting ' .. NumArmiesInput.GetValue() .. ' armies from ' .. Game.Map.Territories[TargetTerritoryID].Name .. ' to ' .. Game.Game.Players[TargetPlayerID].DisplayName(nil, false);

	local payload = NumArmiesInput.GetValue() .. ',' .. TargetTerritoryID .. ',' .. TargetPlayerID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end
