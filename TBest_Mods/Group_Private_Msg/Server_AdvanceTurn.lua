require ('Server_GameCustomMessage');

function Server_AdvanceTurn_End (game, addNewOrder)	
	--Add a turn 'chat' msg to show when a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)	

	--Check if there are any players still playing. If there is not, delete all playerGameData
	for playerID, player in pairs (game.Game.Players)do
		print(playerID)
		if (IsAlive(player, game)) then
			return;
		end
	end	
	ClearData(game,69603);
end

--Determines if the player is alive.
function IsAlive(player, ClientGame)	
	if (player.State == WL.GamePlayerState.Playing) then return true end;
	return false;
end