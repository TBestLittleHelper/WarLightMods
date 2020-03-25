require('Client_PresentMenuUI');

function Client_GameRefresh(game)	
    --Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.ChatModEnabled == false) then 
        return;
	end
	
	--Check for unread chat
	CheckUnreadChat(game);
	--Refresh the UI for the player info
	if (CheckIfRefresh(game) == true)then
		print("Client_GameRefresh called RefreshChat")
	--TODO	RefreshChat();
	end;
end

--Alert when new chat.
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
			--Mark the chat as read so we only show 1 alert. 
			local payload = {};
			payload.Message = "ReadChat";
			payload.TargetGroupID = i;
			game.SendGameCustomMessage("Marking chat as read...", payload, function(returnValue) 
				--Only show an alert if we are not the sender or if it is a SinglePlayer game (for testing)
				if (game.Us.ID ~= groups[i][groups[i].NumChat].Sender or game.Settings.SinglePlayer == true) then
					local sender = game.Game.Players[groups[i][groups[i].NumChat].Sender].DisplayName(nil, false);
					UI.Alert(groups[i].GroupName .. " has unread chat. The last chat message is: \n " .. groups[i][groups[i].NumChat].Chat .. " from " .. sender)
					return;
				end;
			end)
		end
	end		
end

--Called by Client_GameRefresh
function CheckIfRefresh(gameRefresh)
	if(skipRefresh == true or skipRefresh == nil)then
		print('skipRefresh chat') 
		return false;
	end;
	--We don't want to refresh if the PresentMenuUi has not been opned. gameRefresh is called immidietaly when a game is created so we need this check
	if (ClientGame == nil or ChatContainer == nil or GroupMembersNames == nil)then
		print("refresh suppressed.")
		return false;
	end;

	return true;
end;