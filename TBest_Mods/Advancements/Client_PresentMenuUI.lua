function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--If a spectator, just alert then return
	if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
		UI.Alert("You can't do anything as a spectator until the game has ended.")
		return
	end

	setMaxSize(500, 600)
	setScrollable(false, true)

	local vert = UI.CreateVerticalLayoutGroup(rootParent)
	local horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)

	--Global variables
	playerGameData = Mod.PlayerGameData

	TechTreeContainer = UI.CreateVerticalLayoutGroup(vert)
	TechTreeContainerArray = {}
	TechTreeSelected = "Technology"

	--Button to show Technology tech tree
	UI.CreateButton(horizontalLayout).SetText("Technology " .. playerGameData.Advancment.TechProgress).SetFlexibleWidth(
		0.3
	).SetColor("#FFF700").SetOnClick(
		function()
			TechTreeSelected = "Technology"
			UpdateTechTree()
		end
	)
	--Button to show Military tech tree
	UI.CreateButton(horizontalLayout).SetText("Military " .. playerGameData.Advancment.MilitaryProgress).SetFlexibleWidth(
		0.3
	).SetColor("#FF0000").SetOnClick(
		function()
			TechTreeSelected = "Military"
			UpdateTechTree()
		end
	)
	--Button to show Diplomatic tech tree
	UI.CreateButton(horizontalLayout).SetText("Culture " .. playerGameData.Advancment.CultureProgress).SetFlexibleWidth(
		0.3
	).SetColor("#880085").SetOnClick(
		function()
			TechTreeSelected = "Culture"
			UpdateTechTree()
		end
	)
end

function UpdateTechTree()
	print("UpdateTechTree() called")
	if (TechTreeContainerArray ~= {}) then
		DestroyOldUIelements(TechTreeContainerArray)
	end
	rowTech = UI.CreateVerticalLayoutGroup(TechTreeContainer)
	treeLayout = UI.CreateVerticalLayoutGroup(rowTech)

	table.insert(TechTreeContainerArray, rowTech)
	table.insert(TechTreeContainerArray, treeLayout)
	local horzMain = UI.CreateVerticalLayoutGroup(treeLayout)

	for key, value in pairs(playerGameData.Advancment.Unlocked[TechTreeSelected]) do
		local horzLayout = UI.CreateHorizontalLayoutGroup(horzMain)
		print(key, value)
		--Advancment info
		UI.CreateButton(horzLayout).SetPreferredWidth(150).SetPreferredHeight(8).SetText(key .. " " .. value).SetInteractable(
			false
		).SetColor("#00ff05")
	end
end

--TODO move to uitility lua file?
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
