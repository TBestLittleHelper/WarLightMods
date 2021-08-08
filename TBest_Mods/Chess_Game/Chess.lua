function updateGame( standing,game,FEN )
    for _, territory in pairs (standing.Territories) do
		local unit = getUnit(FEN,game.Map.Territories[territory.ID].Name);
		print(unitToUnitName[string.upper(unit)])
		print(game.Map.Territories[territory.ID].Name)
		if unit ~= 'E' then print(unitToUnitName[string.upper(unit)] .. ' at ' .. game.Map.Territories[territory.ID].Name) end;
		local armies = unitToUnitValue[string.upper(unit)]
		if (armies == 10)then
			--TODO make something unique for the king?
			territory.NumArmies = WL.Armies.Create(armies);
		elseif (armies == 0)then
			--If zero armies, make neutral
			territory.NumArmies = WL.Armies.Create(armies);
			territory.OwnerPlayerID = 0;
		else
			--Set correct amount of armies
			territory.NumArmies = WL.Armies.Create(armies);
		end;
		--If Unit is uppercase, it's a white piece. Else it's a black piece
		if (unit == string.upper(unit) and unit ~= 'E')then
			territory.OwnerPlayerID = PublicGameData.whitePlayerID;
		elseif (unit ~= 'E') then
			territory.OwnerPlayerID = PublicGameData.blackPlayerID;
		end;
    end;
end

function makeMove(standing,game,order,result)
	print(order.From)
	print(order.To)
	print(result.IsSuccessful)

    updateFEN(standing,game)
end

function updateFEN(standing,game)
	-- body
	local numHalfMoves = numHalfMoves(FEN);
	local numMoves = numMoves(FEN);
end

function getUnit(FEN, TerrName)
	--FEN starts with A8, go A1.
	local section = 9 - string.sub(TerrName,2); --Lua array start at 1. So use 9 not 8
	local array = split(FEN, '/');
	local letterValue = letterToNumber[string.sub(TerrName,1,1)]

	--Return E, if there is no units
	if (string.len(array[section]) < letterValue or string.len(array[section])==1) then return 'E' end;
	return string.sub( array[section],letterToNumber[string.sub(TerrName,1,1)],letterToNumber[string.sub(TerrName,1,1)]);	
end;

function myTurn(playerID)
	local FEN = Mod.PublicGameData.currentFEN;
	if playerID == Mod.PublicGameData.whitePlayerID then return true end;
	return false;
end
--Check if a player can castle to a given side
function castle(FEN, color, side)

end;

--The second to last number in FEN
function numHalfMoves (FEN)


end

--The last number in FEN
function numMoves (FEN)

end;