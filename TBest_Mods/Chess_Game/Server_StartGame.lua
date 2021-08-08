require 'Utilities'
require 'Chess'

function Server_StartGame(game, standing)		
	--Set the initial FEN value.
	local FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
	--FEN = "5rk1/3pQpbp/r4np1/q7/1p1P4/1P3N2/P1PN1PPP/R4RK1 b - - 0 1";
	--TODO turn FEN into a FEN with E's and not digits
	FEN = "EEEEErkE/EEEpQpbp/rEEEEnpE/qEEEEEEE/EpEPEEEE/EPEEENEE/PEPNEPPP/REEEERKE b - - 0 1";

	letterToNumber = {A=1,B=2,C=3,D=4,E=5,F=6,G=7,H=8};
	unitToUnitName = {E='Empty',P='Pawn',B='Bishop',N='Knight',R='Rook',Q='Queen',K='King'}
	unitToUnitValue = {E=0,P=1,B=3,N=4,R=5,Q=9,K=10}

	if (Mod.Settings.StartFEN ~= nil)then FEN = Mod.Settings.StartFEN end;
	local whitePlayerID = nil;
	local blackPlayerID = nil;

	--Assign white and black
	for _, player in pairs(game.Game.Players) do
		if (whitePlayerID == nil)then 
			whitePlayerID = player.PlayerID;
			if (whitePlayerID == nil)then whitePlayerID = player.AIPlayerID end;
		elseif (blackPlayerID == nil)then
			blackPlayerID = player.PlayerID;
			if (blackPlayerID == nil)then blackPlayerID = player.AIPlayerID end;
		end;
	end

	--Set up a reference table, that connects every square (like 'E5') to a territory ID
	local boardSqrToTerrID = {};
	for letter, number in pairs (letterToNumber) do
		for i=8,1,-1 do 
			boardSqrToTerrID[letter..i] = nil;
		end
	end;
	
	for _, territory in pairs (standing.Territories) do
		boardSqrToTerrID[game.Map.Territories[territory.ID].Name] = territory.ID;	
	end;


	PublicGameData = Mod.PublicGameData;
	PublicGameData.boardSqrToTerrID = boardSqrToTerrID;
	PublicGameData.currentFEN = FEN;
	PublicGameData.whitePlayerID = whitePlayerID;
	PublicGameData.blackPlayerID = blackPlayerID;
	Mod.PublicGameData = PublicGameData;

	updateGame(standing,game,FEN)
end