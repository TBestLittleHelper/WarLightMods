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
			UI.Alert(groups[i].GroupName .. " has unread chat. Las message was " .. groups[i][groups[i].NumChat].Chat .. " from " .. groups[i][groups[i].NumChat].Sender)
			Mod.PlayerGameData[i].UnreadChat = false; --Return so we only show 1 alert. Maybe make this a prompt and continue with alerts upon action
			return;
		end
	end
end