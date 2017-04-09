
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local string Formula = 'BonusValue = ';
	
		if (Mod.Settings.ChangeDefaultBonus) then
			Formula = Formula .. 'defaultBonusValue ';
		else
			Formula = Formula .. 'numberOfTerritories ';
		end
		
		if (Mod.Settings.Multiply) then
			Formula = Formula .. '* ';
			else if (Mod.Settings.Amount > -1) then --negative numbers get a '-' autmaticaly
				Formula = Formula ..  '+ ';
			end
		end
		Formula = Formula .. Mod.Settings.Amount;
		if (Mod.Settings.RandomFactor ~=0) then
			Formula = Formula .. ' + X'
		end
		
	UI.CreateLabel(vert).SetText(Formula);
		if (Mod.Settings.RandomFactor ~=0) then --if X is used
			UI.CreateLabel(vert).SetText('X is any random number from -'.. Mod.Settings.RandomFactor .. ' to ' .. Mod.Settings.RandomFactor);
		end
	UI.CreateLabel(vert).SetText('Change negative bonuses: ' .. tostring(Mod.Settings.ChangeNegavtive));
end
