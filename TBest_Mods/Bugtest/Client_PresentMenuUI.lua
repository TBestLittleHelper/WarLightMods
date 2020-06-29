function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    PlayerGameData = Mod.PlayerGameData;
    PlayerGameData = {}
    PlayerGameData.Data = '1'
	GroupMembersNames = UI.CreateLabel(rootParent) 
	GroupMembersNames.SetText(getGroupMembers())
end

function getGroupMembers()
	PlayerGameData = Mod.PlayerGameData;
	return 'test'
end