require ('Server_GameCustomMessage');

function Server_AdvanceTurn_End (game, addNewOrder)	
	--Add a turn 'chat' msg to show when a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)	
end