function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText("Percent of pickable territories availible: " .. Mod.Settings.PickablePercent)
end
