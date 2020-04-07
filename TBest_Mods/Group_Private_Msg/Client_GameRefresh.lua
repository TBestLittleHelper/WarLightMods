require('Client_PresentMenuUI');

function Client_GameRefresh(game)	
    --Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.ChatModEnabled == false) then 
        return;
	end
	
	--Check for unread chat
	print("Checking unread chat")
	CheckUnreadChat(game);
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
			--Only show an alert if we are not the sender or if it is a SinglePlayer game (for testing)
			if (game.Us.ID ~= groups[i][groups[i].NumChat].Sender or game.Settings.SinglePlayer == true) then
				local Alerts = true;
				--Check if alerts are true
				local PublicGameData = Mod.PublicGameData;
				if (PublicGameData ~= nil)then
					if (PublicGameData[game.Us.ID] ~= nil) then
						Alerts = PublicGameData[game.Us.ID].AlertUnreadChat;
					end;
				end;
				if (Alerts)then
					local sender = game.Game.Players[groups[i][groups[i].NumChat].Sender].DisplayName(nil, false);
					UI.Alert(groups[i].GroupName .. " has unread chat. The last chat message is: \n " .. groups[i][groups[i].NumChat].Chat .. " from " .. sender)
					--Mark the chat as read so we only show 1 alert. 
					local payload = {};
					payload.Message = "ReadChat";
					payload.TargetGroupID = i;
					game.SendGameCustomMessage("Marking chat as read...", payload, function(returnValue) end)
				end
			end;
			
			--Check if we have the chat group selected, and if we do add the message to the chat layout
			if (ChatGroupSelectedID ~= nil) then
				if (ChatGroupSelectedID == i)then
					
					--The chat layout VerticalLayoutGroup has alredy been created in presentMenu. We stored it in ChatMsgContainerArray[2]
					ChatLayout = ChatMsgContainerArray[2];
					
					local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout);
					
					local PlayerGameData = Mod.PlayerGameData;	
					local ChatArrayIndex = nil;
					
					if (PlayerGameData[ChatGroupSelectedID].NumChat == nil) then 
						ChatArrayIndex = 0;
						else ChatArrayIndex = PlayerGameData[ChatGroupSelectedID].NumChat
					end;
					
					for i = ChatArrayIndex, ChatArrayIndex do 
						local horz = UI.CreateHorizontalLayoutGroup(horzMain);
						
						--Chat Sender
						ChatSenderbtn = UI.CreateButton(horz).SetPreferredWidth(150).SetPreferredHeight(8)		
						if (PlayerGameData[ChatGroupSelectedID][i].Sender == -1) then
							ChatSenderbtn.SetText("Mod Info").SetColor('#880085')		
							else
							ChatSenderbtn.SetText(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].DisplayName(nil, false))
							.SetColor(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].Color.HtmlColor)	
						end
						--Chat messages
						UI.CreateLabel(horz)
						.SetFlexibleWidth(1)
						.SetFlexibleHeight(1)
						.SetText(PlayerGameData[ChatGroupSelectedID][i].Chat)		
					end						
				end;
			end
			--Break the loop, we only want to do 1 action on each refresh
			return;
		end;
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