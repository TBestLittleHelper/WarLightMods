require('Utilities');


function Client_GameRefresh(game)	
    --Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized == false) then 
        return;
	end
	print("client game refresh")
	if (Mod.PublicGameData == nil) then return end;

	--Check for new Diplomacy
	if (Mod.Settings.ModDiplomacyEnabled)then
		print("Checking Diplo alert chat")
		if (CheckDiplomacyAlert(game) == true) then return end;
	end;
	
	--Check for unread chat
	print("Checking unread chat")
	CheckUnreadChat(game);
end

--Alert when new chat.
function CheckUnreadChat(game)
	if (skipRefresh == nil or skipRefresh == true)then return end;	

	local PlayerGameData = Mod.PlayerGameData;
	if (PlayerGameData.Chat == nil)then 
		print("PlayerGameData.Chat is nil. No unread chat")
		return;
	end;
	
	local groups = {}
	local markChatAsRead = false; --We only mark chat as read, if we had any unread chat
	local alertMsg = "";
	--Check if alerts are true
	local Alerts = true;
	local PublicGameData = Mod.PublicGameData;
	if (PublicGameData ~= nil)then
		if (PublicGameData[game.Us.ID] ~= nil) then
			Alerts = PublicGameData[game.Us.ID].AlertUnreadChat;
		end;
	end;
	
	for i, v in pairs(PlayerGameData.Chat) do
		groups[i] = PlayerGameData.Chat[i]
		if (groups[i].UnreadChat == true) then
			markChatAsRead = true;
			--Only show an alert if we are not the sender or if it is a SinglePlayer game (for testing)
			if (game.Us.ID ~= groups[i][groups[i].NumChat].Sender or game.Settings.SinglePlayer == true) then				
				if (Alerts)then
					local sender = game.Game.Players[groups[i][groups[i].NumChat].Sender].DisplayName(nil, false);
					if (alertMsg ~= "")then alertMsg = alertMsg .. '\n'end; --Add a new line, if we need it
					alertMsg = alertMsg .. groups[i].GroupName .. " has unread chat. The last chat message is: \n " .. groups[i][groups[i].NumChat].Chat .. " from " .. sender;
				end
			end;			
		end;
	end;	
	if (Alerts == true and alertMsg ~= "")then UI.Alert(alertMsg) end;
	--Mark the chat as read, if we had any unread chat, server side, so we only show 1 alert per group 
	if (markChatAsRead)then
		local payload = {};
		payload.Mod = "Chat"
		payload.Message = "ReadChat";			
		game.SendGameCustomMessage("Marking chat as read...", payload, function(returnValue) end)
	end;
end;



function CheckDiplomacyAlert(game)
	local PlayerGameData = Mod.PlayerGameData;
	--UI.Alert(PlayerGameData.Diplo);
	
	if (PlayerGameData.Diplo == nil)then PlayerGameData.Diplo = {}end;
	if (PlayerGameData.Diplo.HighestAllianceIDSeen == nil)then PlayerGameData.Diplo.HighestAllianceIDSeen = 0 end;		

	----remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.
	HighestAllianceIDSeen = PlayerGameData.Diplo.HighestAllianceIDSeen;
	local HighestProposalIDSeen = 0; 

	if (HighestAllianceIDSeen == 0 and PlayerGameData.Diplo.HighestAllianceIDSeen ~= nil and PlayerGameData.Diplo.HighestAllianceIDSeen > HighestAllianceIDSeen) then
        HighestAllianceIDSeen = PlayerGameData.Diplo.HighestAllianceIDSeen;
    end

    --Check for proposals we haven't alerted the player about yet
    for _,proposal in pairs(filter(PlayerGameData.Diplo.PendingProposals or {}, function(proposal) return HighestProposalIDSeen < proposal.ID end)) do
        DoProposalPrompt(game, proposal);
        if (HighestProposalIDSeen < proposal.ID) then
            HighestProposalIDSeen = proposal.ID;
        end
    end

    --Notify players of new alliances via UI.Alert()
    local unseenAlliances = filter(Mod.PublicGameData.Alliances or {}, function(alliance) return HighestAllianceIDSeen < alliance.ID end);
    if (#unseenAlliances > 0) then
        for _,alliance in pairs(unseenAlliances) do
            if (HighestAllianceIDSeen < alliance.ID) then
                HighestAllianceIDSeen = alliance.ID;
            end
        end

        local msgs = map(unseenAlliances, function(alliance)
            local playerOne = game.Game.Players[alliance.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[alliance.PlayerTwo].DisplayName(nil, false);
			return playerOne .. ' and ' .. playerTwo .. ' are now allied!';
        end);
        local finalMsg = table.concat(msgs, '\n');

        --Let the server know we've seen it.  Wait on doing the alert until after the message is received just to avoid two things appearing on the screen at once.
		local payload = {};
		payload.Mod = 'Diplomacy';
        payload.Message = 'SeenAllianceMessage';
        payload.HighestAllianceIDSeen = HighestAllianceIDSeen;
        game.SendGameCustomMessage('Read receipt...', payload, function(returnValue)
            UI.Alert(finalMsg);
        end);
        return true;
    end

    --Notify players of any pending alerts
    local unseenAlerts = Mod.PlayerGameData.Diplo.Alerts or {};

    if (#unseenAlerts > 0) then
        local msg = table.concat(map(unseenAlerts, function(alert) return alert.Message end), '\n');

        --Let the server know we've seen all of these. Wait on doing the alert until after the message is received just to avoid two things appearing on the screen at once.
		local payload = {};
		payload.Mod = 'Diplomacy';
        payload.Message = 'SeenAlerts';
        game.SendGameCustomMessage('Read receipt...', payload, function(returnValue)
            UI.Alert(msg);
		end);
		return true;
    end
end