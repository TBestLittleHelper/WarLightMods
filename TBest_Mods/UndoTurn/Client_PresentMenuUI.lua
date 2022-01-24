function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

	--Window size
	SizeX = 250
	SizeY = 350

	setMaxSize(SizeX, SizeY)
	setScrollable(false, false)

	Game = game
	playerID = Game.Us.ID

	vert = UI.CreateVerticalLayoutGroup(rootParent)

	--Info graphic
	local row1 = UI.CreateHorizontalLayoutGroup(vert)
	UndoTurnButton =
		UI.CreateButton(row1).SetText("Undo your last turn. You can only undo once each game").SetColor("#880085").SetPreferredHeight(
		400
	).SetOnClick(UndoTurnClicked)
end

function UndoTurnClicked()
	local payload = {}
	payload.Mod = "Undo"

	Game.SendGameCustomMessage(
		"Sending request to server...",
		payload,
		function(returnValue)
		end
	)
end
