function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Mod == "Undo") then
		publicGameData = Mod.PublicGameData

		--Check that they can undo last turn
		if (publicGameData.CanUndoLastTurn[playerID]) then
			publicGameData.UndoLastTurn = true
			publicGameData.CanUndoLastTurn[playerID] = false
		end
		Mod.PublicGameData = publicGameData
		Dump(Mod.PublicGameData)
		print(Mod.PublicGameData.CanUndoLastTurn[playerID])
		Dump(game.ServerGame.LatestTurnStanding)
	else
		error("Payload message not understood (" .. payload.Message .. ")")
	end
end

--cooldown? Only let every other turn to be undone?

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
