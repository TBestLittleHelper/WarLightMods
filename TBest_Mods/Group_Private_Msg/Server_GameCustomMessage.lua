require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload);
		elseif (payload.Message == "RemoveGroupMember") then
		--TODO
		elseif (payload.Message == "SendMessage") then
		--TODO
		else
		error("Payload message not understood (" .. payload.Message .. ")");
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
	
end


function GetGroup(playerID,TargetGroupID,TargetPlayerID,TargetGroupName)
	local playerGameData = Mod.PlayerGameData;
	
	if (playerGameData[playerID] == nil) then 
		print(" nil playerGameData")
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
		playerGameData[playerID] = {[TargetGroupID] = Group}		
		Mod.PlayerGameData = playerGameData;
		
		else
		--TODO check if duplicate member
		print("nice, old group :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID][TargetGroupID]
		Dump(Group)
		Dump(Group.Members)
		addToSet(Group.Members, TargetPlayerID)
		playerGameData[playerID][TargetGroupID] = Group;
		
		Mod.PlayerGameData = playerGameData;
	end

	return Group;
end

