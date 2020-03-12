require('Utilities');
require('Client');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then close itself
	if (game.Us == nil) then
		--TODO can we close this menu?
		--TODO opening multiple PresentMenu's at the same time gives odd behavior. anything we can do?
		UI.Alert("You can't do anything as a spectator");
		close();
		return;
		else
		--TODO think about what is made global
		--Make this globally accessible
		ClientGame = game;

		MainDialog = nil; --TODO remove this var We should work without it
		SizeX = 450; --Chat window
		SizeY = 410; --Chat window
		ChatGroupSelectedID = nil; --We want this globaly
		ChatUIElements = {} --Store elements we might want to destoy here
		
		setMaxSize(300,300); --This dialog's size
		local horz = UI.CreateVerticalLayoutGroup(rootParent);
		
		--Make a scaleable chat, where user can use setMaxSize in parant dialog
		UI.CreateLabel(horz).SetText("Change X size")
		
		SizeXInput = UI.CreateNumberInputField(horz).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeX)
		UI.CreateLabel(horz).SetText("Change Y size")
		SizeYInput = UI.CreateNumberInputField(horz).SetSliderMinValue(300).SetSliderMaxValue(1000).SetValue(SizeY)
		ResizeChatDialog = UI.CreateButton(horz).SetText("Resize Chat").SetOnClick(function()
			SizeX = SizeXInput.GetValue();
			SizeY = SizeYInput.GetValue();
			--TODO validate input for sizeX and Y
			if (MainDialog ~= nil) then UI.Destroy(MainDialog)
				print("destroyed old dialog")
			end;
			print("Resize ClientDialog")
			RefreshClientDialog();
		end);
		MainDialog = ClientGame.CreateDialog(ClientMainDialog); 	
	end
end
--Called by Client_GameRefresh
function RefreshGame(gameRefresh)
	ClientGame = gameRefresh;
	--Only refresh the dialog if we have the Dialog open
	if (MainDialog ~= nil) then UI.Destroy(MainDialog) 
		print("RefreshClientDialog")
		RefreshClientDialog();
	end;
end

--TODO better refresh method
function RefreshClientDialog()
	--Supress the refresh if we don't have any data
	if (ClientGame == nil)then return end;
	MainDialog = ClientGame.CreateDialog(ClientMainDialog); 	
end

function ClientMainDialog(rootParent, setMaxSize, setScrollable, game, close)	
	PlayerGameData = Mod.PlayerGameData;		
	Game = game; --make it globally accessible
	
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	setMaxSize(SizeX, SizeY);
	setScrollable(true,true);
	
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
	
	--Edit group button
	UI.CreateButton(horizontalLayout)
	.SetText("Edit a group")
	.SetFlexibleWidth(0.1)
	.SetPreferredWidth(130)
	.SetOnClick(function()
		game.CreateDialog(CreateEditDialog);
		close();--Close this dialog. 
	end);
	
	--If we are in a group, show the chat options
	if (next(PlayerGameData) ~= nil) then
		--For the last X chat msg
		local color = 	Game.Game.Players[Game.Us.ID].Color.HtmlColor;
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
		
		--TODO chat msg time stamp?
		local rowChatRecived = UI.CreateVerticalLayoutGroup(vert);
		ChatLayout = UI.CreateVerticalLayoutGroup(rowChatRecived)
		RefreshChat();
		
		ChatMessageText = UI.CreateTextInputField(vert)
		.SetPlaceholderText(" Chat max 100 char")
		.SetFlexibleWidth(0.9)
		.SetCharacterLimit(100)
		.SetPreferredWidth(200)
		.SetPreferredHeight(40)
		
		if (ChatGroupSelectedID == nil)then
			ChatMessageText.SetInteractable(false)
		end
		
		--Send chat button
		UI.CreateButton(vert).SetText("Send chat").SetOnClick(function()
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
		--RefreshChat button
		UI.CreateButton(vert).SetText("Refresh chat").SetOnClick(RefreshChat)
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
		
		RefreshChat();
	end
	return ret;
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
	GroupTextNameLabel = UI.CreateLabel(row11).SetText("Name a new chat group");
	GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25).SetPlaceholderText('Group Name 25 char').SetPreferredWidth(200).SetFlexibleWidth(1)
	
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	
	if (next(PlayerGameData) ~= nil) then
		ChatGroupBtn = UI.CreateButton(row2).SetText("Pick an existing group").SetOnClick(ChatGroupClicked);
	end
	
	
	UI.CreateButton(row2).SetText("Add Player").SetOnClick(function() 		
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
			close(); --Close the dialog and reopen to refresh
			game.CreateDialog(CreateEditDialog);
		end);
	end);
	
	UI.CreateButton(row2).SetText("Remove Player").SetOnClick(function() 
		
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
		
		Game.SendGameCustomMessage("Removeing group member...", payload, function(returnValue) 
			close(); --Close the dialog and reopen to refresh
			game.CreateDialog(CreateEditDialog);
		end);
	end);
	
	UI.CreateButton(vert).SetText("Go Back").SetOnClick(function() 		
		RefreshClientDialog();
		close();
	end);
end

function SendChat()	
	local payload = {};
	payload.Message = "SendChat";
	payload.TargetGroupID = ChatGroupSelectedID;
	payload.Chat = ChatMessageText.GetText();
	print("Chat sent " .. payload.Chat .. " to " .. payload.TargetGroupID .. " from " .. Game.Us.ID)
	Game.SendGameCustomMessage("Sending chat...", payload, function(returnValue) 
		RefreshChat();
		
		UI.Alert("Chat sent!");
	end);
	ChatMessageText.SetText("");
end;

function RefreshChat()
	print("RefreshChat called")

	Dump(ChatLayout)
	local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout);
	
	local PlayerGameData = Mod.PlayerGameData;	
	local ChatArrayIndex = nil;
	
	--If there are no past chat or no group selected display the example
	if (ChatGroupSelectedID == nil) then -- or PlayerGameData.Chat[ChatGroupSelectedID] == nil)then	
		local ExampleChatLayout = UI.CreateHorizontalLayoutGroup(horzMain);
		ChatRecived =	UI.CreateButton(ExampleChatLayout)
		.SetFlexibleWidth(0.2)
		.SetPreferredWidth(100)
		.SetPreferredHeight(40)
		.SetInteractable(true)
		.SetText("From Mod")
		.SetColor('#880085')	
		ChatMessageTextRecived = UI.CreateLabel(ExampleChatLayout)
		.SetFlexibleWidth(0.8)
		.SetPreferredWidth(200)
		.SetPreferredHeight(40)
		.SetText("No group selected. This is an example chat msg 😀")
		return;
	end;
		
		if (PlayerGameData[ChatGroupSelectedID].NumChat == nil) then 
			ChatArrayIndex = 0;
			return;
		else ChatArrayIndex = PlayerGameData[ChatGroupSelectedID].NumChat end;
		
		for i=1, ChatArrayIndex do 
			--print (PlayerGameData[ChatGroupSelectedID][i].Chat) 
			local horz = UI.CreateHorizontalLayoutGroup(horzMain);
			
			UI.CreateButton(horz)
			.SetFlexibleWidth(0.2)
			.SetPreferredWidth(100)
			.SetPreferredHeight(40)
			.SetInteractable(true)
			.SetText(Game.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].DisplayName(nil, false))
			.SetColor(Game.Game.Players[PlayerGameData[ChatGroupSelectedID][i].Sender].Color.HtmlColor)	
			UI.CreateLabel(horz)
			.SetFlexibleWidth(0.8)
			.SetPreferredWidth(200)
			.SetPreferredHeight(40)
			.SetText(PlayerGameData[ChatGroupSelectedID][i].Chat)
			
		end
end

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
		--TODO maybe color code groups
		TargetGroupID = group.GroupID;
		GroupTextNameLabel.SetText("Selected group ")
	end
	return ret;
end													