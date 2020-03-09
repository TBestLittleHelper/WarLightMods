require('Utilities');

function DoProposalPrompt(game, Chat)
	local senderChat = game.Game.Players[Chat.Sender].DisplayName(nil, false);
	
	UI.Alert(senderChat .. " has sent the following chat: " .. Chat.Chat)
	
	--UI.PromptFromList(otherPlayer .. ' has proposed an alliance with you for ' .. proposal.NumTurns .. ' turns.  Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });

end
function AcceptProposalBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Accept';
	ret["selected"] = function() 
        local payload = {};
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
        payload.Message = "DeclineProposal";
        payload.ProposalID = proposal.ID;
		game.SendGameCustomMessage('Declining proposal...', payload, function(returnValue) end);
	end
	return ret;
end