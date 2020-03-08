require('Utilities');
require('Client');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then close itself
	if (game.Us == nil) then
		UI.Alert("You can do anything as a spectator");
		close();
	end
	
	PlayerGameData = Mod.PlayerGameData;
	
	-- if next(PlayerGameData) == nil then
	-- print(" empty playerdata")	
	-- else 
	-- print("DumpTable(PlayerGameData")
	-- DumpTable(PlayerGameData)
	-- end
	
	
	Game = game; --make it globally accessible
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	--List current groups.
	if (next(PlayerGameData) ~= nil) then
		local groupMembers = "";
		local playerID;
		local ListMsg = "";
		
		for groupID, v in pairs(PlayerGameData) do
			print(groupID .. " i, ")
			groupMembers = PlayerGameData[groupID].GroupName .. " have the following members:  "
			for j, val in pairs(PlayerGameData[groupID].Members) do
				if (val == true) then
					playerID = j
					local player = Game.Game.Players[playerID];
					local playerName = player.DisplayName(nil,false);
					groupMembers = groupMembers .. playerName .. " "
				end
			end
			
			ListMsg = ListMsg .. groupMembers .. "\n"
			groupMembers = "";
		end
		
		local row = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row).SetText(ListMsg);
		
	end
	--Edit group button
	UI.CreateButton(vert).SetText("Edit a group chat").SetOnClick(function()
		game.CreateDialog(CreateEditDialog);
	end);
	
	--If we are in a group, have a chat option
	if (next(PlayerGameData) ~= nil) then
		ChatMessageText = UI.CreateTextInputField(vert)
		.SetPlaceholderText("Chat max 100 char")
		.SetPreferredWidth(1)
		.SetCharacterLimit(100)
		.SetPreferredWidth(250)
		
		
		UI.CreateButton(vert).SetText("Select group").SetOnClick(function()
			game.CreateDialog(ChatGroupClicked); --TODO
		end);
		
		
		UI.CreateButton(vert).SetText("Send chat").SetOnClick(function()
			game.CreateDialog(SendChatDialog);
		end);
	end
end

function CreateEditDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(420, 330);
	TargetPlayerID = nil;
	TargetGroupID = nil;
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Select a player to add or remove from a group: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);
	
	row11 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row11).SetText("Make a group Name");
	GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25).SetPlaceholderText('Group Name 25 char').SetPreferredWidth(200).SetFlexibleWidth(1)
	
	if (next(PlayerGameData) ~= nil) then
		local row12 = UI.CreateHorizontalLayoutGroup(vert);
		ChatGroupBtn = UI.CreateButton(row12).SetText("Pick From List").SetOnClick(ChatGroupClicked);
	end
	
	UI.CreateButton(vert).SetText("Add Player").SetOnClick(function() 
		
		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end
		
		if (GroupTextName.GetText() == nil or string.len(GroupTextName.GetText()) < 3) then
			UI.Alert("Please choose a group name with at least 3 characters");
			return;
		end
		
		
		--If it's a new group, make an ID for it
		--TODO better way to make ID
		if (TargetGroupID == nil) then
			local temp = #PlayerGameData + 1
			
			temp = game.Us.ID .. '000' .. temp
			
			TargetGroupID = tonumber(temp)
			
			print("made new groupID: " .. temp)
			
			else
			print("group ID " .. TargetPlayerID)
		end
		
		local payload = {};
		payload.Message = "AddGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		payload.TargetGroupName = GroupTextName.GetText();
		
		Game.SendGameCustomMessage("Adding group member...", payload, function(returnValue) 
			UI.Alert("Group member added!");
			close(); --Close the propose dialog since we're done with it
		end);
	end);
	
	--TODO test remove
	UI.CreateButton(vert).SetText("Remove Player").SetOnClick(function() 
		
		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end
		if (GroupTextName == nil or GroupTextName == "") then
			UI.Alert("Please choose a group first");
			return;
		end
		--If it's a new group, make an ID for it
		if (TargetGroupID == nil) then
			TargetGroupID = #PlayerGameData + 1
		end
		
		local payload = {};
		payload.Message = "RemoveGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		payload.TargetGroupName = "GroupNameTest" ; --TODO
		
		Game.SendGameCustomMessage("Remove group member...", payload, function(returnValue) 
			UI.Alert("Group member Removed!");
			close(); --Close the propose dialog since we're done with it
		end);
	end);
end

function SendChatDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(420, 330);
	TargetGroupID = nil;
	
end;

function TargetPlayerClicked()
	local options = map(filter(Game.Game.Players, IsPotentialTarget), PlayerButton);
	UI.PromptFromList("Select the player you'd like to add or remove from a group", options);
end

function TargetGroupClicked()
	print("TargetGroupClicked")
	
	local groups = {}
	for i, v in pairs(PlayerGameData) do
		print(i)
		groups[i] = PlayerGameData[i]
	end
	local options = map(groups, GroupButton);
	UI.PromptFromList("Select the group you'd like to add this player too", options);
end

--Determines if the player is one we can propose an alliance to.
function IsPotentialTarget(player)
	if (Game.Us.ID == player.ID) then return false end; -- we can never propose an alliance with ourselves.
	
	if (player.State ~= WL.GamePlayerState.Playing) then return false end; --skip players not alive anymore, or that declined the game.
	
	if (Game.Settings.SinglePlayer) then return true end; --in single player, allow proposing with everyone
	
	return not player.IsAI; --In multi-player, never allow proposing with an AI.
end

function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name).SetColor(player.Color.HtmlColor);
		TargetPlayerID = player.ID;
	end
	return ret;
end

function GroupButton(group)
	
	local name = group.GroupName;
	
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		GroupTextName.SetText(name).SetInteractable(false)
		TargetGroupID = group.Owner;
	end
	return ret;
end

function ChatGroupClicked()
	local groups = {}
	for i, v in pairs(PlayerGameData) do
		print(i)
		groups[i] = PlayerGameData[i]
	end
	local options = map(groups, ChatGroupButton);
	UI.PromptFromList("Select the group you'd like to add this player too", options);
	
end
function ChatGroupButton(group)
	
	local name = group.GroupName;
	
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		GroupTextName.SetText(name).SetInteractable(false)
		--TODO a group needs to know it's own ID
		TargetGroupID = group.GroupID;
	end
	return ret;
end