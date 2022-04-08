require "Utilities"

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
		UI.Alert("You can't do anything as a spectator until the game has ended.")
		return
	end

	setMaxSize(550, 650)
	setScrollable(false, true)

	--Global variables
	playerGameData = Mod.PlayerGameData
	publicGameData = Mod.PublicGameData
	closeMenu = close -- Should only ever be one menu open. So this should always point the open dialog
	clientGame = game
	unlockableSelected = nil

	local vert = UI.CreateVerticalLayoutGroup(rootParent)
	horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)

	TechTreeContainer = UI.CreateVerticalLayoutGroup(vert)
	TechTreeContainerArray = {}
	TechTreeSelected = next(Mod.PublicGameData.Advancement)

	--Time to show a tech tree!
	UpdateDialogView()
end

function UpdateDialogView()
	if (TechTreeContainerArray ~= {}) then
		DestroyOldUIelements(TechTreeContainerArray)
	end
	--Update global Mod gameData variables
	playerGameData = Mod.PlayerGameData
	publicGameData = Mod.PublicGameData
	--Create the Advancement tree buttons
	for key, _ in pairs(publicGameData.Advancement) do
		local button =
			UI.CreateButton(horizontalLayout).SetText(key .. " " .. playerGameData.Advancement.Points[key]).SetFlexibleWidth(0.3).SetColor(
			publicGameData.Advancement[key].Color
		).SetOnClick(
			function()
				TechTreeSelected = key
				UpdateDialogView()
			end
		)
		table.insert(TechTreeContainerArray, button)
	end
	--Button to show Bonus overwiew info, in the user color
	local color = clientGame.Game.Players[clientGame.Us.ID].Color.HtmlColor

	local infoButton =
		UI.CreateButton(horizontalLayout).SetText("Help").SetFlexibleWidth(0.1).SetColor(color).SetOnClick(
		function()
			local msg = ""
			for bonus, value in pairs(playerGameData.Bonus) do
				if (type(value)) == "table" then
					value = value.TargetPlayerID
				end
				msg = msg .. bonus .. " " .. value .. "\n"
			end
			if (msg == "") then
				msg = "No Advancments"
			end
			for _, advancement in pairs(publicGameData.Advancement) do
				msg = msg .. "\n" .. advancement.Helptext
			end
			UI.Alert(msg)
		end
	)
	table.insert(TechTreeContainerArray, infoButton)

	local rowTech = UI.CreateVerticalLayoutGroup(TechTreeContainer)
	local treeLayout = UI.CreateVerticalLayoutGroup(rowTech)

	table.insert(TechTreeContainerArray, rowTech)
	table.insert(TechTreeContainerArray, treeLayout)
	local horzMain = UI.CreateVerticalLayoutGroup(treeLayout)
	--Defualt advancements have the "Buttons" menu
	if (publicGameData.Advancement[TechTreeSelected].Menu == "Buttons") then
		for key, unlockable in pairs(playerGameData.Advancement.Unlockables[TechTreeSelected]) do
			local horzLayout = UI.CreateHorizontalLayoutGroup(horzMain)
			--Advancement info
			local AdvancementInfo =
				UI.CreateButton(horzLayout).SetPreferredWidth(150).SetPreferredHeight(8).SetText(unlockable.Text).SetInteractable(
				false
			).SetColor("#FF7D00")

			if (unlockable.Unlocked) then
				AdvancementInfo.SetColor("#00ff05")
				UI.CreateButton(horzLayout).SetText("Active").SetColor("#00ff05")
				UI.CreateButton(horzLayout).SetText("Unlocked").SetColor("#00ff05").SetInteractable(false)
			else
				local CostButton =
					UI.CreateButton(horzLayout).SetText("Cost " .. unlockable.UnlockPoints).SetOnClick(
					function()
						if (unlockable.Type == "Structure" or unlockable.Type == "Armies") then
							unlockableSelected = unlockable
							unlockableSelected.key = key
							unlockableSelected.TechTreeSelected = TechTreeSelected
							-- Close current menu, and open a new one
							closeMenu()
							clientGame.CreateDialog(BuyOnTerritory)
						else
							local payload = {key = key, TechTreeSelected = TechTreeSelected}
							clientGame.SendGameCustomMessage(
								"Buying Advancement ... ",
								payload,
								function(returnValue)
									--TODO return some msg if error?
									UpdateDialogView() --TODO test
								end
							)
						end
					end
				)
				if (unlockable.UnlockPoints > playerGameData.Advancement.Points[TechTreeSelected]) then
					CostButton.SetInteractable(false)
				end
				if (unlockable.PreReq > playerGameData.Advancement.PreReq[TechTreeSelected]) then
					UI.CreateButton(horzLayout).SetText("Need " .. unlockable.PreReq .. " " .. TechTreeSelected).SetInteractable(false)
					CostButton.SetInteractable(false)
				else
					UI.CreateButton(horzLayout).SetText("Unlocked").SetColor("#00ff05").SetInteractable(false)
				end
			end
		end
	elseif (publicGameData.Advancement[TechTreeSelected].Menu == "Diplomacy") then
		--The diplomacy advancements are unique

		for key, unlockable in pairs(playerGameData.Advancement.Unlockables[TechTreeSelected]) do
			local horzLayout = UI.CreateHorizontalLayoutGroup(horzMain)
			local AdvancementInfo =
				UI.CreateButton(horzLayout).SetPreferredWidth(150).SetPreferredHeight(8).SetText(unlockable.Text).SetInteractable(
				false
			).SetColor("#FF7D00")
			local CostButton =
				UI.CreateButton(horzLayout).SetText("Cost " .. unlockable.UnlockPoints).SetOnClick(
				function()
					unlockableSelected = unlockable
					unlockableSelected.key = key
					unlockableSelected.TechTreeSelected = TechTreeSelected

					BuyWithPlayer()
				end
			)
			if (unlockable.TargetPlayerID ~= nil and unlockable.Type == "Support") then
				--TODO display name, display color
				local SelectedPlayerButton = UI.CreateButton(horzLayout).SetInteractable(false).SetText("No player selected")
				SelectedPlayerButton.SetText("Selected player: " .. unlockable.TargetPlayerID)
			end
		end
	end
end

function DestroyOldUIelements(Container)
	if (next(Container) ~= nil) then
		for count = #Container, 1, -1 do
			if (Container[count] ~= nil) then
				UI.Destroy(Container[count])
			end
			table.remove(Container, count)
		end
	end
end

function BuyOnTerritory(rootParent, setMaxSize, setScrollable, game, close)
	if (unlockableSelected == nil) then
		UI.Alert("No unlockable selected")
		close()
		return
	end
	closeMenu = close
	setMaxSize(300, 400)

	local veticalBuyOnTerritory = UI.CreateVerticalLayoutGroup(rootParent)

	UI.CreateButton(veticalBuyOnTerritory).SetText(unlockableSelected.Text).SetInteractable(false)
	UI.CreateButton(veticalBuyOnTerritory).SetText(
		"It is possible to select a territory you don't own. WARNING : If you pick a territory that already has a structure, you will waste your points."
	).SetInteractable(false)

	selectedTerritoryButton =
		UI.CreateButton(veticalBuyOnTerritory).SetText("Select a territory").SetOnClick(SelectBuyOnTerritory)

	confirmButton =
		UI.CreateButton(veticalBuyOnTerritory).SetText("Confirm").SetOnClick(ConfirmBuyWithTerritory).SetInteractable(false)
end
function TargetTerritoryClicked(territory)
	if (territory == nil) then
		--The click request was cancelled.
		UI.Alert("No territory was selected")
	end
	confirmButton.SetInteractable(true)
	confirmButton.SetText("Click here to confirm buying on " .. territory.Name)
	unlockableSelected.territorySelected = territory
end
function SelectBuyOnTerritory()
	UI.InterceptNextTerritoryClick(TargetTerritoryClicked)
	selectedTerritoryButton.SetText("Please click on a territory.  If needed, you can move this dialog out of the way.")
end
function ConfirmBuyWithTerritory(close)
	Dump(unlockableSelected)
	local payload = {
		key = unlockableSelected.key,
		TechTreeSelected = unlockableSelected.TechTreeSelected,
		TerritoryID = unlockableSelected.territorySelected.ID
	}
	clientGame.SendGameCustomMessage(
		"Buying Advancement ... ",
		payload,
		function(returnValue)
			--TODO return some msg if error?
		end
	)
	closeMenu()
	clientGame.CreateDialog(Client_PresentMenuUI) --TODO test
end
function BuyWithPlayer()
	if (unlockableSelected == nil) then
		UI.Alert("No unlockable selected")
		return
	end
	local players = {}
	for i, player in pairs(clientGame.Game.Players) do
		players[i] = player
	end
	local options = map(filter(players, IsPotentialTarget), SelectedBuyWithPlayer)
	UI.PromptFromList("Select a player ", options)
end
--Determins if the player is one we can interact with.
function IsPotentialTarget(player)
	if (clientGame.Us.ID == player.ID) then
		return false
	end -- we can never add ourselves.

	if (player.State ~= WL.GamePlayerState.Playing) then
		return false
	end --skip players not alive anymore, or that declined the game.

	return true
end

function SelectedBuyWithPlayer(player)
	local name = player.ID
	local ret = {}
	ret["text"] = name
	ret["selected"] = function()
		local payload = {
			key = unlockableSelected.key,
			TechTreeSelected = unlockableSelected.TechTreeSelected,
			PlayerID = player.ID
		}
		clientGame.SendGameCustomMessage(
			"Buying Advancement ... ",
			payload,
			function(returnValue)
				--TODO return some msg if error?
			end
		)
	end
	return ret
end
