function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game; --global variables
	print(Game.Game.ID .. ' GameID');
	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(450, 300);

	vert = UI.CreateVerticalLayoutGroup(rootParent);
	vert2 = UI.CreateVerticalLayoutGroup(rootParent);

	if (not game.Settings.LocalDeployments) then
		return UI.CreateLabel(vert).SetText("This mod only works in Local Deployment games. This isn't a Local Deployment.")
	elseif (not game.Us or game.Us.State ~= WL.GamePlayerState.Playing) then
		return UI.CreateLabel(vert).SetText("You cannot do anything since you're not in the game.");
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	addOrders = UI.CreateButton(row1).SetText("Add last turns deployment and transfers").SetOnClick(AddOrdersHelper).SetColor("#00ff05");
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	addDeployOnly = UI.CreateButton(row2).SetText("Add last turns deployment only").SetOnClick(AddDeployHelper).SetColor("#00ff05");
	local row3 =  UI.CreateHorizontalLayoutGroup(vert);
	clearOrders = UI.CreateButton(row3).SetText("Clear Orders").SetOnClick(clearOrdersFunction).SetColor("#0000FF");
end

function clearOrdersFunction()
	if(Game.Us.HasCommittedOrders)then
		return UI.Alert("You need to uncommit first");
	end
	local orderTabel = Game.Orders;--get client order list

	if (next(orderTabel) ~= nil) then
		orderTabel = {}
		Game.Orders = orderTabel
	end
end;

function AddDeploy()
	print ('running AddDeploy');

	
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	
	local orderTabel = Game.Orders;--get client order list
	if (next(orderTabel) ~= nil) then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end;
	
	
	local maxDeployBonues = {}; --aray with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonues[bonus.ID] = bonus.Amount --store the bonus value
	end;
	
	local newOrder;
	
	for _,order in pairs(LastTurn) do
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
	print ('running addOrders');
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		return;
	end
	local standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	local orderTabel = Game.Orders;--get clinet order list
	if (next(orderTabel) ~= nil) then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end;
	
	
	local maxDeployBonues = {}; --aray with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonues[bonus.ID] = bonus.Amount --store the bonus value
	end;
	
	local newOrder;
	
	for _,order in pairs(LastTurn) do
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
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false)	
						table.insert(orderTabel, newOrder);
					end;
				end;
			end;
		end;
	end;
	--update client orders list
	Game.Orders = orderTabel;
end;

function AddDeployHelper()
	standing = Game.LatestStanding; --used to make sure we can make the deploy/transfer
	LastTurn = Game.Orders

	--can we get rid of this Call?
	Game.GetDistributionStanding(function(data) getDistHelper(data)  end)
	
	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;
	if (Distribution == nil) then --auto dist
		firstTurn = 0;
	end;
	if(turn -1 <= firstTurn) then
		UI.Alert("You can't use the mod during distribution or for the first turn.");
		return;
	end;
	
	local turn = turn -2;
	print('request Game.GetTurn for turn: ' .. turn);
	Game.GetTurn(turn, function(data) getTurnHelperAdd(data) end)--getTurnHelperAdd(data) end)
end;

function AddOrdersHelper()
	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	LastTurn = Game.Orders

	--can we get rid of this Call?
	Game.GetDistributionStanding(function(data) getDistHelper(data)  end)

	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;
	if (Distribution == nil) then --auto dist
		firstTurn = 0;
	end;
	if(turn -1 <= firstTurn) then
		UI.Alert("You can't use the mod during distribution or for the first turn.");
		return;
	end;
	
	local turn = turn -2;
	print('request Game.GetTurn for turn: ' .. turn);
	Game.GetTurn(turn, function(data) getTurnHelperAddOrders(data) end)--getTurnHelperAdd(data) end)
end;

function getTurnHelperAdd(prevTurn)
	print('got prevTurn');
	LastTurn = prevTurn.Orders;
	AddDeploy();
end;

function getTurnHelperAddOrders(prevTurn)
	print('got prevTurn');
	LastTurn = prevTurn.Orders;
	AddOrdersConfirmes();
end;

--Your function will be called with nil if the distribution standing is not available, 
--for example if it's an automatic distribution game
function getDistHelper(data)
	print('got Distribution');
	Distribution = data;
end;
