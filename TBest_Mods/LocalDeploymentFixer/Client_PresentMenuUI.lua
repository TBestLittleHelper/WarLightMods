function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game; --global variables
	LastTurn = {}; 
	
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
end

function AddOrdersConfirmes()
	
	if(Game.Us.HasCommittedOrders == true)then
		UI.Alert("You need to uncommit first");
		--since you can't write in the order table when the player has already commited
		return;
	end
	
	if(Game.Game.TurnNumber  == 0) then
		--TODO proper instead of lazy fix for no past turns
		UI.Alert("You can't use the mods for the first turn.");
		return;
	end;
	
	print('Getting turn ' .. Game.Game.TurnNumber - 2); -- -2, since this returns the uncompleted turn, and counts turn 0
	local turn = Game.Game.TurnNumber -2;
	Game.GetTurn(turn, function(turn) getTurnHelper(turn) end)

	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	
	local orderTabel = Game.Orders;--get clinet order list
	
	if lastTurn == nil then print ('nil') end;
	for _,order in pairs(lastTurn) do

		if (order.PlayerID == Game.Us.ID) then
			if (order.proxyType == "GameOrderDeploy")then
					--check that we own the territory
				if (Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID) then
					table.insert(orderTabel, order);
				end;
			end;
			if (order.proxyType == "GameOrderAttackTransfer") then
				if (Game.Us.ID == standing.Territories[order.From].OwnerPlayerID) then
					if (Game.Us.ID == standing.Territories[order.To].OwnerPlayerID) then
						table.insert(orderTabel, order);
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

	
