require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then close itself
	if (game.Us == nil) then
		close();
		UI.Alert("You can't do anything as a spectator");
		return;
		else
		--TODO think about what is made global
		--Make this globally accessible
		ClientGame = game;
		
		MainDialog = nil;
		SizeX = 500; --Chat window
		SizeY = 500; --Chat window
		ChatGroupSelectedID = nil; --We want this globaly
		ChatLayout = nil;
		ChatContainer = nil;
		ChatMsgContainerArray = {};
		
		setMaxSize(300,300); --This dialog's size
		local horz = UI.CreateVerticalLayoutGroup(rootParent); --TODO rename to vert
		

		--TODO remove or make Admin/Me only
		ClearChatBtn = UI.CreateButton(horz).SetText("Remove all playerdata").SetOnClick(function()
			local payload = {};
			payload.Message = "ClearData";
			
			ClientGame.SendGameCustomMessage("ClearData" , payload, function(returnValue)end);
		end);
		
		
		--Make a scalable chat, where user can use setMaxSize in parent dialog
		UI.CreateLabel(horz).SetText("Change X size")
		
		SizeXInput = UI.CreateNumberInputField(horz).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeX)
		UI.CreateLabel(horz).SetText("Change Y size")
		SizeYInput = UI.CreateNumberInputField(horz).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeY)
		ResizeChatDialog = UI.CreateButton(horz).SetText("Open chat window").SetOnClick(function()
			SizeX = SizeXInput.GetValue();
			SizeY = SizeYInput.GetValue();
			--Validate input for sizeX and Y
			if SizeX < 200 then SizeX = 200 end
			if SizeX > 2000 then SizeX = 2000 end
			if SizeY < 200 then SizeY = 200 end
			if SizeY > 2000 then SizeY = 2000 end
			
			RefreshMainDialog(close)
		end);
			RefreshMainDialog(close)
	end;
end;

function RefreshMainDialog(close)
	if close ~= nil then close() end;
	
	if (MainDialog ~= nil) then UI.Destroy(MainDialog)
		print("destroyed old dialog")
	end;
	
	print("Open ClientDialog")
	MainDialog = ClientGame.CreateDialog(ClientMainDialog);	
end


--Called by Client_GameRefresh
function RefreshGame(gameRefresh)
	--We don't want to refresh if the PresentMenuUi has not been opned.
	if (ClientGame == nil or ChatContainer == nil)then
		print("refresh suppressed.")
		return;
	end;	
	ClientGame = gameRefresh;
	RefreshChat(); -- todo TEST breaks atm when a new game starts
end;

function ClientMainDialog(rootParent, setMaxSize, setScrollable, game, close)	
	PlayerGameData = Mod.PlayerGameData;		--TODO move to global var's ?
	
	--TODO rework layout
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	setMaxSize(SizeX, SizeY);
	setScrollable(false,true);
	local row = UI.CreateHorizontalLayoutGroup(vert);
	
	--List the members of the current selected group.
	--TODO this dosn't update when refresh chat is called. We should fix that.
	GroupMembersNames = UI.CreateLabel(row).SetText(getGroupMembers());
	
	local horizontalLayout = UI.CreateHorizontalLayoutGroup(vert);
	
	--Edit group button
	UI.CreateButton(horizontalLayout)
	.SetText("Edit a group")
	.SetFlexibleWidth(0.1)
	.SetPreferredWidth(130)
	.SetOnClick(function()
		DestroyOldUIelements(ChatMsgContainerArray) --TODO maybe we can just set the Array = {} : For now, this works
		ClientGame.CreateDialog(CreateEditDialog);
		close();--Close this dialog. 
	end);
	
	--If we are in a group, show the chat options
	if (next(PlayerGameData) ~= nil) then
		--For the last X chat msg?
		--A text field for the group selected
		ChatGroupSelectedText = UI.CreateTextInputField(horizontalLayout)
		.SetPlaceholderText(" Chat Group")
		.SetFlexibleWidth(0.8)
		.SetCharacterLimit(100)
		.SetPreferredWidth(130)
		.SetInteractable(false)
		
		--Make a button for to select chat group
		UI.CreateButton(horizontalLayout)
		.SetText("Select group") --TODO keep selection over refresh
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(130)
		.SetOnClick(ChatGroupSelected)
		--TODO autoselect if ChatGroupSelected ~= nil
		
		--TODO chat msg time stamp?
		ChatContainer = UI.CreateVerticalLayoutGroup(vert);
		RefreshChat();
		
		ChatMessageText = UI.CreateTextInputField(vert)  --Do we need this global? If so move to global space
		.SetPlaceholderText(" Chat max 100 char")
		.SetFlexibleWidth(0.9)
		.SetCharacterLimit(100)
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
		print (color)
		print ("color")
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
	Dump(group)
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		ChatGroupSelectedText.SetText(name)
		ChatGroupSelectedID = group.GroupID;
		ChatMessageText.SetInteractable(true)
		
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
	--TODO make it possible to select multiple players?
	--TODO leave a group
	--TODO delete a group
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Select a player to add or remove from a group: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);
	
	row11 = UI.CreateHorizontalLayoutGroup(vert);
	GroupTextNameLabel = UI.CreateLabel(row11).SetText("Name a new chat group: ");
	GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25).SetPlaceholderText('Group Name 25 char').SetPreferredWidth(200).SetFlexibleWidth(1)
	
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	
	if (next(PlayerGameData) ~= nil) then
		ChatGroupBtn = UI.CreateButton(row2).SetText("Pick an existing group").SetOnClick(ChatGroupClicked);
	end
	
	--Add a player to a group
	UI.CreateButton(row2).SetText("Add Player").SetColor("#03d100").SetOnClick(function() 		
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
		--TODO remove Alert
		UI.Alert(payload.TargetGroupID)

		RefreshMainDialog(close);
		end);
	end);
	
	--Remove a player from a group
	UI.CreateButton(row2).SetText("Remove Player").SetColor("#a10000").SetOnClick(function() 
		
		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end
		--If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
		if (GroupTextName.GetInteractable() == true) then
			UI.Alert("Please choose a group from the list");
			return;
		end
		
		local payload = {};
		payload.Message = "RemoveGroupMember";
		payload.TargetPlayerID = TargetPlayerID;
		payload.TargetGroupID = TargetGroupID;
		
		ClientGame.SendGameCustomMessage("Removing group member...", payload, function(returnValue) 
			RefreshMainDialog(close);
		end);
	end);
	
	buttonRow = UI.CreateHorizontalLayoutGroup(vert);
	--Go back to MainDialog button
	UI.CreateButton(buttonRow).SetText("Go Back").SetColor("#0062ff").SetOnClick(function() 		
		RefreshMainDialog(close);
	end);	
	
	--If owner, show delete else show leave? TODO
	UI.CreateButton(buttonRow).SetText("Leave group").SetColor("#a10000").SetOnClick(function() 		
		RefreshMainDialog(close);
	end);	
	UI.CreateButton(buttonRow).SetText("Delete group").SetColor("#a10000").SetOnClick(function() 		
		RefreshMainDialog(close);
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
	
	--Remove old elements
	DestroyOldUIelements(ChatMsgContainerArray)
	
	rowChatRecived = UI.CreateVerticalLayoutGroup(ChatContainer); 
	ChatLayout = UI.CreateVerticalLayoutGroup(rowChatRecived)
	table.insert(ChatMsgContainerArray, rowChatRecived);
	table.insert(ChatMsgContainerArray, ChatLayout);
	
	
	local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout);
	
	local PlayerGameData = Mod.PlayerGameData;	
	local ChatArrayIndex = nil;
	
	--If there are no past chat (TODO) or no group selected display the example
	if (ChatGroupSelectedID == nil) then -- or PlayerGameData.Chat[ChatGroupSelectedID] == nil)then	
		local ExampleChatLayout = UI.CreateHorizontalLayoutGroup(horzMain);
		ChatRecived =	UI.CreateButton(ExampleChatLayout)
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(100)
		.SetPreferredHeight(40)
		.SetText("From Mod")
		.SetColor('#880085')	
		ChatMessageTextRecived = UI.CreateLabel(ExampleChatLayout)
		.SetFlexibleWidth(0.8)
		.SetText("No group selected. This is an example chat msg 😀")
		return;
	end;
	
	if (PlayerGameData[ChatGroupSelectedID].NumChat == nil) then 
		ChatArrayIndex = 0;
		return;
	else ChatArrayIndex = PlayerGameData[ChatGroupSelectedID].NumChat end;
	
	for i=1, ChatArrayIndex do 
		local horz = UI.CreateHorizontalLayoutGroup(horzMain);
		
		UI.CreateButton(horz)
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(100)
		.SetPreferredHeight(40)
		.SetText(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].DisplayName(nil, false))
		.SetColor(ClientGame.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].Color.HtmlColor)	
		UI.CreateLabel(horz)
		.SetFlexibleWidth(0.8)
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
		--TODO maybe color code groups
		TargetGroupID = group.GroupID;
		GroupTextNameLabel.SetText("Selected group ")
	end
	return ret;
end																	