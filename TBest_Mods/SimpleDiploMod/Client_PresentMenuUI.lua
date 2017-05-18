require('Utilities');

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
	UI.CreateLabel(row2).SetText("Offer this player an allience: ");
	TargetPlayerBtn = UI.CreateButton(row2).SetText("Select player...").SetOnClick(TargetPlayerClicked);


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
	end
	return ret;
end

function CheckCreateFinalStep()
	if (SubmitBtn == nil) then

		local row3 = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row3).SetText("How long do you want to declere war for? ");
		NumTurnInput = UI.CreateNumberInputField(row3).SetSliderMinValue(2);

		SubmitBtn = UI.CreateButton(vert).SetText("Declering War").SetOnClick(SubmitClicked);
	end
	NumTurnInput.SetSliderMaxValue(10).SetValue(10);
end

function SubmitClicked()
	local msg = 'Declering war on ' .. Game.Game.Players[TargetPlayerID].DisplayName(nil, false);

	local payload = NumTurnInput.GetValue() .. ',' .. TargetPlayerID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end
