require('Zombie')
--Called when the game starts the first turn. In a manual territory distribution game, 
--this is called after all players have entered their picks. In an automatic territory distribution game, 
--this is called when the game starts. This is called after the standing has been built (picks have been given out)

function Server_StartGame(game, standing)
		Zombie(game, standing);
end