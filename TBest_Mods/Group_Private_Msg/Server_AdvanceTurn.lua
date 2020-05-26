require ('Server_GameCustomMessage');
require('Utilities');

function Server_AdvanceTurn_Start(game, addNewOrder)
	if (Mod.Settings.ModDiplomacyEnabled)then
		--Remember in a global variable all alliances that are breaking this turn
		AlliancesBreakingThisTurn = {};
	end;
end;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (Mod.Settings.ModDiplomacyEnabled)then
	Diplomacy_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder);
	BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder);
	end;
end;

function Server_AdvanceTurn_End (game, addNewOrder)	
	--Add a turn 'chat' msg to show when a turn advanced in chat
	TurnDivider(game.Game.NumberOfTurns)		
end

function Diplomacy_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		--Check if the players are allied
		if (PlayersAreAllied(game, game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID)) then
			skipThisOrder(WL.ModOrderControl.Skip);
		end
	elseif (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'Diplomacy2_')) then
		local payloadSplit = split(order.Payload, '_'); 
		local msg = payloadSplit[2];
		if (msg == 'BreakAlliance') then
			local allianceBreak = {};
			allianceBreak.OurPlayerID = order.PlayerID;
			allianceBreak.OtherPlayerID = tonumber(payloadSplit[3]);
			AlliancesBreakingThisTurn[#AlliancesBreakingThisTurn + 1] = allianceBreak;

			--Don't show the break order here. Instead, we'll insert it ourselves at the bottom in Server_AdvanceTurn_End
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

			--Insert a message into player data for the target so that they know to alert the player.
			local ourPlayerName = game.Game.Players[allianceBreak.OurPlayerID].DisplayName(nil, false);
			AlertPlayer(allianceBreak.OtherPlayerID, ourPlayerName .. ' has broken their alliance with you');

		end
	end
end
function AlertPlayer(playerID, msg)
	local playerData = Mod.PlayerGameData;
	if (playerData[playerID] == nil) then
		playerData[playerID] = {};
	end
	local payload = {};
	payload.Message = msg;
	payload.ID = NewIdentity();

	local alerts = playerData[playerID].Alerts or {};
	table.insert(alerts, payload);
	--TODO Server_AdvanceTurn.lua:(59,1-32): PlayerGameData can only contain human players in the game 
	playerData[playerID].Alerts = alerts;
	Mod.PlayerGameData = playerData;
end
function AllianceMatchesPlayers(alliance, playerOne, playerTwo)
	return (alliance.PlayerOne == playerOne and alliance.PlayerTwo == playerTwo)
		or (alliance.PlayerOne == playerTwo and alliance.PlayerTwo == playerOne);
end
function PlayersAreAllied(game, playerOne, playerTwo)
	if (playerOne == playerTwo) then return false end; --never allied with yourself.

	return first(Mod.PublicGameData.Alliances or {}, function(alliance) return AllianceMatchesPlayers(alliance, playerOne, playerTwo) end) ~= nil;
end


function BetterCities_Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	--TODO
end