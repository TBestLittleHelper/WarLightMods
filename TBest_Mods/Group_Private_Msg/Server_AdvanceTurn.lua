require ('Server_GameCustomMessage');

function Server_AdvanceTurn_End (game, addNewOrder)	
	--Add a turn 'chat' msg to show when a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)	

	--Check if there are any players still playing. If there is not, delete all playerGameData
	local numAlive = 0; --If we have 2 or more alive game is ongoing.
	local Teams = {};
	local numTeamAlive = 0; --If we have teams, num teams alive 
	for playerID, player in pairs (game.Game.Players)do
		if (IsAlive(playerID, game)) then
			numAlive = numAlive+1;
			if (Teams[game.Game.Players[playerID].Team] == nil) then
				Teams[game.Game.Players[playerID].Team] = true;
				numTeamAlive = numTeamAlive +1;
			end
		end
	end
	
	if (numTeamAlive > 1)then return end; --More then 1 team alive
	if (Teams[-1] == true)then 	--If there are no teams (-1 is a special value for no teams)
		if (numAlive > 1)then return end; --And there are more then 1 alive, return
	end;
	--ClearData 
	ClearData(game,69603);
end

--Determines if the player is alive.
function IsAlive(playerID, ClientGame)	
	if (ClientGame.Game.PlayingPlayers[playerID] ~= nil) then 
		return true;
	end;
	return false;
end