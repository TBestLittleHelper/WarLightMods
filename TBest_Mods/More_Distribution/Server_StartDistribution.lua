require ('Utilities');

--NOTE: A pickable territory has the OwnerPlayerID = -2, a non-pickable territory has OwnerPlayerID = 0;
function Server_StartDistribution(Game, standing)
	--If it is custom senario, return
	-- 0 full dist,-1 warlords, -2, cities, -3 custom, 1+ MapMaker Dist
	if (Game.Settings.DistributionModeID == -3)then return end;
	if (Game.Settings.DistributionModeID > 0)then return end;

	local AllBonuses = Game.Map.Bonuses;
	if (Mod.Settings.INSSmap) then AllBonuses = INSSmap(Game,standing);
	
	--Only bonuses with wastlands are pickable
	elseif (Mod.Settings.wastlandsOnly) then WastlandOnly(Game, standing);
	
	--Only big bonuses (counted by income) are pickable
	elseif (Mod.Settings.incomeBiggestBonus)then BigBonus(Game, standing) end;
	
	--Reverse dist
	if (Mod.Settings.ReverseDist) then ReverseDist(Game, standing) end;
	
	--Check that the game is valid (eg. more then 1 pickable territory)
	SafetyCheck(Game, standing);
	
	--Adjust to fit settings of initial territory distribution
	--Since changing what is pickable, messes this up, we have to go over and clean up
	MatchGameSettings(Game, standing)
end;

function ReverseDist(Game, standing)
	print('ReverseDist')
	for _, terr in pairs (standing.Territories)do
		-- If not a wasteland, we might make it pickable
		if (standing.Territories[terr.ID].NumArmies.NumArmies ~= Game.Settings.WastelandSize)then		
			local pickable = terr.OwnerPlayerID;
			if (pickable == -2) then 
				terr.OwnerPlayerID = 0;				
				elseif (pickable == 0) then
				terr.OwnerPlayerID = -2;
				else print(pickable);
			end
		end
	end
end

function INSSmap(Game,standing)
	print('INSS map')
	local AllBonuses = Game.Map.Bonuses;
	local bonusArray = {};
	local count = 1;
	--If a bonus have a know prefix, don't add it to the bonusArray
	--This should leave us with no overlapping bonuses
	for _, bonus in pairs (AllBonuses) do
		if not(string.match(bonus.Name, "hidden"))then
			bonusArray[count] = bonus;
			count = count + 1;
		end		
	end
	--If unsuported map, this will be nil
	if next(bonusArray) == nil then return AllBonuses end;
	--Set the map to a blank state, by making all territories non-pickable, and removing any WZ added wastlands
	for _, terr in pairs (standing.Territories)do
		terr.OwnerPlayerID = -0;
		terr.NumArmies = WL.Armies.Create(Game.Settings.InitialNonDistributionArmies);	
	end;

	--Since WZ dosn't handle distribution properly for INSS maps, remake a dist.
	--When a game creator adds wastelands to their game, Warzone will randomly distribute neutrals around before populating the rest of the map.
	for i=1, Game.Settings.NumberOfWastelands do
		--Get and remove a random bonus from the array
		local rand = math.random(#bonusArray);
		local wastlandedBonus = table.remove(bonusArray,rand);
		local randomID	= randomFromTable(wastlandedBonus.Territories);

		--Make a random terr a wastland
		standing.Territories[randomID].NumArmies = WL.Armies.Create(Game.Settings.WastelandSize);						
	end

	--Warlords
	--Distribute one reandom territory from each bonus among the remaining bonuses
	if (Game.Settings.DistributionModeID == -1 or Game.Settings.DistributionModeID == -2)then 
		local bonusArrayCopy = bonusArray; -- We want to return bonusArray, so we use a copy
		print('Warlords')
		while(next(bonusArrayCopy)) do
			local bonus = table.remove(bonusArrayCopy,1);
			local randomID = randomFromTable(bonus.Territories);
			----Make the selected terr pickable
			standing.Territories[randomID].OwnerPlayerID = -2;
		end;
	end;

	--Cities
	--Cities is just the reverse of warlords, so just flip it
	if (Game.Settings.DistributionModeID == -2)then 
		print('Cities')
		ReverseDist(Game,standing);
	end;

	return bonusArray;
end

function WastlandOnly(Game, standing)
	print('wastlandOnly')
	local AllBonuses = Game.Map.Bonuses;
	local haveWastland;
	local terrInBonus;
	local index;
	--for all territores in each bonus, check if we have a wastland
	for _, bonus in pairs (AllBonuses) do
		terrInBonus = {};
		haveWastland = false;
		index = 1;
		for _,terrID in pairs (bonus.Territories) do
			if (standing.Territories[terrID].NumArmies.NumArmies == Game.Settings.WastelandSize)then		
				haveWastland = true;
			else
				terrInBonus[index] = terrID;
				standing.Territories[terrID].OwnerPlayerID = -0; --Make it nonpickable
			end
		end;	
		--If we have a wastland in the bonus, make a random territory pickable, all other territories are nonpickable
		if (haveWastland and (terrInBonus) ~= nil) then
			local randomID = randomFromArray(terrInBonus)
			standing.Territories[randomID].OwnerPlayerID = -2;
		end;
	end	
end;

function BigBonus(Game, standing)
	print('BigBonus')
	--First find what bonus each territories belongs too. No duplicates are allowed.
	local AllBonuses = AllBGame.Map.Bonuses;
	local AllTerrMap = Game.Map.Territories;
	local terrInBonus;
	local index;

	--for all territories
	for _, terr in pairs (AllTerrMap) do	
		-- If not a wasteland, we might make it pickable
		if (standing.Territories[terr.ID].NumArmies.NumArmies ~= Game.Settings.WastelandSize)then		
			local biggestBonusID = -1; -- will remain -1 if they are not part of a bonus
			local incomeBiggestBonus = 0; -- The armies per turn from the bonus
			--for all bonuses that the territory is part of
			for _, bonusID in pairs (terr.PartOfBonuses) do
				--if this bonus have higher income, replace biggestBonusID.
				if (incomeBiggestBonus < AllBonuses[bonusID].Amount) then
					biggestBonusID = bonusID;
					incomeBiggestBonus = AllBonuses[bonusID].Amount;
				end;
			end;
			--If incomeBiggestBonus is >= then the Mod setting, make it pickable
			if (incomeBiggestBonus >= Mod.Settings.incomeBiggestBonusSize) then
				standing.Territories[terr.ID].OwnerPlayerID = -2;
				else
				standing.Territories[terr.ID].OwnerPlayerID = -0;
			end;
		end;
	end
end

--Check that we meet the minimum picks
function SafetyCheck(Game, standing)
	local LimitDistributionTerritories = Game.Settings.LimitDistributionTerritories;
	local NumTerritoriesInDistribution =0;
	--If the minimum number of territoryies is pickable, return
	for _, terr in pairs (standing.Territories)do
		if (terr.OwnerPlayerID == -2) then
			NumTerritoriesInDistribution = NumTerritoriesInDistribution+1;
			--Note WZ has some built in safety and may change the number of starting territories in some cases
			if (NumTerritoriesInDistribution >= LimitDistributionTerritories)then 
				return;
			end;
		end;
	end
	--If an insufficiant amount of territories was pickable, make everything pickable.
	print('Not enogh pickable territories:' .. NumTerritoriesInDistribution .. ' Making it full dist.')
	print(LimitDistributionTerritories)
	for _, terr in pairs (standing.Territories)do
		terr.OwnerPlayerID = -2;
	end
end;

function MatchGameSettings(Game, standing)
	local InitialNeutralsInDistribution = Game.Settings.InitialNeutralsInDistribution;
	local InitialNonDistributionArmies = Game.Settings.InitialNonDistributionArmies;
	local WastelandSize = Game.Settings.WastelandSize;
	
	for _, terr in pairs (standing.Territories)do
		if (terr.OwnerPlayerID == -2) then
			terr.NumArmies = WL.Armies.Create(InitialNeutralsInDistribution)
			else
			--If it is NOT a wastland, make it the same as InitialNonDistributionArmies
			if not(terr.NumArmies.NumArmies == WastelandSize)then
				terr.NumArmies = WL.Armies.Create(InitialNonDistributionArmies);
			end;
		end;
	end
end
