require('Utilities');
require('Client_PresentMenuUI')


function Client_GameRefresh(game)
    --Skip if we're not in the game.  We can't use game.SendGameCustomMessage as a spectator
    if (game.Us == nil) then 
        return;
    end
	
	print("Client_GameRefresh called RefreshGame")
	RefreshGame(game);
end


--TODO alert when new chat.
function DoProposalPrompt(game, Chat)
	local senderChat = game.Game.Players[Chat.Sender].DisplayName(nil, false);
	
	UI.Alert(senderChat .. " has sent the following chat: " .. Chat.Chat)
	
end