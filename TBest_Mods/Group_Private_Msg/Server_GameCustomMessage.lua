require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload);
		elseif (payload.Message == "RemoveGroupMember") then
		--TODO
		elseif (payload.Message == "SendChat") then
		DeliverChat(game,playerID,payload)
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
		local ChatInfo = {};
		ChatInfo.ID = NewIdentity();
		ChatInfo.Sender = playerID;
		ChatInfo.GroupID = payload.GroupID;
		ChatInfo.Chat = payload.Chat;

		if (game.Settings.SinglePlayer) then
			--In single-player, just send the chat msg back to the player for testing.
			
			local data = Mod.PlayerGameData[PlayerID];
			if data.Chat == nil then data.Chat = {} end

			--the ID should always be unique, so it shoudl always be {}
			local chat = data.Chat[ChatInfo.ID] or {};
			if data.Chat[ChatInfo.ID] == nil then data.Chat[ChatInfo.ID] = {} end

			print("earara")
			addToSet(data.Chat[ChatInfo.ID],ChatInfo)
			data.Chat[ChatInfo.ID] = chat;

			Mod.PlayerGameData[PlayerID] = data;
			
			print("Chat added to playerdata ")
			Dump(data)
			Dump(data.Chat[ChatInfo.ID])
			print("dump done")
		
			--ProposalAccepted(ChatInfo, game);
		
		else
			--Write it into the player-specific data
			--TODO for each member in TargetGroupID
			local playerData = Mod.PlayerGameData;
			if (playerData[payload.TargetPlayerID] == nil) then
				playerData[payload.TargetPlayerID] = {};
			end

			local pendingProposals = playerData[payload.TargetPlayerID].PendingProposals or {};
			table.insert(pendingProposals, proposal);
			playerData[payload.TargetPlayerID].PendingProposals = pendingProposals;
			Mod.PlayerGameData = playerData;
		end
	
	
	
	
end

--TODO not public
function NewIdentity()
	local data = Mod.PublicGameData;
	local ret = data.Identity or 1;
	data.Identity = ret + 1;
	Mod.PublicGameData = data;
	return ret;
end

function ProposalAccepted(proposal, game)
	
	-- --Create the alliance
	-- local alliance = {};
	-- alliance.ID = NewIdentity();
	-- alliance.PlayerOne = proposal.PlayerOne;
	-- alliance.PlayerTwo = proposal.PlayerTwo;
	-- alliance.ExpiresOnTurn = game.Game.NumberOfTurns + proposal.NumTurns;

	-- local data = Mod.PublicGameData;
	-- local alliances = data.Alliances or {};

	-- --Do we already have an alliance? Remove it if so.
	-- alliances = filter(alliances, function(a) return not ((a.PlayerOne == alliance.PlayerOne and a.PlayerTwo == alliance.PlayerTwo) or (a.PlayerOne == alliance.PlayerTwo and a.PlayerTwo == alliance.PlayerOne)) end);

	-- --Write it into Mod.PublicGameData for all to see
	-- table.insert(alliances, alliance);
	-- data.Alliances = alliances;
	-- Mod.PublicGameData = data;
end