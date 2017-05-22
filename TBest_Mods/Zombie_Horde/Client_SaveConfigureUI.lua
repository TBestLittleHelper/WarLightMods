
function Client_SaveConfigureUI(alert)
    Mod.Settings.ExtraArmies = numberInputField1.GetValue();
    Mod.Settings.ZombieID = zombieInputField.GetValue();
    Mod.Settings.RandomZombie = RandomZombieBox.GetIsChecked();
    Mod.Settings.RandomSeed = seedInputField.GetValue();
end
