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
	RefreshGame(game); --Do we need to call this?
	
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
			--Mark the chat as read so we only show 1 alert. Maybe (todo) make this a prompt and continue with alerts upon action
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