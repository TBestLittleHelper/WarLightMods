function Server_StartGame(game, standing)
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData
	publicGameData = Mod.PublicGameData

	--Setup PublicGameData -- TODO Refactor some stuff to Mod.Settings?
	publicGameData.Advancment = {
		Technology = {},
		Military = {},
		Culture = {}
	}
	-- How to gain tech points
	publicGameData.Advancment.Technology = {
		Progress = {MinIncome = 25, TurnsEnded = 1, StructuresOwned = 1},
		Color = "#FFF700"
	}

	--How to gain Military points
	publicGameData.Advancment.Military = {
		Progress = {MinTerritoriesOwned = 100, ArmiesLost = 100, ArmiesDefeated = 100},
		Color = "#FF0000"
	}

	--How to gain Culture points
	publicGameData.Advancment.Culture = {
		Progress = {AttacksMade = 1, MaxTerritoriesOwned = 75, MaxArmiesOwned = 100},
		Color = "#880085"
	}

	-- Setup privateGameData
	privateGameData.Advancment = {Technology = {}, Military = {}, Culture = {}} -- TODO do we use this?

	--Player progress.
	for _, player in pairs(game.ServerGame.Game.Players) do
		privateGameData[player.ID] = {Advancment = {}}
		privateGameData[player.ID].Advancment.Points = {Technology = 0, Military = 0, Culture = 0}
		privateGameData[player.ID].Advancment.PreReq = {Technology = 0, Military = 0, Culture = 0}
		privateGameData[player.ID].Advancment.Unlockables = {
			Technology = technologyUnlockables(),
			Military = militaryUnlockables(),
			Culture = cultureUnlockables()
		}
		--We should assume all Bonus Effects can be nil. In case we add or change them in the future
		privateGameData[player.ID].Bonus = {}

		--Player Settings
		privateGameData[player.ID].AlertUnlockAvailible = true
	end

	-- playerGameData is sent to the client, so we can show it in the UI. Thus, it mirror the privateGameData.
	--Note that AI's can't use playerGameData. Thus, only privateGameData will have AI data.
	for _, player in pairs(game.ServerGame.Game.Players) do
		if (player.IsAI == false) then
			playerGameData[player.ID] = privateGameData[player.ID]
		end
	end
	Mod.PlayerGameData = playerGameData
	Mod.PrivateGameData = privateGameData
	Mod.PublicGameData = publicGameData
end

--TODO one time income?
function technologyUnlockables()
	local unlockables = {
		{Type = "Income", Power = 5, UnlockPoints = 10, PreReq = 0, Unlocked = false, Text = "Earn 5 income per turn"},
		{
			Type = "Structure",
			Structure = WL.StructureType.Market,
			UnlockPoints = 10,
			PreReq = 1,
			Unlocked = false,
			Text = "Build a Market"
		},
		{Type = "Income", Power = 10, UnlockPoints = 15, PreReq = 2, Unlocked = false, Text = "Earn 10 income per turn"},
		{Type = "Armies", Power = 30, UnlockPoints = 30, PreReq = 2, Unlocked = false, Text = "Buy 30 armies"}
	}

	return unlockables
end

--TODO lastManStanding (1 army defends for 5, 10 armies)
--TODO flankBonus when attacking?
--TODO overwhelming attack. Attacks over 100 armies, gain 25 strength?

function militaryUnlockables()
	local unlockables = {
		{
			Type = "Attack",
			Power = 10,
			UnlockPoints = 10,
			PreReq = 0,
			Unlocked = false,
			Text = "Increase offensive kill rate by 10"
		},
		{
			Type = "Structure",
			Structure = WL.StructureType.ArmyCamp,
			UnlockPoints = 10,
			PreReq = 1,
			Unlocked = false,
			Text = "Build an Army Camp"
		},
		{
			Type = "Attack",
			Power = 10,
			UnlockPoints = 15,
			PreReq = 1,
			Unlocked = false,
			Text = "Increase offensive kill rate by 10"
		},
		{
			Type = "Loot",
			Power = 10,
			UnlockPoints = 15,
			PreReq = 1,
			Unlocked = false,
			Text = "Pillage 10 defeated armies for 1 income"
		}
	}

	return unlockables
end

--TODO defeated attacking armies are converted to defenders, if the attack fails
--TODO embassies
function cultureUnlockables()
	local unlockables = {
		{
			Type = "Defence",
			Power = 15,
			UnlockPoints = 10,
			PreReq = 0,
			Unlocked = false,
			Text = "Increase defencive kill rate by 15"
		},
		{
			Type = "Structure",
			Structure = WL.StructureType.Arena,
			UnlockPoints = 10,
			PreReq = 1,
			Unlocked = false,
			Text = "Build an Arena"
		},
		{
			Type = "Defence",
			Power = 15,
			UnlockPoints = 15,
			PreReq = 1,
			Unlocked = false,
			Text = "Increase defencive kill rate by 15"
		},
		{
			Type = "NeutralCapture",
			UnlockPoints = 25,
			PreReq = 2,
			Unlocked = false,
			Text = "Defending neutral armies will surrender"
		}
	}

	return unlockables
end
