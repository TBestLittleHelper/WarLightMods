require "Utilities"

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
		UI.Alert("You can't do anything as a spectator until the game has ended.")
		return
	end

	setMaxSize(550, 650)
	setScrollable(false, true)

	--Global variables TODO use Mod.PlayerGameData instead?
	playerGameData = Mod.PlayerGameData
	publicGameData = Mod.PublicGameData
	clientGame = game

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
			if (next(playerGameData.Bonus) == nil) then --TODO not working atm
				UI.Alert("No Advancements")
			end
			for bonus, value in pairs(playerGameData.Bonus) do
				msg = msg .. bonus .. " " .. value .. "\n"
			end
			UI.Alert(msg)
		end --TODO add more info to it?
	)
	table.insert(TechTreeContainerArray, infoButton)

	--TODO 		privateGameData[player.ID].AlertUnlockAvailible = true
	local alertButton =
		UI.CreateButton(horizontalLayout).SetText("Alerts on").SetFlexibleWidth(0.1).SetOnClick(
		function()
		end
	)
	table.insert(TechTreeContainerArray, alertButton)

	local rowTech = UI.CreateVerticalLayoutGroup(TechTreeContainer)
	local treeLayout = UI.CreateVerticalLayoutGroup(rowTech)

	table.insert(TechTreeContainerArray, rowTech)
	table.insert(TechTreeContainerArray, treeLayout)
	local horzMain = UI.CreateVerticalLayoutGroup(treeLayout)
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
							BuyOnTerritory(key, TechTreeSelected)
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
		print("Diplomacy todo")
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

function BuyOnTerritory(key, TechTreeSelected)
	if (TechTreeContainerArray ~= {}) then
		DestroyOldUIelements(TechTreeContainerArray)
	end
	local selectTerritoryButton =
		UI.CreateButton(horizontalLayout).SetText(
		"Select any territory; it is possible to select a territory you don't own. You can move this dialog out of the way if needed. WARNING : If you pick a territory that already has a structure, you will waste your points."
	)
	selectedTerritoryButton =
		UI.CreateButton(horizontalLayout).SetText("Select a territory").SetOnClick(BuyWithTerritory(tempGlobal))
	table.insert(TechTreeContainerArray, selectTerritoryButton)
	table.insert(TechTreeContainerArray, selectTerritoryButton)

	--TODO Ugly, but I don't know if I can avoid global variables, since I need to use the callback
	tempGlobal = {key = key, TechTreeSelected = TechTreeSelected, territory = nil}
	UI.InterceptNextTerritoryClick(TargetTerritoryClicked)
end
function TargetTerritoryClicked(territory)
	if (territory == nil) then
		--The click request was cancelled.
		UI.Alert("No territory was selected")
		tempGlobal = nil
		UpdateDialogView()
	end
	tempGlobal.territory = territory
	selectedTerritoryButton.SetText("Place the bonus on " .. territory.Name)
end
function BuyWithTerritory(tempGlobal)
	local payload = {
		key = tempGlobal.key,
		TechTreeSelected = tempGlobal.TechTreeSelected,
		TerritoryID = tempGlobal.territory.ID
	}
	clientGame.SendGameCustomMessage(
		"Buying Advancement ... ",
		payload,
		function(returnValue)
			--TODO return some msg if error?
			UpdateDialogView() --TODO test
		end
	)
	tempGlobal = nil
end
