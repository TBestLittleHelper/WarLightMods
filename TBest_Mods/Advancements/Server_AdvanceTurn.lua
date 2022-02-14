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
		if (Mod.PublicGameData.Advancment.Technology.Progress.MinIncome <= players[playerID].Income) then
			privateGameData[playerID].Advancment.TechnologyProgress = privateGameData[playerID].Advancment.TechnologyProgress + 1
		end
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
