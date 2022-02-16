require("Utilities")

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	--payload = {key = key, TechTreeSelected = TechTreeSelected}

	local playerGameData = Mod.PlayerGameData
	local privateGameData = Mod.PrivateGameData
	local publicGameData = Mod.PublicGameData

	local unlockable = playerGameData[playerID].Advancment.Unlockables[payload.TechTreeSelected][payload.key]
	Dump(unlockable)
	if
		(unlockable.unlocked == false and
			unlockable.preReq <= privateGameData[playerID].Advancment.PreReq[payload.TechTreeSelected])
	 then
		if (unlockable.unlockPoints <= privateGameData[playerID].Advancment.Points[payload.TechTreeSelected]) then
			print("We can buy it!")
		end
	end
	--		{AttackBoost = 10, unlockPoints = 10, preReq = 0, unlocked = false, text = "Increase offensive kill rate by 10"},
end
