--https://github.com/FizzerWL/ExampleMods/tree/master/GiftGoldMod
require('Utilities');

function GiftGoldMenu(rootParent, setMaxSize, setScrollable, game, close)
	Game = game;
	Close = close;

	setMaxSize(450, 250);

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Gift gold to this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	local goldHave = game.LatestStanding.NumResources(game.Us.ID, WL.ResourceType.Gold);

	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText('Amount of gold to give away: ');
    GoldInput = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(goldHave)
		.SetValue(1);

	UI.CreateButton(vert).SetText("Gift").SetOnClick(SubmitClicked);
end

function TargetPlayerClicked()
	local players = filter(Game.Game.Players, function (p) return p.ID ~= Game.Us.ID end);
	local options = map(players, GiftGoldPlayerButton);
	UI.PromptFromList("Select the player you'd like to give gold to", options);
end
function GiftGoldPlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;
	end
	return ret;
end

function SubmitClicked(game)
	if (TargetPlayerID == nil) then
		UI.Alert("Please choose a player first");
		return;
	end

	--Check for negative gold.  We don't need to check to ensure we have this much since the server does that check in Server_GameCustomMessage
	local gold = GoldInput.GetValue();
	if (gold <= 0) then
		UI.Alert("Gold to gift must be a positive number");
		return;
	end

	local payload = {};
	payload.Message = 'GiftGold';
	payload.TargetPlayerID = TargetPlayerID;
	payload.Gold = gold;

	--TODO add a go back button instead?
	Game.SendGameCustomMessage("Gifting Gold...", payload, function(returnValue) 
		Close(); --Close the dialog since we're done with it
		RefreshMainDialog(close, game)		
		UI.Alert(returnValue.Message);
	end);
end