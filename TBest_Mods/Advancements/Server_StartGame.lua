function Server_StartGame(game, standing)
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData
	publicGameData = Mod.PublicGameData

	--Setup PublicGameData
	publicGameData.Advancment = {Technology = {}, Military = {}, Culture = {}}
	-- How to gain tech points
	publicGameData.Advancment.Technology = {Progress = {minIncome = 25, TurnsEnded = 1, StructuresOwned = 1}}

	--How to gain Military points
	publicGameData.Advancment.Military = {Progress = {minTerritoriesOwned = 100, ArmiesLost = 100, ArmiesDefeated = 100}}

	--How to gain Culture points
	publicGameData.Advancment.Culture = {
		Progress = {noAttackMade = 1, maxTerritoriesOwned = 75, maxArmiesOwned = 100}
	}

	-- Setup privateGameData
	privateGameData.Advancment = {Technology = {}, Military = {}, Culture = {}}

	--Player progress.
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			privateGameData[player.ID] = {Advancment = {}}
			privateGameData[player.ID].Advancment.TechnologyProgress = 0
			privateGameData[player.ID].Advancment.MilitaryProgress = 0
			privateGameData[player.ID].Advancment.CultureProgress = 0
			privateGameData[player.ID].Advancment.PreReq = {Technology = 0, Military = 0, Culture = 0}
			privateGameData[player.ID].Advancment.Unlockables = {
				Technology = technologyUnlockables(),
				Military = militaryUnlockables(),
				Culture = cultureUnlockables()
			}
			--We will assume all Bonus Effects can be nil. In case we add or change them in the future
			privateGameData[player.ID].BonusIncome = 0
			privateGameData[player.ID].BonusAttack = 0
			privateGameData[player.ID].BonusDefence = 0
		end
	end

	-- playerGameData is sent to the client, so we can show it in the UI. Thus, it mirror the privateGameData.
	--Note that AI's can't use playerGameData. Thus, only privateGameData will have AI data.
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			print("Doing playerGameDataSetup " .. player.ID)
			playerGameData[player.ID] = privateGameData[player.ID]
			playerGameData[player.ID].CanUnlockAlert = true
		end
	end
	Mod.PlayerGameData = playerGameData
end

function technologyUnlockables()
	local unlockables = {
		{Income = 5, unlockPoints = 10, preReq = 0, unlocked = false, text = "Earn 5 income per turn"},
		{Structure = WL.StructureType.Market, unlockPoints = 10, preReq = 1, unlocked = false, text = "Build a Market"},
		{Income = 10, unlockPoints = 15, preReq = 1, unlocked = false, text = "Earn 10 income per turn"}
	}

	return unlockables
end

function militaryUnlockables()
	local unlockables = {
		{AttackBoost = 10, unlockPoints = 10, preReq = 0, unlocked = false, text = "Increase offensive kill rate by 10"},
		{Structure = WL.StructureType.ArmyCamp, unlockPoints = 10, preReq = 1, unlocked = false, text = "Build an Army Camp"},
		{AttackBoost = 10, unlockPoints = 15, preReq = 1, unlocked = false, text = "Increase offensive kill rate by 10"}
	}

	return unlockables
end

function cultureUnlockables()
	local unlockables = {
		{DefenceBoost = 15, unlockPoints = 10, preReq = 0, unlocked = true, text = "Increase defencive kill rate by 15"},
		{Structure = WL.StructureType.Arena, unlockPoints = 10, preReq = 1, unlocked = false, text = "Build an Arena"},
		{DefenceBoost = 15, unlockPoints = 15, preReq = 1, unlocked = false, text = "Increase defencive kill rate by 15"}
	}

	return unlockables
end
