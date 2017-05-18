require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game;

	setMaxSize(450, 250);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Us == nil) then
		UI.CreateLabel(vert).SetText("You cannot conduct diplomatic actions since you're not in the game");
		return;
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Decler war on this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);
	
end

function TargetPlayerClicked()
	local options = map(Game.Game.Players, PlayerButton);
	UI.PromptFromList("Select the player you'd like to declere war on", options);
end
function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;
		CheckCreateFinalStep();

	end
	return ret;
end

function CheckCreateFinalStep()
	if (SubmitBtn == nil) then

		local row3 = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row3).SetText("How many turns would you like to declere war for?");

		SubmitBtn = UI.CreateButton(vert).SetText("Declere War").SetOnClick(SubmitClicked);
		NumTurnInput = UI.CreateNumberInputField(row3).SetSliderMinValue(1);

	end
	NumTurnInput.SetSliderMaxValue(10).SetValue(5);

end

function SubmitClicked()
	local msg = 'Declered War on ' .. Game.Game.Players[TargetPlayerID].DisplayName(nil, false) .. ' for ' .. NumTurnInput.GetValue() .. ' turns';

	local payload = NumTurnInput.GetValue() .. ',' .. TargetPlayerID;
	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end
