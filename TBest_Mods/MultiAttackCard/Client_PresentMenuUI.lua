function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil) then
		UI.Alert("You can't do anything as a spectator.")
		return
	end
	--Prevent mod menu from opening during distribution
	if (game.Game.NumberOfTurns == -1) then
		UI.Alert("You can't do anything during distribution")
		close()
		return
	end

	--Window size
	SizeX = 300
	SizeY = 400

	setMaxSize(SizeX, SizeY)
	setScrollable(false, false)

	fromTerritory = nil
	toTerritory = nil
	Game = game

	vert = UI.CreateVerticalLayoutGroup(rootParent)

	--Info
	local rowInfo = UI.CreateHorizontalLayoutGroup(vert)
	PlayCardInfo =
		UI.CreateButton(rowInfo).SetText("Saved Multi-Attack Charges : " .. Mod.PlayerGameData.charges).SetColor("#880085").SetPreferredHeight(
		400
	).SetInteractable(false)

	--From territory
	local rowFrom = UI.CreateHorizontalLayoutGroup(vert)
	FromTerritoryButton =
		UI.CreateButton(rowFrom).SetText("From Territory ..").SetColor("#880085").SetOnClick(FromTerritoryButtonClicked)
	--To territory
	local rowTo = UI.CreateHorizontalLayoutGroup(vert)
	ToTerritoryButton =
		UI.CreateButton(rowTo).SetText("To Territory ..").SetColor("#880085").SetOnClick(ToTerritoryButtonClicked)
	--Submit attack
	local rowAttack = UI.CreateHorizontalLayoutGroup(vert)
	UI.CreateButton(rowAttack).SetText("Confirm").SetColor("#00FF05").SetOnClick(ConfirmButtonClicked)
	AutoConfrimToggle = UI.CreateCheckBox(rowAttack).SetIsChecked(false).SetText("Auto Confirm")
end

--Select from territory
function FromTerritoryButtonClicked()
	UI.InterceptNextTerritoryClick(FromTerritoryClicked)
	FromTerritoryButton.SetText("Please click on From territory.")
end
function FromTerritoryClicked(terrDetails)
	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		FromTerritoryButton.SetText("From Territory ..")
		fromTerritory = nil
	else
		--Territory was clicked
		FromTerritoryButton.SetText("From Territory: " .. terrDetails.Name)
		fromTerritory =
		print(toTerritory == nil)
		if (toTerritory == nil)then
			ToTerritoryButtonClicked()
		end
	end
end

--Select to territory
function ToTerritoryButtonClicked()
	UI.InterceptNextTerritoryClick(ToTerritoryClicked)
	ToTerritoryButton.SetText("Please click on To territory.")
end
function ToTerritoryClicked(terrDetails)
	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		ToTerritoryButton.SetText("To Territory ..")
		toTerritory = nil
	else
		--Territory was clicked
		ToTerritoryButton.SetText("To Territory: " .. terrDetails.Name)
		toTerritory = terrDetails
		--If auto confirm, clic the confirm button
		if AutoConfrimToggle.GetIsChecked() then
			ConfirmButtonClicked()
		end
	end
end

--Confirm attack
function ConfirmButtonClicked()
	if (fromTerritory == nil) then
		UI.Alert("Error: No from territory selected")
		return
	end
	if (toTerritory == nil) then
		UI.Alert("Error: No to territory selected")
		return
	end
	--Make sure fromTerritory boarders toTerritory
	if (Game.Map.Territories[fromTerritory.ID].ConnectedTo[toTerritory.ID] == nil) then
		UI.Alert("Error: Selected territories does not connect to each other")
		return
	end

	local msg = fromTerritory.Name .. " multiattack to  " .. toTerritory.Name
	local payload = "MultiAttackCard_" .. fromTerritory.ID .. "," .. toTerritory.ID
	local orders = Game.Orders
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload))
	Game.Orders = orders

	--For convinience, set update 'from' and clear 'to territory'. Also start ToTerritoryButtonClicked
	FromTerritoryClicked(toTerritory)
	ToTerritoryClicked(nil)
	ToTerritoryButtonClicked()
end
