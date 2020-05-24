require 'Utilities'

function Client_PresentConfigureUI(rootParent)
	local initialReverseDist = Mod.Settings.ReverseDist;
	local initialwastlandsOnly = Mod.Settings.wastlandsOnly;
	local initialIncomeBiggestBonus = Mod.Settings.incomeBiggestBonus;
	local initialINSS = Mod.Settings.INSSmap;
	
	if initialReverseDist == nil then initialReverseDist = false; end	
	if initialwastlandsOnly == nil then initialwastlandsOnly = false; end;
	if initialIncomeBiggestBonus == nil then initialIncomeBiggestBonus = false; end
	if initialINSS == nil then initialINSS = false; end
	
	local mainContainer = UI.CreateVerticalLayoutGroup(rootParent);
	
	local vert = UI.CreateVerticalLayoutGroup(mainContainer);
	UI.CreateLabel(vert).SetText("If the settings would produce a non-working distribution, the mod will turn it into a full distribution. You also have to make sure to select either warlords or city distrubution in the game settings and Manual Distribution. At the moment, combining settings below is not supported (with the exception of inverse).");	
	
	local HorzLayout = UI.CreateHorizontalLayoutGroup(mainContainer);
	reverseDistCheckBox = UI.CreateCheckBox(HorzLayout).SetIsChecked(initialReverseDist).SetText('Do the inverse of the settings below');
	local HorzLayout = UI.CreateHorizontalLayoutGroup(mainContainer);
	wastlandsOnlyCheckBox = UI.CreateCheckBox(HorzLayout).SetIsChecked(initialwastlandsOnly).SetText('Only bonuses with wastlands are pickable');
	local HorzLayout = UI.CreateHorizontalLayoutGroup(mainContainer);
	incomeBiggestBonusCheckBox = UI.CreateCheckBox(HorzLayout).SetIsChecked(initialIncomeBiggestBonus).SetText('Only bonuses with a high (4) income are pickable');
	local HorzLayout = UI.CreateHorizontalLayoutGroup(mainContainer);
	INSSmapsCheckBox = UI.CreateCheckBox(HorzLayout).SetIsChecked(initialINSS).SetText('Check this if for INSS maps. All INSS maps are not supported.');
	
end