function Server_StartGame(game, standing)
	privateGameData = Mod.PrivateGameData
	playerGameData = Mod.PlayerGameData

	--TODO PublicGameData

	-- Setup privateGameData
	privateGameData.Advancment = {}
	--Tech
	privateGameData.Advancment.Technology = {"Income Boost", "Structure", "Income Boost"}
	privateGameData.Advancment.TechnologyIncomeBoost = 5
	privateGameData.Advancment.TechnologyStructure = WL.StructureType.Market
	privateGameData.Advancment.ProgressIncome = 25
	privateGameData.Advancment.ProgressTurn = 1
	privateGameData.Advancment.ProgressArmiesPerTerritory = 10
	--Military
	privateGameData.Advancment.Military = {"AttackBoost", "Structure", "Attack Boost"}
	privateGameData.Advancment.MilitaryAttackBoost = 10
	privateGameData.Advancment.MilitaryStructure = WL.StructureType.ArmyCamp
	privateGameData.Advancment.ProgressMinTerritoriesOwned = 100
	privateGameData.Advancment.ProgressArmiesLost = 100
	privateGameData.Advancment.ProgressArmiesDeafeted = 100
	--Cultral
	privateGameData.Advancment.Culture = {"Defence Boost", "Structure", "Defence Boost"}
	privateGameData.Advancment.CultureDefenceBoost = 15
	privateGameData.Advancment.Structure = WL.StructureType.Arena
	privateGameData.Advancment.ProgressNoAttackMade = 1
	privateGameData.Advancment.ProgressMaxTerritoriesOwned = 100
	privateGameData.Advancment.ProgressMaxArmiesOwned = 100

	--Player progress
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			privateGameData[player.ID] = {Advancment = {}}
			privateGameData[player.ID].Advancment.TechProgress = 0
			privateGameData[player.ID].Advancment.MilitaryProgress = 0
			privateGameData[player.ID].Advancment.CultureProgress = 0
			privateGameData[player.ID].Advancment.Unlocked = {Technology = {IncomeBoost = 5}, Military = {}, Culture = {}}
		end
	end

	-- playerGameData is sent to the client, so we can show it in the UI. Thus, it mirror the privateGameData
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then --can't use playerGameData for AI's
			print("Doing playerGameDataSetup " .. player.ID)
			playerGameData[player.ID] = privateGameData[player.ID]
		end
	end
	Mod.PlayerGameData = playerGameData
end
