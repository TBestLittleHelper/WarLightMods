function PresentModWinConSettings()
	Conditionsrequiredforwinit = Mod.Settings.Conditionsrequiredforwin;
	if(Conditionsrequiredforwinit == nil)then
		Conditionsrequiredforwinit = 1;
	end
	Capturedterritoriesinit = Mod.Settings.Capturedterritories;
	if(Capturedterritoriesinit == nil)then
		Capturedterritoriesinit = 0;
	end
	Lostterritoriesinit = Mod.Settings.Lostterritories;
	if(Lostterritoriesinit == nil)then
		Lostterritoriesinit = 0;
	end
	Ownedterritoriesinit = Mod.Settings.Ownedterritories;
	if(Ownedterritoriesinit == nil)then
		Ownedterritoriesinit = 0;
	end
	Capturedbonusesinit = Mod.Settings.Capturedbonuses;
	if(Capturedbonusesinit == nil)then
		Capturedbonusesinit = 0;
	end
	Lostbonusesinit = Mod.Settings.Lostbonuses;
	if(Lostbonusesinit == nil)then
		Lostbonusesinit = 0;
	end
	Ownedbonusesinit = Mod.Settings.Ownedbonuses;
	if(Ownedbonusesinit == nil)then
		Ownedbonusesinit = 0;
	end
	Killedarmiesinit = Mod.Settings.Killedarmies;
	if(Killedarmiesinit == nil)then
		Killedarmiesinit = 0;
	end
	Lostarmiesinit = Mod.Settings.Lostarmies;
	if(Lostarmiesinit == nil)then
		Lostarmiesinit = 0;
	end
	Ownedarmiesinit = Mod.Settings.Ownedarmies;
	if(Ownedarmiesinit == nil)then
		Ownedarmiesinit = 0;
	end
	Eleminateaisinit = Mod.Settings.Eleminateais;
	if(Eleminateaisinit == nil)then
		Eleminateaisinit = 0;
	end
	Eleminateplayersinit = Mod.Settings.Eleminateplayers;
	if(Eleminateplayersinit == nil)then
		Eleminateplayersinit = 0;
	end
	Eleminateaisandplayersinit = Mod.Settings.Eleminateaisandplayers;
	if(Eleminateaisandplayersinit == nil)then
		Eleminateaisandplayersinit = 0;
	end
	terrconditioninit = Mod.Settings.terrcondition
	if(terrconditioninit == nil)then
		terrconditioninit = {};
	end
	ShowUI();
end
function ShowUI()
	local num = 0;
	local conditionnumber = 14;

    --TODO check if we can suport commanders OR put up an important text msg about limits.
	UI.CreateLabel(vertlistWinCon[0]).SetText('To disable a win condition, set it to 0.');
	UI.CreateLabel(vertlistWinCon[1]).SetText('Number of conditions required for a win');
	inputConditionsrequiredforwin = UI.CreateNumberInputField(vertlistWinCon[1]).SetSliderMinValue(1).SetSliderMaxValue(11).SetValue(Conditionsrequiredforwinit);
    UI.CreateLabel(vertlistWinCon[2]).SetText('Captured this many territories');
	inputCapturedterritories = UI.CreateNumberInputField(vertlistWinCon[2]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Capturedterritoriesinit);
	UI.CreateLabel(vertlistWinCon[3]).SetText('Lost this many territories    ');
	inputLostterritories = UI.CreateNumberInputField(vertlistWinCon[3]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Lostterritoriesinit);
	UI.CreateLabel(vertlistWinCon[4]).SetText('Owns this many territories    ');
	inputOwnedterritories = UI.CreateNumberInputField(vertlistWinCon[4]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Ownedterritoriesinit);
	UI.CreateLabel(vertlistWinCon[5]).SetText('Captured this many bonuses    ');
	inputCapturedbonuses = UI.CreateNumberInputField(vertlistWinCon[5]).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(Capturedbonusesinit);
	UI.CreateLabel(vertlistWinCon[6]).SetText('Lost this many bonuses        ');
	inputLostbonuses = UI.CreateNumberInputField(vertlistWinCon[6]).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(Lostbonusesinit);
	UI.CreateLabel(vertlistWinCon[7]).SetText('Owns this many bonuses        ');
	inputOwnedbonuses = UI.CreateNumberInputField(vertlistWinCon[7]).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(Ownedbonusesinit);
	UI.CreateLabel(vertlistWinCon[8]).SetText('Killed this many armies       ');
	inputKilledarmies = UI.CreateNumberInputField(vertlistWinCon[8]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Killedarmiesinit);
	UI.CreateLabel(vertlistWinCon[9]).SetText('Lost this many armies         ');
	inputLostarmies = UI.CreateNumberInputField(vertlistWinCon[9]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Lostarmiesinit);
	UI.CreateLabel(vertlistWinCon[10]).SetText('Owns this many armies        ');
	inputOwnedarmies = UI.CreateNumberInputField(vertlistWinCon[10]).SetSliderMinValue(0).SetSliderMaxValue(1000).SetValue(Ownedarmiesinit);
	UI.CreateLabel(vertlistWinCon[11]).SetText("Eleminated this many ais(players turned into ai don't count)");
	inputEleminateais = UI.CreateNumberInputField(vertlistWinCon[11]).SetSliderMinValue(0).SetSliderMaxValue(39).SetValue(Eleminateaisinit);
	UI.CreateLabel(vertlistWinCon[12]).SetText('Eliminated this many players  ');
	inputEleminateplayers = UI.CreateNumberInputField(vertlistWinCon[12]).SetSliderMinValue(0).SetSliderMaxValue(39).SetValue(Eleminateplayersinit);
	UI.CreateLabel(vertlistWinCon[13]).SetText('Eliminated this many AIs and players');
	inputEleminateaisandplayers = UI.CreateNumberInputField(vertlistWinCon[13]).SetSliderMinValue(0).SetSliderMaxValue(39).SetValue(Eleminateaisandplayersinit);
	

	--Territory conditions
	UI.CreateButton(vertlistWinCon[14]).SetText('Save territory conditions').SetOnClick(saveTerritoryConditions);

	inputterrcondition = {};
	inputWinConTerr = {}
	for i=0,5,1 do 
		inputWinConTerr[i] = {};
		inputWinConTerr[i].Terrname = UI.CreateTextInputField(vertlistWinCon[15+i]).SetPlaceholderText(' Enter territory name').SetText("").SetPreferredWidth(200).SetPreferredHeight(30);
		
		if (terrconditioninit[i] ~= nil )then 
			if (terrconditioninit[i].Terrname ~= nil) then inputWinConTerr[i].Terrname.SetText(terrconditioninit[i].Terrname) end;
		end;
		UI.CreateLabel(vertlistWinCon[15+i]).SetText("controlled for ");
		inputWinConTerr[i].Turnnum = UI.CreateNumberInputField(vertlistWinCon[15+i]).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(0);
		if (terrconditioninit[i] ~= nil )then 
			if (terrconditioninit[i].Turnnum ~= nil) then inputWinConTerr[i].Turnnum.SetValue(terrconditioninit[i].Turnnum) end;
		end;
		UI.CreateLabel(vertlistWinCon[15+i]).SetText("turns");
	end;	
	saveTerritoryConditions();
end

function saveTerritoryConditions()
	for i=0,5,1 do 
		inputterrcondition[i] = inputWinConTerr[i];
	end
end;

--TODO remove and use util instead?
function tablelength(arr)
	local num = 0;
	for _,elem in pairs(arr)do
		num = num + 1;
	end
	return num;
end
