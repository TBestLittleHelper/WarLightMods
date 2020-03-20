require('Utilities');
require('Client_PresentMenuUI')


function Client_GameRefresh(game)	
    --Skip if we're not in the game.  We can't use game.SendGameCustomMessage as a spectator
    if (game.Us == nil) then 
        return;
	end
	
	print("Client_GameRefresh called RefreshGame")
	--Check for unread chat
	CheckUnreadChat(game);
	--Refresh the Game info
	--RefreshGame(game); --Do we need to call this?
	
end


--TODO alert when new chat.
function CheckUnreadChat(game)
	local PlayerGameData = Mod.PlayerGameData;
	local groups = {}
	
	if (PlayerGameData == nil)then 
		print("PlayerGameData is nil. No unread chat")
		return;
	end;
	
	
	for i, v in pairs(PlayerGameData) do
		groups[i] = PlayerGameData[i]
		
		if (groups[i].UnreadChat == true) then
			Mod.PlayerGameData[i].UnreadChat = false; --Mark the chat as read so we only show 1 alert. Maybe make this a prompt and continue with alerts upon action
			--Only show an alert if we are not the sender or if it is SinglePlayer (for testing)
			if (game.Us.ID ~= groups[i][groups[i].NumChat].Sender or game.Settings.SinglePlayer == true) then
				local sender = game.Game.Players[groups[i][groups[i].NumChat].Sender].DisplayName(nil, false);
				UI.Alert(groups[i].GroupName .. " has unread chat. Las message was " .. groups[i][groups[i].NumChat].Chat .. " from " .. sender)
			return;
			end;
		end
	end
end