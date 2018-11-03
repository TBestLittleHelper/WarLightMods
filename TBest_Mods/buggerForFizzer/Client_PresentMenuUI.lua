function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game; --global variables
	LastTurn = {}; 
	
	setMaxSize(450, 300);

	vert = UI.CreateVerticalLayoutGroup(rootParent);
	vert2 = UI.CreateVerticalLayoutGroup(rootParent);

	
	if (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		UI.CreateLabel(vert).SetText("You cannot do anything since you're not in the game");
		return;
	end
	
	if (game.Settings.LocalDeployments == false) then
		UI.CreateLabel(vert).SetText("This mod only works in Local Deployment games.  This isn't a Local Deployment.");
		return;
	end

	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	addOrders = UI.CreateButton(row1).SetText("Add last turn's deployment and transfers").SetOnClick(AddOrdersConfirmes);
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	addDeployOnly = UI.CreateButton(row2).SetText("Add last turn's deployment only").SetOnClick(AddDeploy);
	
	local row3 =  UI.CreateHorizontalLayoutGroup(vert);
	clearOrders = UI.CreateButton(row3).SetText("Clear Orders").SetOnClick(clearOrdersFunction);
end

function clearOrdersFunction()
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	local orderTabel = Game.Orders;--get clinet order list
	if(next(orderTabel) ~= nil) then
		orderTabel = {};
		Game.Orders = orderTabel;
	end;
end;

function AddDeploy()
	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;

	if(turn -1 <= firstTurn) then
		UI.Alert("You can't use the mod during distribution or for the first turn.");
		return;
	end;
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	local turn = turn -2;
	Game.GetTurn(turn, function(turnThis) getTurnHelper(turnThis) end)
	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	local orderTabel = Game.Orders;--get clinet order list
	
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	local turn = turn -2;
	
	if (next(orderTabel) ~= nil) then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end;
	
	if (lastTurn == nil) then 
		UI.Alert('Failed to retrive history. Please try again')
		return;
	end;
	
	local maxDeployBonues = {}; --aray with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonues[bonus.ID] = bonus.Amount --store the bonus value
	end;
	
	local newOrder;
	
	for _,order in pairs(lastTurn) do
		if (order.PlayerID == Game.Us.ID) then
			if (order.proxyType == "GameOrderDeploy")then
					--check that we own the territory
				if (Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID) then
					--check that we have armies to deploy
					local bonusID;
					for i, bonus in ipairs(Game.Map.Territories[order.DeployOn].PartOfBonuses) do
						print(bonus)
						bonusID = bonus;
						break;
					end;
					--make sure we deploy more then 0
					if (order.NumArmies == 0) then break; end;
					if (maxDeployBonues[bonusID] == 0) then break; end;	
					if (maxDeployBonues[bonusID] - order.NumArmies >=0) then --deploy full
						maxDeployBonues[bonusID] = maxDeployBonues[bonusID] - order.NumArmies
						newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false)
						table.insert(orderTabel, newOrder);
					elseif (maxDeployBonues[bonusID] > 0) then --deploy the max we can
						newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonues[bonusID], order.DeployOn, false)
						table.insert(orderTabel, newOrder);
						maxDeployBonues[bonusID] = 0;
					end;
				end;
			end;
		end;
	end;
	--update client orders list
	Game.Orders = orderTabel;
end;

function AddOrdersConfirmes()	
	Game.GetDistributionStanding(function(standing) getDistHelper(standing) end)
	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;	
	if (Distribution == nil) then --no dist
		firstTurn = 0;
	end;
	if(turn -1  <= firstTurn) then
		UI.Alert("You can't use the mod during distribution or for the first turn.");
		return;
	end;
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	local turn = turn -2;
	Game.GetTurn(turn, function(turnThis) getTurnHelper(turnThis) end)
	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	local orderTabel = Game.Orders;--get clinet order list
	if (next(orderTabel) ~= nil) then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end;
	
	if (lastTurn == nil) then 
		UI.Alert('Failed to retrive history. Please try again')
		return;
	end;
	
	local maxDeployBonues = {}; --aray with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonues[bonus.ID] = bonus.Amount --store the bonus value
	end;
	
	local newOrder;
	
	for _,order in pairs(lastTurn) do
		if (order.PlayerID == Game.Us.ID) then
			if (order.proxyType == "GameOrderDeploy")then
					--check that we own the territory
				if (Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID) then
					--check that we have armies to deploy
					local bonusID;
					for i, bonus in ipairs(Game.Map.Territories[order.DeployOn].PartOfBonuses) do
						print(bonus .. ' bonusID')
						bonusID = bonus;
						break;
					end;
					--make sure we deploy more then 0
					if (order.NumArmies == 0) then break; end;
					if (maxDeployBonues[bonusID] == 0) then break; end;
					
					if (maxDeployBonues[bonusID] - order.NumArmies >=0) then --deploy full
						maxDeployBonues[bonusID] = maxDeployBonues[bonusID] - order.NumArmies
						newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false)
						table.insert(orderTabel, newOrder);
					elseif (maxDeployBonues[bonusID] > 0) then --deploy the max we can
						newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonues[bonusID], order.DeployOn, false)
						table.insert(orderTabel, newOrder);
						maxDeployBonues[bonusID] = 0;
					end;
				end;
			end;
			if (order.proxyType == "GameOrderAttackTransfer") then
				if (Game.Us.ID == standing.Territories[order.From].OwnerPlayerID) then --from us 
					if (Game.Us.ID == standing.Territories[order.To].OwnerPlayerID) then -- to us
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, false, order.NumArmies, false)
						table.insert(orderTabel, newOrder);
					end;
				end;
			end;
		end;
	end;
	--update client orders list
	Game.Orders = orderTabel;
end;

function getTurnHelper(turn)
	lastTurn = turn.Orders;
end;

function getDistHelper(standing)
	Distribution = standing;
end;
