function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText("Number of free orders: " .. Mod.Settings.FreeOrders)
end
