require('Utilities');
require('Client');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then close itself
	if (game.Us == nil) then
		--TODO can we close PresentMenu?
		UI.Alert("You can't do anything as a spectator");
		return;
	else
	UI.CreateLabel(rootParent).SetText("Don't mind me")
	--TODO make a force refreash button?
	setMaxSize(200,150);
		--Make globally accessible
		ClientGame = game;
		RefreshClientDialog();
	end
	close(); --TODO close the parent dosn't work.
end
--Called by Client_GameRefresh
function RefreshGame(gameRefresh)
	print("RefreshClientDialog")
	if (MainDialog ~= nil) then UI.Destroy(MainDialog) end;
	RefreshClientDialog();
end

--TODO better reresh method
function RefreshClientDialog()
	ClientGame.CreateDialog(ClientMainDialog); 	
end

function ClientMainDialog(rootParent, setMaxSize, setScrollable, game, close)	
	PlayerGameData = Mod.PlayerGameData;		
	Game = game; --make it globally accessible
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	setMaxSize(450, 410);
	setScrollable(true);
	
	--List current groups.
	--TODO only show selected group?
	if (next(PlayerGameData) ~= nil) then
		local groupMembers = "";
		local playerID;
		local ListMsg = "";
		
		for groupID, v in pairs(PlayerGameData) do
			groupMembers = PlayerGameData[groupID].GroupName .. " has the following members:  "
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
	horizontalLayout = UI.CreateHorizontalLayoutGroup(vert);

	--If we are in a group, show the chat options
	if (next(PlayerGameData) ~= nil) then
		--For the last X chat msg
		local color = 	Game.Game.Players[Game.Us.ID].Color.HtmlColor;
		local rowChatRecived = UI.CreateVerticalLayoutGroup(vert);
		local horz = UI.CreateHorizontalLayoutGroup(rowChatRecived);
		rowChatRecived.setScrollable = true;
		ChatRecived =	UI.CreateButton(horz)
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(100)
		.SetPreferredHeight(40)
		.SetInteractable(true)
		.SetText("Sender Name")
		.SetColor('#880085')	
		ChatMessageText = UI.CreateLabel(horz)
		.SetFlexibleWidth(0.8)
		.SetPreferredWidth(200)
		.SetPreferredHeight(40)
		.SetText("Chat msg")
		local horz = UI.CreateHorizontalLayoutGroup(rowChatRecived);
		rowChatRecived.setScrollable = true;
		ChatRecived =	UI.CreateButton(horz)
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(100)
		.SetPreferredHeight(40)
		.SetInteractable(true)
		.SetText("Group Name")
		.SetColor('#880085')	
		ChatMessageText = UI.CreateLabel(horz)
		.SetFlexibleWidth(0.8)
		.SetPreferredWidth(200)
		.SetPreferredHeight(40)
		.SetText("Group chat msg")



		ChatMessageText = UI.CreateTextInputField(vert)
		.SetPlaceholderText(" Chat max 100 char")
		.SetFlexibleWidth(0.9)
		.SetCharacterLimit(100)
		.SetPreferredWidth(200)
		.SetPreferredHeight(40)
	
	--A text field for the group selected
	ChatGroupSelectedID = nil;
	ChatGroupSelectedText = UI.CreateTextInputField(horizontalLayout)
		.SetPlaceholderText(" Chat Group Name")
		.SetFlexibleWidth(0.8)
		.SetCharacterLimit(100)
		.SetPreferredWidth(100)
		.SetInteractable(false)
		
	--Make a button for to select chat group
	UI.CreateButton(horizontalLayout)
		.SetText("Select group")
		.SetFlexibleWidth(0.1)
		.SetOnClick(ChatGroupSelected)
		
		UI.CreateButton(vert).SetText("Send chat").SetOnClick(function()
		SendChat();
		close();--Close this dialog. We will call RefreshClientDialog from SendChat
		end);
	end
	--Edit group button
	UI.CreateButton(horizontalLayout)
		.SetText("Edit a group")
		.SetFlexibleWidth(0.1)
		.SetPreferredWidth(150)
		.SetOnClick(function()
		game.CreateDialog(CreateEditDialog);
		close();--Close this dialog. We will call RefreshClientDialog from the new Dialog
	end);

end


function ChatGroupSelected()
	local groups = {}
	for i, v in pairs(PlayerGameData) do
		groups[i] = PlayerGameData[i]
	end
	local options = map(groups, ChatGroupSelectedButton);
	UI.PromptFromList("Select a chat group", options);
end
function ChatGroupSelectedButton(group)	
	local name = group.GroupName;
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		ChatGroupSelectedText.SetText(name)
		ChatGroupSelectedID = group.GroupID;
	end
	return ret;
end

function FlipButtons(groupID)
	--Flip all buttons to interactable and set a color
	for button, bolVal in pairs(buttonGroupSelected) do
		buttonGroupSelected[button].SetColor('#0011ff').SetInteractable(true)		
		--	if PlayerGameData[groupID].GroupName)
	end
	--Make selected button green
	--	buttonGroupSelected[groupID].SetColor('#22ff00').SetInteractable(false)	
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
			local temp =0;
			for groupID, v in pairs(PlayerGameData) do
				temp = temp +1;				
			end
			
			temp = game.Us.ID .. '000' .. temp			
			TargetGroupID = tonumber(temp)
			
			print("made new groupID: " .. TargetGroupID)
			
			else
			print("found old group ID " .. TargetPlayerID)
		end
		
		local payload = {};
		payload.Message = "AddGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		payload.TargetGroupName = GroupTextName.GetText();
		
		Game.SendGameCustomMessage("Adding group member...", payload, function(returnValue) 
			UI.Alert("Group member added!");			
			close(); --Close the dialog since we're done with it
--			RefreshClientDialog(); --Refresh the main dialog
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

function SendChat()
	if (ChatGroupSelectedID == nil)then
		UI.Alert("Pick a chat group first")
		return;
	end
	if (string.len(ChatMessageText.GetText()) < 2 or ChatMessageText.GetText() == ChatMessageText.GetPlaceholderText()) then
		UI.Alert("A chat msg must be more then 1 characters")
		return;
	end
	
	local payload = {};
		payload.Message = "SendChat";
		payload.TargetGroupID = ChatGroupSelectedID;
		payload.Chat = ChatMessageText.GetText();
		print("Chat sent " .. payload.Chat .. " to " .. payload.TargetGroupID .. " from " .. Game.Us.ID)
		Game.SendGameCustomMessage("Sending chat...", payload, function(returnValue) 
			UI.Alert("Chat sent!");
		end);
	ChatMessageText.SetText("");
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

--Determines if the player is one we can interact with.
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
	UI.PromptFromList("Select a chat group", options);
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