
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
		else
			Formula = Formula ..  '+ ';
		end
	Formula = Formula .. Mod.Settings.Amount;
	
	UI.CreateLabel(vert).SetText(Formula);
	UI.CreateLabel(vert).SetText('Change negative bonuses: ' .. tostring(Mod.Settings.ChangeNegavtive));
end

