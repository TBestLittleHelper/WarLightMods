require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	--If the game is over, return
	if (Mod.PublicGameData.GameFinalized == true)then return end;
	Dump(payload)

	--TODO we should add payload.MOD to the others as well
	--Sorted according to what is used most
	if (payload.Message == "ReadChat") then
		--Mark as read
		ReadChat(playerID)
		
		elseif (payload.Message == "SendChat") then
		--DeliverChat
		DeliverChat(game,playerID,payload, setReturnTable)
		
		elseif (payload.Message == "AddGroupMember") then
		--Add to group
		AddToGroup(game,playerID,payload,setReturnTable);
		
		elseif (payload.Message == "RemoveGroupMember") then
		--RemoveFromGroup
		RemoveFromGroup(game,playerID,payload,setReturnTable);
		
		elseif (payload.Message == "LeaveGroup") then
		--Leave group
		LeaveGroup(game,playerID,payload,setReturnTable)
		
		elseif (payload.Message == "DeleteGroup") then
		--Delete group
		DeleteGroup(game,playerID,payload,setReturnTable)
		
		elseif (payload.Message == "SaveSettings") then
		--Save settings
		SaveSettings(game, playerID, payload,setReturnTable)

		--Diplomacy
		elseif(payload.Mod == 'Diplomacy' and Mod.Settings.ModDiplomacyEnabled == true)then
			if (payload.Message == "Propose") then
			Propose(game,playerID, payload)
			elseif (payload.Message == "AcceptProposal" or "DeclineProposal") then
			ProposeDeclineAccept(game,playerID, payload)
			elseif (payload.Message == "SeenAllianceMessage") then
			Propose(game,playerID, payload, setReturnTable)
			elseif (payload.Message == "SeenAlerts") then
			Propose(game,playerID, payload, setReturnTable)
			else return end;
		
		--Gift gold
		elseif (payload.Message == "GiftGold" and Mod.Settings.ModGiftGoldEnabled == true) then
		GiftGold(game,playerID, payload, setReturnTable)
		
		elseif (payload.Message == "ClearData") then
		--Remove all playerGameData. Useful for testing (works only for admin)
		ClearData(game,playerID);		

		else
		error("Payload message not understood (" .. payload.Message .. ")");
	end
end	

function RemoveFromGroup (game,playerID,payload,setReturnTable)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	
	local group = {};
	if (playerGameData[playerID].chat == nil or playerGameData[playerID].chat[TargetGroupID] == nil)then
		print("group to be removed not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
		
		--Check if the TargetPlayerID is the owner 
		elseif(TargetPlayerID == playerGameData[playerID].chat[TargetGroupID].Owner) then
		print("Can't remove the owner of a group")
		return;
		
		else
		print("removing " .. TargetPlayerID .. " from  :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID].chat[TargetGroupID]
		removeFromSet(Group.Members, TargetPlayerID)
		playerGameData[playerID].chat[TargetGroupID] = Group;
		
		--Remove the group from the playerGameData.chat of the removed player, if it's not an AI 
		if not(game.Game.Players[TargetPlayerID].IsAI)then
			Mod.playerGameData.chat[TargetPlayerID][TargetGroupID]=nil;
		end;
		--Update all other group members
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData.chat);
		
		--Send a chat msg to the group chat
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " was removed from " .. Group.GroupName;
		DeliverChat(game,playerID,payload, setReturnTable)
	end
end

function LeaveGroup (game,playerID,payload,setReturnTable)
	local playerGameData = Mod.PlayerGameData;
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = playerID;
	
	if (playerGameData[playerID].chat == nil or playerGameData[playerID].chat[TargetGroupID] == nil)then
		print("group to leave from not found " .. TargetGroupID)
		return; --Group can't be found. Do nothing
	end	
	--Check if the TargetPlayerID is the owner 
	if(TargetPlayerID == playerGameData[playerID].chat[TargetGroupID].Owner) then
		print("The owner of a group can't leave. They must use delete group")
		return;
	end
	
	print(playerID .. " left  :" .. TargetGroupID .. " groupID")
	--Remove the player
	local Group = playerGameData[playerID].chat[TargetGroupID]
	removeFromSet(Group.Members, TargetPlayerID)
	--Update the players data
	for Members, v in pairs (Group.Members) do
		playerGameData[Members].chat[TargetGroupID] = Group;
	end
	Mod.PlayerGameData = playerGameData;
	--Add a msg to the chat
	payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " left " .. Group.GroupName;
	DeliverChat(game,playerID,payload,setReturnTable)
end

function AddToGroup(game,playerID,payload,setReturnTable)
	local playerGameData = Mod.PlayerGameData;
	
	local TargetGroupID = payload.TargetGroupID;
	local TargetPlayerID = payload.TargetPlayerID;
	local TargetGroupName = payload.TargetGroupName;
	
	print(TargetPlayerID .. " targetplayer")
	print(TargetGroupID .. " TargetGroupID")
	
	if (playerGameData[playerID].chat == nil) then 
		--if nill, make an empty table where we can place GroupID
		playerGameData[playerID].chat = {};
		print(" {} playerGameData.chat")
		else
		print("dump playerGameData.chat")
		Dump(playerGameData[playerID].chat)
	end
	
	local Group ={};
	if (playerGameData[playerID].chat == nil or playerGameData[playerID].chat[TargetGroupID] == nil)then
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
		playerGameData[playerID].chat[TargetGroupID] = Group; 
		
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
		--Send a msg to the chat of the group
		payload.Chat = game.Game.Players[Group.Owner].DisplayName(nil,false) .. " created " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. " was added to " .. Group.GroupName;
		DeliverChat(game,playerID,payload)
		
		else
		print("nice, old group :" .. TargetGroupID .. " ID")
		Group = playerGameData[playerID].chat[TargetGroupID]
		
		--Check if the player is already in the group. If so, return
		if (Group.Members[TargetPlayerID] ~= nil) then
			print(TargetPlayerID .. " is alredy in the group");
			return;
		end;
		--Add the player
		addToSet(Group.Members, TargetPlayerID)
		playerGameData[playerID].chat[TargetGroupID] = Group;
		--Update Storage
		UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
		--Send a msg to the chat of the group
		payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil,false) .. "  was added to " .. Group.GroupName;
		DeliverChat(game,playerID,payload,setReturnTable)
	end
end

function DeliverChat(game,playerID,payload,setReturnTable)
	local playerGameData = Mod.PlayerGameData
	local data = playerGameData[playerID].chat;
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
	playerGameData[playerID].chat = data;
	
	UpdateAllGroupMembers(game, playerID, TargetGroupID,playerGameData);
	local Alerts = true;
	local PublicGameData = Mod.PublicGameData;
	if (PublicGameData ~= nil)then
		if (PublicGameData[playerID] ~= nil) then
			Alerts = PublicGameData[playerID].AlertUnreadChat;
		end;
	end;
	if (Alerts)then
	setReturnTable({Status = "Chat sent"}) 
	end;
end

function ReadChat(playerID)
	local playerGameData = Mod.PlayerGameData;
	--Mark chat as read
	for i, v in pairs(playerGameData[playerID].chat) do
		playerGameData[playerID].chat[i].UnreadChat = false;
	end;
	Mod.PlayerGameData = playerGameData;
end

function UpdateAllGroupMembers(game, playerID, groupID , playerGameData)
	local playerGameData = playerGameData;
	local ReffrencePlayerData = playerGameData[playerID].chat; --We already updated the info for this player. Now we need to sync that to the other players
	
	local Group = ReffrencePlayerData[groupID]
	local outdatedPlayerData;
	
	--Update playerGameData for each member
	for Members, v in pairs (Group.Members) do 
		--Make sure we don't add AI's. This code is useful for testing in SP and as a safety
		if not(game.Game.Players[Members].IsAI)then
			outdatedPlayerData = playerGameData[Members].chat;				
			--if nil, make an empty table where we can place GroupID
			if (outdatedPlayerData == nil) then 
				outdatedPlayerData = {};				
			end
			outdatedPlayerData[groupID] = Group;
			playerGameData[Members].chat = outdatedPlayerData;
		end		
	end;
	--Finally write back to Mod.PlayerGameData
	Mod.PlayerGameData = playerGameData;
end

function DeleteGroup(game,playerID,payload)
	local playerGameData = Mod.PlayerGameData;
	local data = playerGameData[playerID].chat;
	
	local TargetGroupID = payload.TargetGroupID;
	local Group = data[TargetGroupID]
	
	--Make sure only the creator/owner of a group can delete it
	if (playerID ~= data[TargetGroupID].Owner)then
		print("You can't delete since you are not the owner of the group")
		return;
	end;
	--Set groupID data to nil for each player
	for Members, v in pairs (Group.Members) do
		--Make sure we skip AI's. This code is useful for testing in SP and as a safety as AI's can't have playerGameData.chat
		if not(game.Game.Players[Members].IsAI)then			
			playerGameData[Members].chat[TargetGroupID] = nil;
		end
	end
	Mod.PlayerGameData = playerGameData;
	print("Deleted Group " .. TargetGroupID)		
end

function SaveSettings(game,playerID, payload)
	Dump(payload)
	
	PublicGameData = Mod.PublicGameData;
	if (PublicGameData == nil)then PublicGameData = {} end;
	if (PublicGameData[playerID] == nil)then PublicGameData[playerID] = {} end;
	
	PublicGameData[playerID].AlertUnreadChat = payload.AlertUnreadChat;
	PublicGameData[playerID].EachGroupButton = payload.EachGroupButton;
	PublicGameData[playerID].NumPastChat = payload.NumPastChat;
	PublicGameData[playerID].SizeX = payload.SizeX;
	PublicGameData[playerID].SizeY = payload.SizeY;
	
	Mod.PublicGameData = PublicGameData;
end;

--Removing all Mod data when a game is over (also useful during development.)
function ClearData(game,playerID)
	--TODO update serverside check. Remove my playerID cond
	if (playerID == 69603)then --My playerID
		--Remove all playerGameData
		local playerGameData = Mod.PlayerGameData;		
		for Players in pairs (playerGameData) do
			print("Deleted playerGameData.chat for " .. Players)
			playerGameData[Players].chat = {};
		end
		
		Mod.PlayerGameData = playerGameData;
		
		--Remove all publicGameData and set a bool flag to false
		local publicGameData = Mod.PublicGameData
		publicGameData = {};
		publicGameData.ChatModEnabled = false;
		Mod.PublicGameData = publicGameData;
	
	else
		--This is a server side safety check. If we end up here, the game should always be over.
		--Check if there are any players still playing. If there is not, delete all playerGameData.chat
		local numAlive = 0; --If we have 2 or more alive game is ongoing.
		local Teams = {};
		local numTeamAlive = 0; --If we have teams, num teams alive 
		
		for playerID, player in pairs (game.Game.Players)do
			if (IsAlive(playerID, game)) then
				numAlive = numAlive+1;
				if (Teams[game.Game.Players[playerID].Team] == nil) then
					Teams[game.Game.Players[playerID].Team] = true;
					numTeamAlive = numTeamAlive +1;
				end
			end
		end
		if (numTeamAlive > 1)then return end; --More then 1 team alive
		if (Teams[-1] == true)then 	--If there are no teams (-1 is a special value for no teams)
			if (numAlive > 1)then return end; --And there are more then 1 alive, return
		end;		
		ClearData(game,69603);
	end;
end

function TurnDivider(turnNumber)
	local playerGameData = Mod.PlayerGameData;
	local ChatArrayIndex;
	
	local ChatInfo = {};
	ChatInfo.Sender = -1; --The Mod is the sender
	ChatInfo.Chat = " ------ End of turn " .. turnNumber+1 .. " ------";	
	
	--For All playerGameData.chat
	for playerID, player in pairs (playerGameData) do
		--For ALL groups
		if(playerGameData[playerID].chat ~= nil)then
			for TargetGroupID, group in pairs (playerGameData[playerID].chat)do
				--ADD a turn chat
				if (playerGameData[playerID].chat[TargetGroupID] == nil) then 
					ChatArrayIndex = 1;
					else ChatArrayIndex = #playerGameData[playerID].chat[TargetGroupID] +1
				end;					
				playerGameData[playerID].chat[TargetGroupID].NumChat = ChatArrayIndex;
				playerGameData[playerID].chat[TargetGroupID][ChatArrayIndex] = {};
				playerGameData[playerID].chat[TargetGroupID][ChatArrayIndex] = ChatInfo;
			end
		end
	end
	--Save playerGameData
	Mod.PlayerGameData = playerGameData;
end

function GiftGold(game, playerID, payload, setReturnTable)
	if (playerID == payload.TargetPlayerID) then
		setReturnTable({ Message = "You can't gift yourself" });
		return;
	end
	local goldSending = payload.Gold;

	local goldHave = game.ServerGame.LatestTurnStanding.NumResources(playerID, WL.ResourceType.Gold);

	if (goldHave < goldSending) then
		setReturnTable({ Message = "You can't gift " .. goldSending .. " when you only have " .. goldHave });
		return;
	end

	local targetPlayer = game.Game.Players[payload.TargetPlayerID];
	local targetPlayerHasGold = game.ServerGame.LatestTurnStanding.NumResources(targetPlayer.ID, WL.ResourceType.Gold);
	
	--Subtract goldSending from ourselves, add goldSending to target
	game.ServerGame.SetPlayerResource(playerID, WL.ResourceType.Gold, goldHave - goldSending);
	game.ServerGame.SetPlayerResource(targetPlayer.ID, WL.ResourceType.Gold, targetPlayerHasGold + goldSending);
	setReturnTable({ Message = "Sent " .. targetPlayer.DisplayName(nil, false) .. ' ' .. goldSending .. ' gold. You now have ' .. (goldHave - goldSending) .. '.'  });
	
end

--Diplomacy Mod
function Propose(game,playerID,payload)
	--Create a proposal
	local proposal = {};
	proposal.ID = NewIdentity();
	proposal.PlayerOne = playerID;
	proposal.PlayerTwo = payload.TargetPlayerID;

	if (game.Settings.SinglePlayer) then
		--In single-player, just auto-accept proposals for testing.
		ProposalAccepted(proposal, game);
	else
		--Write it into the player-specific data
		local playerData = Mod.PlayerGameData;
		if (playerData.Diplo[payload.TargetPlayerID] == nil) then
			playerData.Diplo[payload.TargetPlayerID] = {};
		end

		local pendingProposals = playerData.Diplo[payload.TargetPlayerID].PendingProposals or {};
		table.insert(pendingProposals, proposal);
		playerData.Diplo[payload.TargetPlayerID].PendingProposals = pendingProposals;
		Mod.PlayerGameData = playerData;
	end
end
function ProposeDeclineAccept(game,playerID,payload)
	local proposal = first(Mod.PlayerGameData[playerID].PendingProposals, function(prop) return prop.ID == payload.ProposalID end);
		if (proposal == nil) then return; end; --skip if the proposal ID is invalid.  This can happen if it gets accepted/declined twice
		--Remove it from PlayerGameData
		local pgd = Mod.PlayerGameData;
		pgd[playerID].PendingProposals = filter(pgd[playerID].PendingProposals, function(prop) return prop.ID ~= payload.ProposalID end);
		Mod.PlayerGameData = pgd;
		--If we're accepting it, call ProposalAccepted. If we're declining it, just do nothing and let it be removed.
		if (payload.Message == "AcceptProposal") then
			ProposalAccepted(proposal, game);
		end
end
function SeenAllianceMessage(playerID,payload)
	local playerData = Mod.PlayerGameData;
	if (playerData.Diplo[playerID] == nil) then
		playerData.Diplo[playerID] = {};
	end
	playerData.Diplo[playerID].HighestAllianceIDSeen = payload.HighestAllianceIDSeen;
	Mod.PlayerGameData = playerData;
end
function SeenAlerts(playerID,payload)
	local playerData = Mod.PlayerGameData;
		if (playerData.Diplo[playerID] == nil) then
			playerData.Diplo[playerID] = {};
		end
		playerData.Diplo[playerID].Alerts = nil;
		Mod.PlayerGameData = playerData;
end
function ProposalAccepted(proposal, game)
	
	--Create the alliance
	local alliance = {};
	alliance.ID = NewIdentity();
	alliance.PlayerOne = proposal.PlayerOne;
	alliance.PlayerTwo = proposal.PlayerTwo;

	local data = Mod.PublicGameData;
	local alliances = data.Alliances or {};

	--Do we already have an alliance? Remove it if so.
	alliances = filter(alliances, function(a) return not ((a.PlayerOne == alliance.PlayerOne and a.PlayerTwo == alliance.PlayerTwo) or (a.PlayerOne == alliance.PlayerTwo and a.PlayerTwo == alliance.PlayerOne)) end);

	--Write it into Mod.PublicGameData for all to see
	table.insert(alliances, alliance);
	data.Diplo.Alliances = alliances;
	Mod.PublicGameData = data;
end

