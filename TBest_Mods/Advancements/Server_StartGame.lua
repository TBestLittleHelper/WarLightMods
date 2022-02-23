function Server_StartGame(game, standing)
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData
	publicGameData = Mod.PublicGameData

	GameSpeed = Mod.Settings.GameSpeed -- From 1 to 6. Where 6 is a faster progress

	--Setup PublicGameData
	publicGameData.Advancement = {}
	--Technology
	if (Mod.Settings.Advancement.Technology) then
		publicGameData.Advancement.Technology = {
			Progress = {MinIncome = 100 / GameSpeed, TurnsEnded = 1, StructuresOwned = 1 * GameSpeed},
			Color = "#FFF700",
			Menu = "Buttons"
		}
	end
	--Military
	if (Mod.Settings.Advancement.Military) then
		publicGameData.Advancement.Military = {
			-- TODO seems too slow progress atm. Can we teak the numbers
			Progress = {MinTerritoriesOwned = 100 / GameSpeed, ArmiesLost = 100 / GameSpeed, ArmiesDefeated = 100 / GameSpeed},
			Color = "#FF0000",
			Menu = "Buttons"
		}
	end
	--Culture
	if (Mod.Settings.Advancement.Culture) then
		publicGameData.Advancement.Culture = {
			Progress = {AttacksMade = 1 * GameSpeed, MaxTerritoriesOwned = 25 * GameSpeed, MaxArmiesOwned = 30 * GameSpeed},
			Color = "#880085",
			Menu = "Buttons"
		}
	end
	--Diplomacy
	if (Mod.Settings.Advancement.Diplomacy) then
		publicGameData.Advancement.Diplomacy = {
			Progress = {},
			Color = "#880085", -- TODO color
			Menu = "Diplomacy"
		}
	end

	-- Setup privateGameData
	privateGameData.StartOfTurnOrders = {}
	privateGameData.Advancement = {Technology = {}, Military = {}, Culture = {}, Diplomacy = {}} -- TODO do we use this?

	--Player progress.
	for _, player in pairs(game.ServerGame.Game.Players) do
		privateGameData[player.ID] = {Advancement = {}}
		privateGameData[player.ID].Advancement.Points = {Technology = 0, Military = 0, Culture = 0, Diplomacy = 0}
		privateGameData[player.ID].Advancement.PreReq = {Technology = 0, Military = 0, Culture = 0, Diplomacy = 0}
		privateGameData[player.ID].Advancement.Unlockables = {
			Technology = technologyUnlockables(),
			Military = militaryUnlockables(),
			Culture = cultureUnlockables(), --TODO Refactor
			Diplomacy = diplomacyUnlokables()
		}
		--We should assume all Bonus Effects can be nil. In case we add or change them in the future
		privateGameData[player.ID].Bonus = {}

		--Player Settings
		privateGameData[player.ID].AlertUnlockAvailible = true
	end

	-- playerGameData is sent to the client, so we can show it in the UI. Thus, it mirrors the privateGameData.
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
--TODO income per structure owned?

function technologyUnlockables()
	--TODO hackey. But we could simply return a dummy unlockable if the tech is disabled in Mod.Settings.Advancement
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
		{
			Type = "Armies",
			Power = 10 * Mod.Settings.GameSpeed,
			UnlockPoints = 30,
			PreReq = 2,
			Unlocked = false,
			Text = "Buy 30 armies"
		}
	}

	return unlockables
end

--TODO lastManStanding (1 army defends for 5, 10 armies)
--TODO flankBonus when attacking??
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
			Power = 0.1,
			UnlockPoints = 15,
			PreReq = 1,
			Unlocked = false,
			Text = "Pillage 100 defeated armies for 10 income"
		},
		{
			Type = "Loot",
			Power = 0.1,
			UnlockPoints = 30,
			PreReq = 2,
			Unlocked = false,
			Text = "Pillage 100 defeated armies for 10 income"
		},
		{
			Type = "Attack",
			Power = 10,
			UnlockPoints = 30,
			PreReq = 2,
			Unlocked = false,
			Text = "Increase offensive kill rate by 10"
		}
	}

	return unlockables
end

--TODO defeated attacking armies are converted to defenders, if the attack fails
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
			Type = "FreeNeutralCapture",
			UnlockPoints = 25,
			PreReq = 2,
			Unlocked = false,
			Text = "Defending neutral armies will surrender"
		}
	}

	return unlockables
end

--TODO golden years (double income for 7 turns)
--TODO sanctions : recduce the income of someone else
--todo investment : Give income to someone else. But reduces your own income
function diplomacyUnlokables()
	local unlockables = {
		{
			Type = "Support",
			Power = 1,
			UnlockPoints = 4,
			PreReq = 0,
			Unlocked = false,
			Text = "Control your own nation"
		},
		{
			Type = "Investment",
			Power = 10,
			UnlockPoints = 8,
			PreReq = 1,
			Unlocked = false,
			Text = "Give some of your own income to the needy."
		}
	}
	return unlockables
end
