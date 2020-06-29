function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	PlayerGameData = Mod.PlayerGameData;
	GroupMembersNames = UI.CreateLabel(rootParent) 
	GroupMembersNames.SetText(getGroupMembers())
end

function getGroupMembers()
	PlayerGameData = Mod.PlayerGameData;
	return 'test'
end