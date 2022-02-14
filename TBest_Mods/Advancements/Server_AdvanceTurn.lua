function Server_AdvanceTurn_End(game, addNewOrder)
	playerGameData = Mod.PlayerGameData
	privateGameData = Mod.PrivateGameData

	--Territories owned
	--Structures owned
	--Armies owned
	local players = {}

	for playerID, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		players[playerID] = {}
		players[playerID].IsAI = player.IsAI
		players[playerID].TerritoriesOwned = 0
		players[playerID].StructuresOwned = 0
		players[playerID].ArmiesOwned = 0
		players[playerID].Income = player.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total --bypass army cap and sanc card
		players[playerID].Progress = {
			Technology = privateGameData[playerID].Advancment.TechnologyProgress,
			Military = privateGameData[playerID].Advancment.MilitaryProgress,
			Culture = privateGameData[playerID].Advancment.CultureProgress
		}
	end

	--Loop all territories and count how many a player owns
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if (terr.IsNeutral == false) then
			players[terr.OwnerPlayerID].TerritoriesOwned = players[terr.OwnerPlayerID].TerritoriesOwned + 1
			players[terr.OwnerPlayerID].ArmiesOwned = players[terr.OwnerPlayerID].ArmiesOwned + terr.NumArmies.NumArmies
			if (terr.Structures ~= nil) then
				players[terr.OwnerPlayerID].StructuresOwned = players[terr.OwnerPlayerID].StructuresOwned + 1 --TODO don't assume Structures are not stacked. Create a helper function
			end
		end
	end

	--Give out points and boost
	for playerID, _ in pairs(players) do
		local techPoints = privateGameData[playerID].Advancment.TechnologyProgress
		local cultPoints = privateGameData[playerID].Advancment.CultureProgress
		local miliPoints = privateGameData[playerID].Advancment.MilitaryProgress

		--Technology points. A point per turn; if over min income; point per structure owned
		if (Mod.PublicGameData.Advancment.Technology.Progress.MinIncome <= players[playerID].Income) then
			techPoints = techPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Technology.Progress.TurnsEnded == 1) then
			techPoints = techPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Technology.Progress.StructuresOwned <= players[playerID].StructuresOwned) then
			techPoints = techPoints + players[playerID].StructuresOwned
		end
		--Culture points. A point if under max Armies; under max territories
		if (Mod.PublicGameData.Advancment.Culture.Progress.MaxArmiesOwned >= players[playerID].ArmiesOwned) then
			cultPoints = cultPoints + 1
		end
		if (Mod.PublicGameData.Advancment.Culture.Progress.MaxTerritoriesOwned >= players[playerID].TerritoriesOwned) then
			cultPoints = cultPoints + 1
		end
		--TODO no attack culture ^
		--Military points. A point for min territories owned;
		if (Mod.PublicGameData.Advancment.Military.Progress.MinTerritoriesOwned <= players[playerID].TerritoriesOwned) then
			miliPoints = miliPoints + 1
		end
		--TODO armies lost, armies defeated

		privateGameData[playerID].Advancment.TechnologyProgress = techPoints
		privateGameData[playerID].Advancment.CultureProgress = cultPoints
		privateGameData[playerID].Advancment.MilitaryProgress = miliPoints

		if (not players[playerID].IsAI) then
			playerGameData[playerID] = privateGameData[playerID]
		end
	end

	Mod.PlayerGameData = playerGameData
	Mod.PrivateGameData = privateGameData
	--local incomeMod = WL.IncomeMod.Create(playerID, cost, msg)
	--addNewOrder(WL.GameOrderEvent.Create(playerID, msg, nil, {}, nil, {incomeMod}))
end

function Dump(obj)
	if obj.proxyType ~= nil then
		DumpProxy(obj)
	elseif type(obj) == "table" then
		DumpTable(obj)
	else
		print("Dump " .. type(obj))
	end
end
function DumpTable(tbl)
	for k, v in pairs(tbl) do
		print("k = " .. tostring(k) .. " (" .. type(k) .. ") " .. " v = " .. tostring(v) .. " (" .. type(v) .. ")")
	end
end
function DumpProxy(obj)
	print(
		"type=" ..
			obj.proxyType ..
				" readOnly=" ..
					tostring(obj.readonly) ..
						" readableKeys=" .. table.concat(obj.readableKeys, ",") .. " writableKeys=" .. table.concat(obj.writableKeys, ",")
	)
end
