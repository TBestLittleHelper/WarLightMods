--https://github.com/FizzerWL/ExampleMods/tree/master/Diplomacy2Mod

function DiplomacyMenu(rootParent, setMaxSize, setScrollable, game, close)
	Game = game; --make it globally accessible

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	--TODO list proposals we have sent, but have not recived a response
	--TODO make the players into buttons so we can color them? Or maybe just color them
	--List pending proposals.  This isn't absolutely necessary since we also alert the player of new proposals, but it's nice to list them here anyway.
	for _,proposal in pairs(Mod.PlayerGameData.Diplo.PendingProposals or {}) do
		local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
		local row = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row).SetText('Proposal from ' .. otherPlayer);
		UI.CreateButton(row).SetText('Respond').SetOnClick(function() DoProposalPrompt(game, proposal); close(); end);
    end

	local alliances = Mod.PublicGameData.Diplo.Alliances or {};
	if (#alliances == 0) then
		UI.CreateLabel(vert).SetText("No alliances are currently in effect");
	else
		--Render all alliances that involve the selected player. We start out by selecting ourselves. 
		local selectedPlayerID = game.Us.ID;
		local ourAlliances = filter(alliances, function(alliance) return game.Us ~= nil and (alliance.PlayerOne == selectedPlayerID or alliance.PlayerTwo == game.Us.ID) end);
		UI.CreateLabel(vert).SetText("Players you have an alliances with. Click on a name to break the alliance.");

		for _,alliance in pairs(ourAlliances) do
			local otherPlayerID
			if alliance.PlayerOne == game.Us.ID then
				otherPlayerID = alliance.PlayerTwo 
			else
				otherPlayerID = alliance.PlayerOne
			end
			local otherPlayerName = game.Game.Players[otherPlayerID].DisplayName(nil, false);

			
			local horz = UI.CreateHorizontalLayoutGroup(vert);
			--UI.CreateLabel(horz).SetText('You are allied with ' .. otherPlayerName);
			local color = ClientGame.Game.Players[ClientGame.Us.ID].Color.HtmlColor
			UI.CreateButton(horz).SetText(otherPlayerName).SetColor(color).SetOnClick(function() 
				BreakAlliance(otherPlayerID, otherPlayerName);
			end);
		end

			
		--Render all alliances that don't involve us
		for _,alliance in pairs(filter(alliances, function(alliance) return game.Us == nil or (alliance.PlayerOne ~= game.Us.ID and alliance.PlayerTwo ~= game.Us.ID) end)) do
			local playerOne = game.Game.Players[alliance.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[alliance.PlayerTwo].DisplayName(nil, false);
			UI.CreateLabel(vert).SetText(playerOne .. ' and ' .. playerTwo .. ' are allied');
		end
	end

	if (game.Us ~= nil) then --don't show buttons to spectators
		UI.CreateButton(vert).SetText("Propose Alliance").SetOnClick(function()
			game.CreateDialog(CreateProposeDialog);
		end);

		UI.CreateButton(vert).SetText("Go Back").SetColor("#0000FF").SetOnClick(function() 		
			RefreshMainDialog(close, game);
		end);
	end
end

function BreakAlliance(otherPlayerID, otherPlayerName)
	local msg = 'Breaking alliance with ' .. otherPlayerName;

	local payload = 'Diplomacy2_BreakAlliance_' .. otherPlayerID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
	--TODO if alerts?
	UI.Alert("The break order has been added to the order list. Note that if you had already commited, you need to uncommit then repeat this action.")
end

function CreateProposeDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(390, 300);
	TargetPlayerID = nil;

	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Propose an alliance with this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	UI.CreateButton(vert).SetText("Propose Alliance").SetOnClick(function() 

		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end

		local payload = {};
		payload.Mod = 'Diplomacy';
		payload.Message = "Propose";
		payload.TargetPlayerID = TargetPlayerID;

		Game.SendGameCustomMessage("Proposing alliance...", payload, function(returnValue) 
			UI.Alert("Proposal sent!");
			close(); --Close the propose dialog since we're done with it
		end);
	end);
end

function TargetPlayerClicked()
	local options = map(filter(Game.Game.Players, IsPotentialTarget), PlayerButton);
	--TODO if no option, alert
	UI.PromptFromList("Select the player you'd like to propose an alliance with", options);
end

--Determines if the player is one we can propose an alliance to.
function IsPotentialTarget(player)
	if (Game.Us.ID == player.ID) then return false end; -- we can never propose an alliance with ourselves.

	if (player.State ~= WL.GamePlayerState.Playing) then return false end; --skip players not alive anymore, or that declined the game.

	if (Game.Settings.SinglePlayer) then return true end; --in single player, allow proposing with everyone
	--TODO filter exsisting allies
	return not player.IsAI; --In multi-player, never allow proposing with an AI.
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

function DoProposalPrompt(game, proposal) 
    local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
    UI.PromptFromList(otherPlayer .. ' has proposed an alliance with you.  Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });
end
function AcceptProposalBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Accept';
	ret["selected"] = function() 
		local payload = {};
		payload.Mod = 'Diplomacy';
        payload.Message = "AcceptProposal";
        payload.ProposalID = proposal.ID;
		game.SendGameCustomMessage('Accepting proposal...', payload, function(returnValue) end);
	end
	return ret;
end

function DeclineProposalBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Decline';
	ret["selected"] = function() 
		local payload = {};
		payload.Mod = 'Diplomacy';
        payload.Message = "DeclineProposal";
        payload.ProposalID = proposal.ID;
		game.SendGameCustomMessage('Declining proposal...', payload, function(returnValue) end);
	end
	return ret;
end