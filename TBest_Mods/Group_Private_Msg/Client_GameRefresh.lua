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
		Dump(groups[i])
		if (groups[i].UnreadChat == true) then
			print("true unread chat for group " .. groups[i].GroupName)
			print(groups[i][groups[i].NumChat])
			UI.Alert(groups[i].GroupName .. " has unread chat. Las message was " .. groups[i][groups[i].NumChat])
			Mod.PlayerGameData[i].UnreadChat = false; --Return so we only show 1 alert. Maybe make this a prompt and continue when selected
			return;
		end
	end
	
	-- if (ChatGroupSelectedID ~= nil)then
		-- if (PlayerGameData[ChatGroupSelectedID].NumChat == nil) then 
			-- ChatArrayIndex = 0;
			-- ChatMessageText.SetInteractable(true)
			-- else ChatArrayIndex = PlayerGameData[ChatGroupSelectedID].NumChat
		-- end;
	-- end	
end



-- Sorry, the mod "Better Chat" has failed.  Error: 
-- pcall failure in function Client_GameRefresh ret=2 [string "require('Utilities');..."]:35: attempt to concatenate a nil value (global 'unreadChat')