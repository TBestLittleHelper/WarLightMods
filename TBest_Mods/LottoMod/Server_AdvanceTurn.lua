function Server_AdvanceTurn_Start (game,addNewOrder)
	standing = game.ServerGame.LatestTurnStanding;
	local playersSet = {}
	local CurrentIndex=1;
	local winnerCapturesAll={};

	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			playersSet[territory.OwnerPlayerID] = true
		end
	end
	local winner = lucky(playersSet);
	for _,territory in pairs(standing.Territories)do
		terrMod = WL.TerritoryModification.Create(territory.ID);
		terrMod.SetOwnerOpt=winner;
		winnerCapturesAll[CurrentIndex]=terrMod;
		CurrentIndex=CurrentIndex+1;
	end
print (standing.Game.Players[winner].DisplayName(nil, true)
--	DisplayName(standingOpt GameStanding, includeAIWas boolean) returns string:

	addNewOrder(WL.GameOrderEvent.Create(winner,"Won the lottery!",nil,winnerCapturesAll));
end
--some code is from https://github.com/kszyhoop/WarlightModPicksSwap/blob/master/SwapPicks.lua
function lucky(playersSet)
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end	
  	local winner = math.random(0,n);
	return playersTable[winner];
end
