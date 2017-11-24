--TODO BUGS: Needs to update the menu when turn advances. Else we get a strange bug?

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game; --global variables
	LastTurn = {}; 
	Distribution = {};
	
	setMaxSize(450, 350);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Settings.LocalDeployments == false) then
		UI.CreateLabel(vert).SetText("This mod only works in Local Deployment games.  This isn't a Local Deployment.");
		return;
	end

	if (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		UI.CreateLabel(vert).SetText("You cannot do anything since you're not in the game");
		return;
	end
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	addOrders = UI.CreateButton(row1).SetText("Add last turn's deployment and transfears").SetOnClick(AddOrdersConfirmes);
	
	local row2 =  UI.CreateHorizontalLayoutGroup(vert);
	clearOrders = UI.CreateButton(row1).SetText("Clear Orders").SetOnClick(clearOrders);
end

function clearOrders()
	local orderTabel = Game.Orders;--get clinet order list
	if(next(orderTabel) ~= nil) then
		orderTabel = {};
		Game.Orders = orderTabel;
	end;
end;


function AddOrdersConfirmes()	
	Game.GetDistributionStanding(function(standing) getDistHelper(standing) end)
	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;
	if (Distribution == nil) then --no dist
		firstTurn = 0;
	end;
	if(turn  <= firstTurn) then
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
		print('lastTurn == nil')
		UI.Alert('Failed to retrive history. Please try again')
		return;
	end;
	local newOrder;
	for _,order in pairs(lastTurn) do
		if (order.PlayerID == Game.Us.ID) then
			if (order.proxyType == "GameOrderDeploy")then
					--check that we own the territory
				if (Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID) then
					newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false)
					table.insert(orderTabel, newOrder);
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
	--TODO check that we don't deploy more armies then we have	
	--update client orders list
	Game.Orders = orderTabel;
end;

function getTurnHelper(turn)
	lastTurn = turn.Orders;
end;

function getDistHelper(standing)
	Distribution = standing;
end;


function Dump(obj)
	if obj.proxyType ~= nil then
		DumpProxy(obj);
	elseif type(obj) == 'table' then
		DumpTable(obj);
	else
		print('Dump ' .. type(obj));
	end
end
function DumpTable(tbl)
    for k,v in pairs(tbl) do
        print('k = ' .. tostring(k) .. ' (' .. type(k) .. ') ' .. ' v = ' .. tostring(v) .. ' (' .. type(v) .. ')');
    end
end
function DumpProxy(obj)

    print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end
