require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	Game = game; --Global var. needed for test TODO remove
	
	if (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload);
		
		elseif (payload.Message == "RemoveGroupMember") then
		--RemoveFromGroup
		RemoveFromGroup(game,playerID,payload);
		
		elseif (payload.Message == "SendChat") then
		--DeliverChat
		DeliverChat(game,playerID,payload)
		
		elseif (payload.Message == "DeleteGroup") then
		--Delete group
		
		elseif (payload.Message == "LeaveGroup") then
		--Leave group
		
		elseif (payload.Message == "ClearData") then
		ClearData(game,playerID);
		
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
		
		--Check if the TargetPlayerID is the owner 
		elseif(TargetPlayerID == playerGameData[playerID][TargetGroupID].Owner) then
		print("Can't remove the owner of a group")
		return;
		
		else
		print("removing " .. TargetPlayerID .. " from  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		UpdateAllGroupMembers(playerID, TargetGroupID,playerGameData); --TODO test
	end
	--If group has no members, remove group TODO or add option to delete
end
function LeaveGroup (game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	
	local group = {};
	if (playerGameData[playerID] == nil or playerGameData[playerID][TargetGroupID] == nil)then
		print("group to leave from not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
		
		--Check if the TargetPlayerID is the owner 
		elseif(TargetPlayerID == playerGameData[playerID][TargetGroupID].Owner) then
		print("The owner of a group can't leave")
		return;
		
		else
		print(playerID .. " left  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		UpdateAllGroupMembers(playerID, TargetGroupID, playerGameData);
	end	
end

--TODO this is a bit redundant
function AddToGroup(game,playerID,payload)
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	local TargetGroupName = payload.TargetGroupName;
	
	print(TargetPlayerID .. " targetplayer")
	print(TargetGroupID .. " TargetGroupID")
	
	local group = {};
	group = GetGroup(playerID, TargetGroupID,TargetPlayerID,TargetGroupName)	
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
		
		UpdateAllGroupMembers(playerID, TargetGroupID,playerGameData);
		
		else
		print("nice, old group :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		Dump(Group.Members)
		addToSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		UpdateAllGroupMembers(playerID, TargetGroupID,playerGameData);
	end
	
	return Group;
end

function DeliverChat(game,playerID,payload)
	local playerGameData = Mod.PlayerGameData
	local data = playerGameData[playerID];
	local TargetGroupID = payload.TargetGroupID
	local TimeStamp = payload.Time;
	
	local ChatInfo = {};
	ChatInfo.Sender = playerID;
	ChatInfo.Chat = payload.Chat;			--TODO maybe add support for the time a msg was sent
	ChatInfo.Time = TimeStamp;
	
	local ChatArrayIndex;
	if (data[TargetGroupID] == nil) then 
		ChatArrayIndex = 1;
		else ChatArrayIndex = #data[TargetGroupID] +1
	end;
	
	print("Chat received " .. ChatInfo.Chat .. " to " .. TargetGroupID .. " from " .. ChatInfo.Sender .. " total group chat's : " .. ChatArrayIndex)
	
	--use the ChatArrayIndex. We want the chat msg to be stored in an array	
	if data[TargetGroupID][ChatArrayIndex] == nil then data[TargetGroupID][ChatArrayIndex] = {} end
	data[TargetGroupID].NumChat = ChatArrayIndex;
	data[TargetGroupID][ChatArrayIndex] = {};
	data[TargetGroupID][ChatArrayIndex] = ChatInfo;
	playerGameData[playerID] = data;
	
	
	UpdateAllGroupMembers(playerID, TargetGroupID,playerGameData);
	
end

function UpdateAllGroupMembers(playerID, groupID , playerGameData)
	local playerGameData = playerGameData;
	local ReffrencePlayerData = playerGameData[playerID]; --We already updated the info for this player. Now we need to sync that to the other players
	
	
	local GroupMembers = ReffrencePlayerData[groupID] --todo error nil
	local outdatedPlayerData;
	
	
	--Update playerGameData for each member
	for Members in pairs (GroupMembers.Members) do 
		--Make sure we don't add AI's. This code is useful for testing in SP and as a safety
		if not(Game.Game.Players[Members].IsAI)then
		print(playerID)
		print("~~~~~~~~")

		--	if (Members ~= playerID)then
				outdatedPlayerData = playerGameData[Members];				
				--if nil, make an empty table where we can place GroupID
				if (outdatedPlayerData == nil) then 
					outdatedPlayerData = {};
					print("outdatedPlayerData= {} ")
					else
					print("dump outdatedPlayerData")
					Dump(outdatedPlayerData)
				end
				
				outdatedPlayerData[groupID] = GroupMembers;
				playerGameData[Members] = outdatedPlayerData;
		--	end;
			
			
		end
		
		
	end;
	--Finally write back to Mod.PlayerGameData
	Mod.PlayerGameData = playerGameData;
end

--Admin option, to reuse the same game as a test by removing all playerdata
function ClearData(game,playerID);
	if (playerID == 69603)then

	local playerGameData = Mod.PlayerGameData;
	
	for Players in pairs (playerGameData) do
		print("Deleted playerGameData for " .. Players)
		playerGameData[Players] = {};
	end
	Mod.PlayerGameData = playerGameData;
	end;
end