require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil) then
		UI.Alert("You can't do anything as a spectator");
		return;
	end;
	
	--Make some global var's
	ClientGame = game;
	PlayerGameData = Mod.PlayerGameData;
	
	
	MainDialog = nil;
	if (SizeX == nil or SizeY == nil) then
		SizeX = 500; --Chat window
		SizeY = 500; --Chat window
	end;
	setMaxSize(SizeX, SizeY);
	setScrollable(false,true);
	
	--TODO TargetGroupID = ChatGroupSelected
	ChatGroupSelectedID = nil;
	ChatLayout = nil;
	ChatContainer = nil;
	ChatMsgContainerArray = {};
	
	--Set up the main Dialog window

	--List the members of the current selected group.
	--TODO this doesn't update when refresh chat is called. We should fix that.
	GroupMembersNames = UI.CreateLabel(rootParent).SetText(getGroupMembers());

	--TODO rework layout
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local horizontalLayout = UI.CreateHorizontalLayoutGroup(vert);
	
	--Edit group button
	UI.CreateButton(horizontalLayout)
	.SetText("Manage groups")
	.SetFlexibleWidth(0.2)
	.SetOnClick(function()
		DestroyOldUIelements(ChatMsgContainerArray) --TODO maybe we can just set the Array = {} : For now, this works
		ClientGame.CreateDialog(CreateEditDialog);
		close();--Close this dialog. 
	end);
	
	UI.CreateButton(rootParent).SetText("Settings").SetColor("#00ff05").SetOnClick(function()
		DestroyOldUIelements(ChatMsgContainerArray) --TODO maybe we can just set the Array = {} : For now, this works
		ClientGame.CreateDialog(SettingsDialog);
		close();--Close this dialog. 
	end);
	
	--If we are in a group, show the chat options
	if (next(PlayerGameData) ~= nil) then
		--For the last X chat msg?
		--A text field for the group selected
		ChatGroupSelectedText = UI.CreateButton(horizontalLayout)
		.SetText("Chat Group")
		.SetFlexibleWidth(0.6)
		.SetColor(randomColor()) --TODO maybe not randomColor. But for now raiwnbow!
		
		
		--Make a button for to select chat group
		UI.CreateButton(horizontalLayout)
		.SetText("Select chat group") --TODO keep selection over refresh
		.SetFlexibleWidth(0.2)
		.SetOnClick(ChatGroupSelected)
		--TODO autoselect if ChatGroupSelected ~= nil
		
		ChatContainer = UI.CreateVerticalLayoutGroup(vert);
		RefreshChat();
		
		ChatMessageText = UI.CreateTextInputField(vert)
		.SetPlaceholderText(" Max 300 characters in one messages")
		.SetFlexibleWidth(0.9)
		.SetCharacterLimit(300)
		.SetPreferredWidth(500)
		.SetPreferredHeight(40)
		
		if (ChatGroupSelectedID == nil)then
			ChatMessageText.SetInteractable(false)
		end
		
		ChatButtonContainer = UI.CreateHorizontalLayoutGroup(vert);
		--RefreshChat button
		UI.CreateButton(ChatButtonContainer).SetText("Refresh chat").SetColor("#00ff05").SetOnClick(RefreshChat)
		--Send chat button
		local color = ClientGame.Game.Players[ClientGame.Us.ID].Color.HtmlColor; --this is prolly dumb. But let's color the send chat button in the users color
		UI.CreateButton(ChatButtonContainer).SetColor("#880085").SetText("Send chat").SetOnClick(function()
			if (ChatGroupSelectedID == nil)then
				UI.Alert("Pick a chat group first")
				return;
			end	
			if (string.len(ChatMessageText.GetText()) < 2 or ChatMessageText.GetText() == ChatMessageText.GetPlaceholderText()) then
				UI.Alert("A chat msg must be more then 1 characters")
				return;
			end		
			SendChat();
		end);
	end
end;	
--TODO think about what is made global

function SettingsDialog(rootParent, setMaxSize, setScrollable, game, close)		
	
	setMaxSize(350,350); --This dialog's size
	local vert = UI.CreateVerticalLayoutGroup(rootParent); --TODO rename to vert
	
	
	--This only shows for Admin/Me only (this is checked server side too)
	if (ClientGame.Us.ID == 69603) then 
		ClearChatBtn = UI.CreateButton(vert).SetText("Remove all playerdata").SetOnClick(function()
			local payload = {};
			payload.Message = "ClearData";			
			ClientGame.SendGameCustomMessage("ClearData" , payload, function(returnValue)end);
		end);
	end;	
	
	--TODO hook this up
	ShowAllChatCheckBox = UI.CreateCheckBox(vert).SetText('Show all past chat').SetIsChecked(false).SetOnValueChanged(function()
		print('Check box is now ' .. ShowAllChatCheckBox.GetValue())
		end)
		
	--Make a scalable chat, where user can use setMaxSize for the main dialog
	UI.CreateLabel(vert).SetText("Change X size")
	
	SizeXInput = UI.CreateNumberInputField(vert).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeX)
	UI.CreateLabel(vert).SetText("Change Y size")
	SizeYInput = UI.CreateNumberInputField(vert).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeY)
	
	
	buttonRow = UI.CreateHorizontalLayoutGroup(vert);
	--Go back to MainDialog button : don't save
	UI.CreateButton(buttonRow).SetText("Go Back").SetColor("#0062ff").SetOnClick(function() 		
		RefreshMainDialog(close);
	end);
	
	--Save changes then go back to MainDialog
	ResizeChatDialog = UI.CreateButton(buttonRow).SetText("Resize chat window").SetOnClick(function()
		SizeX = SizeXInput.GetValue();
		SizeY = SizeYInput.GetValue();
		--Validate input for sizeX and Y
		if SizeX < 200 then SizeX = 200 end
		if SizeX > 2000 then SizeX = 2000 end
		if SizeY < 200 then SizeY = 200 end
		if SizeY > 2000 then SizeY = 2000 end
		
		RefreshMainDialog(close)
	end);	
end;

function RefreshMainDialog(close)
	if close ~= nil then close() end;
	
	if (MainDialog ~= nil) then UI.Destroy(MainDialog)
		print("destroyed old dialog")
	end;
	
	print("Open ClientDialog")
	MainDialog = ClientGame.CreateDialog(Client_PresentMenuUI)
end


--Called by Client_GameRefresh
function RefreshGame(gameRefresh)
	--We don't want to refresh if the PresentMenuUi has not been opned. gameRefresh is called when a game is opned
	if (ClientGame == nil or ChatContainer == nil)then
		print("refresh suppressed.")
		return;
	end;	
	ClientGame = gameRefresh;
end;

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
		ChatGroupSelectedText.SetText(name).SetColor(group.Color)
		ChatGroupSelectedID = group.GroupID;
		
		GroupMembersNames.SetText(getGroupMembers());
		RefreshChat();
	end
	return ret;
end

function getGroupMembers()
	
	if (next(PlayerGameData) ~= nil and ChatGroupSelectedID ~= nil) then		
		local groupMembers = PlayerGameData[ChatGroupSelectedID].GroupName .. " has the following members:  ";
		local playerID;
		local ListMsg = ""; 
		
		for j, val in pairs(PlayerGameData[ChatGroupSelectedID].Members) do
			if (val == true) then
				playerID = j
				local player = ClientGame.Game.Players[playerID];
				local playerName = player.DisplayName(nil,false);
				groupMembers = groupMembers .. playerName .. " "
			end
		end
		ListMsg = ListMsg .. groupMembers .. "\n";
		return ListMsg;
	end;
	return "No group selected";
end

function CreateEditDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(420, 330);
	TargetPlayerID = nil;
	TargetGroupID = nil;
	
	
	--TODO make some options non-interactable if they have no use?
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Select a player to add or remove from a group: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);
	
	row11 = UI.CreateHorizontalLayoutGroup(vert);
	GroupTextNameLabel = UI.CreateLabel(row11).SetText("Name a new chat group: ");
	GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25).SetPlaceholderText(" Group Name max 25 characters").SetPreferredWidth(200).SetFlexibleWidth(1)
	
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	
	if (next(PlayerGameData) ~= nil) then
		ChatGroupBtn = UI.CreateButton(row2).SetText("Pick an existing group").SetOnClick(ChatGroupClicked);
	end
	
	--Add a player to a group
	UI.CreateButton(row2).SetText("Add Player").SetColor("#00ff05").SetOnClick(function() 		
		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end		
		if (GroupTextName.GetText() == nil or string.len(GroupTextName.GetText()) < 3) then
			UI.Alert("Please choose a group name with at least 3 characters");
			return;
		end
		
		if (TargetGroupID == nil) then
			local temp =0;
			for groupID, v in pairs(PlayerGameData) do
				temp = temp +1;				
			end
			temp = ClientGame.Us.ID .. '00' .. temp;
			TargetGroupID = toint(temp);
			
			print("made new groupID: " .. TargetGroupID)		
			else
			print("found old group ID " .. TargetPlayerID)
		end
		
		local payload = {};
		payload.Message = "AddGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		payload.TargetGroupName = GroupTextName.GetText();
		
		ClientGame.SendGameCustomMessage("Adding group member...", payload, function(returnValue) 
			TargetPlayerBtn.SetText("Select player...").SetColor(randomColor())	
			TargetPlayerID = nil; --Reset
			GroupTextName.SetInteractable(false); --We store the GroupID, so don't let the user change the name
		end);
	end);
	
	--Remove a player from a group
	UI.CreateButton(row2).SetText("Remove Player").SetColor("#FF0000").SetOnClick(function() 
		
		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end
		--If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
		if (GroupTextName.GetInteractable() == true) then
			UI.Alert("Please choose a group from the list");
			return;
		end
		--We can't remove the owner of a group
		if (TargetPlayerID == Mod.PlayerGameData[TargetGroupID].Owner)then
			UI.Alert("You can't remove the owner of a group")
			return;
		end;
		
		
		local payload = {};
		payload.Message = "RemoveGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		
		ClientGame.SendGameCustomMessage("Removing group member...", payload, function(returnValue) 
			TargetPlayerBtn.SetText("Select player...").SetColor(randomColor())	
			TargetPlayerID = nil; --Reset	
		end);
	end);
	
	buttonRow = UI.CreateHorizontalLayoutGroup(vert);
	--Go back to MainDialog button
	UI.CreateButton(buttonRow).SetText("Go Back").SetColor("#0000FF").SetOnClick(function() 		
		RefreshMainDialog(close);
	end);	
	
	--If owner, show delete else show leave? TODO
	
	--Leave a group option
	LeaveGroupBtn = UI.CreateButton(buttonRow).SetText("Leave group").SetInteractable(false).SetColor("#FF0000").SetOnClick(function() 
		--If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
		if (GroupTextName.GetInteractable() == true) then
			UI.Alert("Please choose a group from the list");
			return;
		end
		if (Mod.PlayerGameData[TargetGroupID].Owner == ClientGame.Us.ID) then
			UI.Alert("You can't leave a group you created. You can, however delete the group.")
			return;
		end;
		local payload = {};
		payload.Message = "LeaveGroup";
		payload.TargetGroupID = TargetGroupID;
		ClientGame.SendGameCustomMessage("Leaving the group...", payload, function(returnValue) 
			--Reset Group Selected
			TargetGroupID = nil;
			GroupTextName.SetText("").SetInteractable(true)
		end);	
	end);
	
	
	--Delete a group : only possible as a group owner
	--TODO confirmation prompt would be smart
	deleteGroupBtn = UI.CreateButton(buttonRow).SetText("Delete group").SetInteractable(false).SetColor("#FF0000").SetOnClick(function() 		
		--If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
		if (GroupTextName.GetInteractable() == true) then
			UI.Alert("Please choose a group from the list");
			return;
		end
		
		if (Mod.PlayerGameData[TargetGroupID].Owner ~= ClientGame.Us.ID) then
			UI.Alert("You can only delete if you are the owner of a group")
			return;
		end;
		local payload = {};
		payload.Message = "DeleteGroup";
		payload.TargetGroupID = TargetGroupID;	
		ClientGame.SendGameCustomMessage("Deleting group...", payload, function(returnValue) 
			--Reset Group Selected
			TargetGroupID = nil;
			GroupTextName.SetText("").SetInteractable(true)
		end);
	end);
	
end

function SendChat()	
	local payload = {};
	payload.Message = "SendChat";
	payload.TargetGroupID = ChatGroupSelectedID;
	payload.Chat = ChatMessageText.GetText();
	print("Chat sent " .. payload.Chat .. " to " .. payload.TargetGroupID .. " from " .. ClientGame.Us.ID)
	ClientGame.SendGameCustomMessage("Sending chat...", payload, function(returnValue) 
		RefreshChat();
	end);
	ChatMessageText.SetText("");
end;

--TODO this function can be made faster and better
function RefreshChat()
	print("RefreshChat() called")
	--Update the members of the current selected group.
	GroupMembersNames.SetText(getGroupMembers())

	--Remove old elements
	DestroyOldUIelements(ChatMsgContainerArray)
	
	rowChatRecived = UI.CreateVerticalLayoutGroup(ChatContainer); 
	ChatLayout = UI.CreateVerticalLayoutGroup(rowChatRecived)
	table.insert(ChatMsgContainerArray, rowChatRecived);
	table.insert(ChatMsgContainerArray, ChatLayout);
	
	
	local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout);
	
	local PlayerGameData = Mod.PlayerGameData;	
	local ChatArrayIndex = nil;
	
	--If there are no past chat or no group selected display the example
	if (ChatGroupSelectedID ~= nil)then
		if (PlayerGameData[ChatGroupSelectedID].NumChat == nil) then 
			ChatArrayIndex = 0;
			ChatMessageText.SetInteractable(true)
			else ChatArrayIndex = PlayerGameData[ChatGroupSelectedID].NumChat
		end;
	end
	
	if (ChatGroupSelectedID == nil or ChatArrayIndex == 0) then -- or PlayerGameData.Chat[ChatGroupSelectedID] == nil)then	
		-- local ExampleChatLayout = UI.CreateHorizontalLayoutGroup(horzMain);
		-- ChatExample1 =	UI.CreateButton(ExampleChatLayout)
		-- .SetPreferredWidth(150)
		-- .SetPreferredHeight(8)
		-- .SetText("Mod Info")
		-- .SetColor('#880085')	
		-- ChatMessageTextRecived = UI.CreateLabel(ExampleChatLayout)
		-- .SetFlexibleWidth(1)
		-- .SetFlexibleHeight(1)
		-- .SetText("No group selected. This is an example chat msg 😀")
		local ExampleChatLayout2 = UI.CreateHorizontalLayoutGroup(horzMain);
		ChatExample2 =	UI.CreateButton(ExampleChatLayout2)
		.SetPreferredWidth(150)
		.SetPreferredHeight(8)
		.SetText("Mod Info")
		.SetColor('#880085')	
		ChatMessageTextRecived2 = UI.CreateLabel(ExampleChatLayout2)
		.SetFlexibleWidth(1)
		.SetFlexibleHeight(1)
		.SetText("Note that messages to the server is rate-limited to 5 calls every 30 seconds per client. Therfore, do not spam chat: it won't work!")
		return;
	end;
	
	
	ChatMessageText.SetInteractable(true)
	
	for i=1, ChatArrayIndex do 
		local horz = UI.CreateHorizontalLayoutGroup(horzMain);
		
		UI.CreateButton(horz)
		.SetPreferredWidth(150)
		.SetPreferredHeight(8)
		.SetText(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].DisplayName(nil, false))
		.SetColor(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].Color.HtmlColor)	
	
		UI.CreateLabel(horz)
		.SetFlexibleWidth(1)
		.SetFlexibleHeight(1)
		.SetText(PlayerGameData[ChatGroupSelectedID][i].Chat)		
	end
end

function DestroyOldUIelements(Container)
	if (next(Container)~=nil) then
		for count = #Container, 1, -1 do
			UI.Destroy(Container[count]);
			table.remove(Container, count)
		end
	end
end

function TargetPlayerClicked()
	local options = map(filter(ClientGame.Game.Players, IsPotentialTarget), PlayerButton);
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
	if (ClientGame.Us.ID == player.ID) then return false end; -- we can never add ourselves.
	
	if (player.State ~= WL.GamePlayerState.Playing) then return false end; --skip players not alive anymore, or that declined the game.
	
	if (ClientGame.Settings.SinglePlayer) then return true end; --in single player, allow proposing with everyone
	
	return not player.IsAI; --In multi-player, never allow adding an AI.
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
		TargetGroupID = group.GroupID;
		GroupTextNameLabel.SetText("Selected group ")
		--Check if we are owner or member
		if (ClientGame.Us.ID == Mod.PlayerGameData[TargetGroupID].Owner) then
			--If we are the owner, we can delete the group
			deleteGroupBtn.SetInteractable(true);
			LeaveGroupBtn.SetInteractable(false); --TODO hide the buttons instead?
		else
			--If we are not the owner we can leave the group
			deleteGroupBtn.SetInteractable(false);
			LeaveGroupBtn.SetInteractable(true); --TODO hide the buttons instead?
		end
	end
	return ret;
end																			