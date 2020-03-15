require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload);
		elseif (payload.Message == "RemoveGroupMember") then
		--RemoveFromGroup
		RemoveFromGroup(game,playerID,payload);
		elseif (payload.Message == "SendChat") then
		DeliverChat(game,playerID,payload)
		--DeliverChat
		else
		error("Payload message not understood (" .. payload.Message .. ")");
	end
end	
--TODO maybe make sure only owner can remove? The others can only leave?
function RemoveFromGroup (game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	
	local group = {};
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("group to be removed not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
		else
		print("removing " .. TargetPlayerID .. " from  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		Mod.PlayerGameData = playerGameData;	
		UpdateAllGroupMembers(playerID, TargetGroupID); --TODO test
	end
	--If group has no members, remove group TODO or add option to delete
end
function LeaveGroup (game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	
	local group = {};
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("group to be leave from not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
		else
		print(playerID .. " left  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		Mod.PlayerGameData = playerGameData;	
		UpdateAllGroupMembers(playerID, TargetGroupID);
	end	
end

--TODO this is a bit redundant
function AddToGroup(game,playerID,payload)
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	local TargetGroupName = payload.TargetGroupName
	
	print(TargetPlayerID .. " targetplayer")
	print(TargetGroupID .. " TargetGroupID")
	
	local group = {};
	group = GetGroup(playerID, TargetGroupID,TargetPlayerID,TargetGroupName)	
	UpdateAllGroupMembers(playerID, TargetGroupID);
end


function GetGroup(playerID,TargetGroupID,TargetPlayerID,TargetGroupName)
	local playerGameData = Mod.PlayerGameData;
	
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
		}
		--addToSet(set, key)
		addToSet(Group.Members, playerID)
		addToSet(Group.Members, TargetPlayerID)
		--Save to mod storage
		playerGameData[playerID][TargetGroupID] = Group; 
		
		Mod.PlayerGameData = playerGameData;
		
		else
		print("nice, old group :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		Dump(Group.Members)
		addToSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		Mod.PlayerGameData = playerGameData;
	end
	
	return Group;
end

function DeliverChat(game,PlayerID,payload)
	local playerGameData = Mod.PlayerGameData
	local data = playerGameData[PlayerID];
	local TargetGroupID = payload.TargetGroupID
	
	local ChatInfo = {};
	ChatInfo.Sender = PlayerID;
	ChatInfo.Chat = payload.Chat;			--TODO maybe add support for the time a msg was sent
	
	local ChatArrayIndex;
	if (data[TargetGroupID] == nil) then 
		ChatArrayIndex = 1;
		else ChatArrayIndex = #data[TargetGroupID] +1
	end;
	
	print("Chat recived " .. ChatInfo.Chat .. " to " .. TargetGroupID .. " from " .. ChatInfo.Sender .. " total group chat's : " .. ChatArrayIndex)
	
	--use the ChatArrayIndex. We want the chat msg to be stored in an array	
	if data[TargetGroupID][ChatArrayIndex] == nil then data[TargetGroupID][ChatArrayIndex] = {} end
	data[TargetGroupID].NumChat = ChatArrayIndex;
	data[TargetGroupID][ChatArrayIndex] = {};
	data[TargetGroupID][ChatArrayIndex] = ChatInfo;
	playerGameData[PlayerID] = data;
	
	Mod.PlayerGameData = playerGameData;	
	print(Mod.PlayerGameData[PlayerID][TargetGroupID][ChatArrayIndex].Chat .. " was stored in Mod.PlayerGameData")
	
	--For SP We don't need to store data for the PlayerGameData[AI]
	--Multiplayer update other group members
	if not(game.Settings.SinglePlayer) then
		UpdateAllGroupMembers(playerID, TargetGroupID);
	end;
end


function UpdateAllGroupMembers(PlayerID, groupID)
	
	
end