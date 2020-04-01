require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (Mod.PublicGameData.ChatModEnabled == false)then return end;
	
	--Sorted according to what is used most
	if (payload.Message == "ReadChat") then
		--Mark as read
		ReadChat(playerID,payload)
		elseif (payload.Message == "SendChat") then
		--DeliverChat
		DeliverChat(game,playerID,payload)
		
		elseif (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload);
		
		elseif (payload.Message == "RemoveGroupMember") then
		--RemoveFromGroup
		RemoveFromGroup(game,playerID,payload);
		
		elseif (payload.Message == "LeaveGroup") then
		--Leave group
		LeaveGroup(game,playerID,payload)
		
		elseif (payload.Message == "DeleteGroup") then
		--Delete group
		DeleteGroup(game,playerID,payload)
		
		elseif (payload.Message == "ClearData") then
		--Remove all playerGameData. Useful for testing (works only for admin)
		ClearData(game,playerID);		
	end
end	

function RemoveFromGroup (game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	
	local group = {};
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("group to be removed not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
		
		--Check if the TargetPlayerID is the owner 
		elseif(TargetPlayerID == playerGameData[playerID][TargetGroupID].Owner) then
		print("Can't remove the owner of a group")
		return;
		
		else
		print("removing " .. TargetPlayerID .. " from  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		--Remove the group from the playerGameData of the removed player, if it's not an AI 
		if not(game.Game.Players[TargetPlayerID].IsAI)then
			Mod.PlayerGameData[TargetPlayerID][TargetGroupID]=nil;
		end;
		--Update all other group members
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
		
		--Send a chat msg to the group chat
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " was removed from " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
	end
end

function LeaveGroup (game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = playerID;
	
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("group to leave from not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
	end	
	--Check if the TargetPlayerID is the owner 
	if(TargetPlayerID == playerGameData[playerID][TargetGroupID].Owner) then
		print("The owner of a group can't leave. They must use delete group")
		return;
	end
	
	print(playerID .. " left  :" .. TargetGroupID .. " groupID")
	--Remove the player
	local Group = playerGameData[playerID][TargetGroupID]
	removeFromSet(Group.Members, TargetPlayerID)
	--Update the players data
	for Members, v in pairs (Group.Members) do
		playerGameData[Members][TargetGroupID] = Group;
	end
	Mod.PlayerGameData = playerGameData;
	--Add a msg to the chat
	payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " left " .. Group.GroupName;
	DeliverChat(game,playerID,payload)
end

function AddToGroup(game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	local TargetGroupName = payload.TargetGroupName;
	
	print(TargetPlayerID .. " targetplayer")
	print(TargetGroupID .. " TargetGroupID")
	
	if (playerGameData[playerID] == nil) then 
		--if nill, make an empty table where we can place GroupID
		playerGameData[playerID] = {};
		print(" {} playerGameData")
		else
		print("dump playerGameData")
		Dump(playerGameData[playerID])
	end
	
	local Group ={};
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("new group " .. TargetGroupID)
		Group = {
			Members = {},
			Owner = playerID,
			GroupName = TargetGroupName,
			GroupID = TargetGroupID,
			Color = randomColor(),
			UnreadChat = false,
		}
		--addToSet(set, key)
		addToSet(Group.Members, playerID)
		addToSet(Group.Members, TargetPlayerID)
		--Save to mod storage
		playerGameData[playerID][TargetGroupID] = Group; 
		
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
		--Send a msg to the chat of the group
		payload.Chat = game.Game.Players[Group.Owner].DisplayName(nil,false) .. " created " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " was added to " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
		
		else
		print("nice, old group :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		
		--Check if the player is already in the group. If so, return
		if (Group.Members[TargetPlayerID] ~= nil) then
			print(TargetPlayerID .. " is alredy in the group");
			return;
		end;
		--Add the player
		addToSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		--Update Storage
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
		--Send a msg to the chat of the group
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. "  was added to " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
	end
end

function DeliverChat(game,playerID,payload)
	local playerGameData = Mod.PlayerGameData
	local data = playerGameData[playerID];
	local TargetGroupID = payload.TargetGroupID
	
	local ChatInfo = {};
	ChatInfo.Sender = playerID;
	ChatInfo.Chat = payload.Chat;			
	
	local ChatArrayIndex;
	if (data[TargetGroupID] == nil) then 
		ChatArrayIndex = 1;
		else ChatArrayIndex = #data[TargetGroupID] +1
	end;
	
	print("Chat received " .. ChatInfo.Chat .. " to " .. TargetGroupID .. " from " .. ChatInfo.Sender .. " total group chat's : " .. ChatArrayIndex)
	
	--use the ChatArrayIndex. We want the chat msg to be stored in an array	format
	if data[TargetGroupID][ChatArrayIndex] == nil then data[TargetGroupID][ChatArrayIndex] = {} end
	data[TargetGroupID].NumChat = ChatArrayIndex;
	data[TargetGroupID][ChatArrayIndex] = {};
	data[TargetGroupID][ChatArrayIndex] = ChatInfo;
	--Mark the chat as unread for everyone in the group.
	data[TargetGroupID].UnreadChat = true;
	playerGameData[playerID] = data;
	
	UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
end

function ReadChat(playerID, payload)
	local playerGameData = Mod.PlayerGameData;
	playerGameData[playerID][payload.TargetGroupID].UnreadChat = false;
	Mod.PlayerGameData = playerGameData;
end

function UpdateAllGroupMembers(game, playerID, groupID , playerGameData)
	local playerGameData = playerGameData;
	local ReffrencePlayerData = playerGameData[playerID]; --We already updated the info for this player. Now we need to sync that to the other players
	
	local Group = ReffrencePlayerData[groupID]
	local outdatedPlayerData;
	
	--Update playerGameData for each member
	for Members, v in pairs (Group.Members) do 
		--Make sure we don't add AI's. This code is useful for testing in SP and as a safety
		if not(game.Game.Players[Members].IsAI)then
			outdatedPlayerData = playerGameData[Members];				
			--if nil, make an empty table where we can place GroupID
			if (outdatedPlayerData == nil) then 
				outdatedPlayerData = {};				
			end
			outdatedPlayerData[groupID] = Group;
			playerGameData[Members] = outdatedPlayerData;
		end		
	end;
	--Finally write back to Mod.PlayerGameData
	Mod.PlayerGameData = playerGameData;
end

function DeleteGroup(game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local data = playerGameData[playerID];
	
	local TargetGroupID = payload.TargetGroupID;
	local Group = data[TargetGroupID]
	
	--Make sure only the creator/owner of a group can delete it
	if (playerID ~= data[TargetGroupID].Owner)then
		print("You can't delete since you are not the owner of the group")
		return;
	end;
	--Set groupID data to nil for each player
	for Members, v in pairs (Group.Members) do
		--Make sure we skip AI's. This code is useful for testing in SP and as a safety as AI's can't have playerGameData
		if not(game.Game.Players[Members].IsAI)then			
			playerGameData[Members][TargetGroupID] = nil;
		end
	end
	Mod.PlayerGameData = playerGameData;
	print("Deleted Group " .. TargetGroupID)		
end

--Admin option, to reuse the same game as a test by removing all playerdata
function ClearData(game,playerID);
	if (playerID == 69603)then --My playerID
		local playerGameData = Mod.PlayerGameData;		
		for Players in pairs (playerGameData) do
			print("Deleted playerGameData for " .. Players)
			playerGameData[Players] = {};
		end
		Mod.PlayerGameData = playerGameData;
		--Set a bool flag to false
		local publicGameData = Mod.PublicGameData
		publicGameData.ChatModEnabled = false;
		Mod.PublicGameData = publicGameData;
	end;
end

function TurnDivider(turnNumber)
	local playerGameData = Mod.PlayerGameData;
	local ChatArrayIndex;
	
	local ChatInfo = {};
	ChatInfo.Sender = -1; --The Mod is the sender
	ChatInfo.Chat = " ------ End of turn " .. turnNumber+1 .. " ------";	

	--For All playerGameData
	for playerID, player in pairs (playerGameData) do
		--For ALL groups
		for TargetGroupID, group in pairs (playerGameData[playerID])do
			--ADD a turn chat
			if (playerGameData[playerID][TargetGroupID] == nil) then 
				ChatArrayIndex = 1;
				else ChatArrayIndex = #playerGameData[playerID][TargetGroupID] +1
			end;					
			playerGameData[playerID][TargetGroupID].NumChat = ChatArrayIndex;
			playerGameData[playerID][TargetGroupID][ChatArrayIndex] = {};
			playerGameData[playerID][TargetGroupID][ChatArrayIndex] = ChatInfo;
		end
	end
	--Save playerGameData
	Mod.PlayerGameData = playerGameData;
end