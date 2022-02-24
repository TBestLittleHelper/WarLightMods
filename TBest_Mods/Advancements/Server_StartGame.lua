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
			Menu = "Buttons",
			Helptext = "Technology points are earned from having a high income, owning structure and the passage of time"
		}
	end
	--Military
	if (Mod.Settings.Advancement.Military) then
		publicGameData.Advancement.Military = {
			-- TODO seems too slow progress atm. Can we teak the numbers
			Progress = {MinTerritoriesOwned = 100 / GameSpeed, ArmiesLost = 100 / GameSpeed, ArmiesDefeated = 100 / GameSpeed},
			Color = "#FF0000",
			Menu = "Buttons",
			Helptext = "Military points are earned from owning many territories, deafeting enemy armies or loosing your own armies."
		}
	end
	--Culture
	if (Mod.Settings.Advancement.Culture) then
		publicGameData.Advancement.Culture = {
			Progress = {AttacksMade = 1 * GameSpeed, MaxTerritoriesOwned = 25 * GameSpeed, MaxArmiesOwned = 30 * GameSpeed},
			Color = "#880085",
			Menu = "Buttons",
			Helptext = "Culture points are earned from owning few territories, not making attacks and owning few armies."
		}
	end
	--Diplomacy
	if (Mod.Settings.Advancement.Diplomacy) then
		publicGameData.Advancement.Diplomacy = {
			Progress = {},
			Color = "#0021FF",
			Menu = "Diplomacy",
			Helptext = "Diplomacy points can only be earned by other players supporting you."
		}
	end

	-- Setup privateGameData
	privateGameData.StartOfTurnOrders = {}

	--Player progress.
	for _, player in pairs(game.ServerGame.Game.Players) do
		privateGameData[player.ID] = {Advancement = {Points = {}, PreReq = {}, Unlockables = {}}}

		for advancement, _ in pairs(publicGameData.Advancement) do
			privateGameData[player.ID].Advancement.Points[advancement] = 0
			privateGameData[player.ID].Advancement.PreReq[advancement] = 0
			privateGameData[player.ID].Advancement.Unlockables[advancement] = getUnlockables(advancement) --TODO This could probably be more efficient
		end
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

--Helper function to get the unlockable for the advancement
function getUnlockables(key)
	if key == "Technology" then
		return technologyUnlockables()
	end
	if key == "Military" then
		return militaryUnlockables()
	end
	if key == "Culture" then
		return cultureUnlockables()
	end
	if key == "Diplomacy" then
		return diplomacyUnlokables()
	end
end
--TODO one time income?
--TODO income per structure owned?

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
		{
			Type = "Armies",
			Power = 10 * Mod.Settings.GameSpeed,
			UnlockPoints = 30,
			PreReq = 2,
			Unlocked = false,
			Text = "Buy 30 armies"
		},
		{Type = "Income", Power = 20, UnlockPoints = 30, PreReq = 3, Unlocked = false, Text = "Earn 20 income per turn"},
		{
			Type = "Structure",
			Structure = WL.StructureType.Market,
			UnlockPoints = 30,
			PreReq = 3,
			Unlocked = false,
			Text = "Build a Market"
		},
		{
			Type = "Armies",
			Power = 20 * Mod.Settings.GameSpeed,
			UnlockPoints = 35,
			PreReq = 4,
			Unlocked = false,
			Text = "Buy 30 armies"
		},
		{Type = "Income", Power = 30, UnlockPoints = 30, PreReq = 5, Unlocked = false, Text = "Earn 30 income per turn"}
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
			Text = "Invest 10 income to help another gain 20"
		}
	}
	return unlockables
end
