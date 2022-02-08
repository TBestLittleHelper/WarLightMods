require("Utilities")

function Client_GameRefresh(game)
	if (Mod.Settings.Version ~= 2) then
		return
	end

	--Skip if we're not in the game or if the game is over.
	if (game.Us == nil or Mod.PublicGameData.GameFinalized) then
		return
	end
	print("client game refresh")
	if (Mod.PublicGameData == nil) then
		return
	end

	--Check for unread chat
	print("Checking unread chat")
	CheckUnreadChat(game)
end

--Alert when new chat.
function CheckUnreadChat(game)
	if (skipRefresh == nil or skipRefresh == true) then
		return
	end

	local PlayerGameData = Mod.PlayerGameData
	if (PlayerGameData.Chat == nil) then
		print("PlayerGameData.Chat is nil. No unread chat")
		return
	end

	local groups = {}
	local markChatAsRead = false --We only mark chat as read, if we had any unread chat
	local alertMsg = ""
	--Check if alerts are true
	local Alerts = true
	local PublicGameData = Mod.PublicGameData
	if (PublicGameData ~= nil) then
		if (PublicGameData[game.Us.ID] ~= nil) then
			Alerts = PublicGameData[game.Us.ID].AlertUnreadChat
		end
	end

	for i, v in pairs(PlayerGameData.Chat) do
		groups[i] = PlayerGameData.Chat[i]
		if (groups[i].UnreadChat == true) then
			markChatAsRead = true
			--Only show an alert if we are not the sender (or if it is a SinglePlayer game for testing)
			if (game.Us.ID ~= groups[i][groups[i].NumChat].Sender or game.Settings.SinglePlayer == true) then
				if (Alerts) then
					local sender = "Mod Info"
					if (game.Game.Players[groups[i][groups[i].NumChat].Sender] ~= nil) then
						sender = game.Game.Players[groups[i][groups[i].NumChat].Sender].DisplayName(nil, false)
					end

					if (alertMsg ~= "") then
						alertMsg = alertMsg .. "\n"
					end --Add a new line, if we need it
					alertMsg =
						alertMsg ..
						groups[i].GroupName ..
							" has unread chat. The last message: \n " .. groups[i][groups[i].NumChat].Chat .. " from " .. sender
				end
			end
		end
	end
	if (Alerts == true and alertMsg ~= "") then
		UI.Alert(alertMsg)
	end
	--Mark the chat as read, if we had any unread chat, server side, so we only show 1 alert per group
	if (markChatAsRead) then
		local payload = {}
		payload.Mod = "Chat"
		payload.Message = "ReadChat"
		game.SendGameCustomMessage(
			"Marking chat as read...",
			payload,
			function(returnValue)
			end
		)
	end
end
