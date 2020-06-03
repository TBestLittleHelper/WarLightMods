require("Utilities")

function PresentMenuWinCon(rootParent, setMaxSize, setScrollable, game, close)
    root = rootParent;
    if (game.Us == nil) then
        UI.CreateLabel(rootParent).SetText("You have no progress since you aren't in the game");
        return;
    end
    setMaxSize(450, 350);
    UI.CreateLabel(rootParent).SetText('To win, you need to complete ' .. Mod.Settings.Conditionsrequiredforwin .. ' of the red conditions;').SetColor('#FF0000');
    if (Mod.Settings.Capturedterritories > 0)then 
        CreateLine('Captured this many territories : ',Mod.PlayerGameData.WinCon.Capturedterritories, Mod.Settings.Capturedterritories,0);
    end;
    if (Mod.Settings.Lostterritories > 0)then 
        CreateLine('Lost this many territories : ',Mod.PlayerGameData.WinCon.Lostterritories, Mod.Settings.Lostterritories,0);
    end;
    if (Mod.Settings.Ownedterritories > 0)then 
        CreateLine('Owns this many territories : ',Mod.PlayerGameData.WinCon.Ownedterritories, Mod.Settings.Ownedterritories,0);
    end;
    if (Mod.Settings.Capturedbonuses > 0)then 
        CreateLine('Captured this many bonuses : ',Mod.PlayerGameData.WinCon.Capturedbonuses, Mod.Settings.Capturedbonuses,0);
    end;
    if (Mod.Settings.Lostbonuses > 0)then 
        CreateLine('Lost this many bonuses : ',Mod.PlayerGameData.WinCon.Lostbonuses, Mod.Settings.Lostbonuses,0);
    end;
    if (Mod.Settings.Ownedbonuses > 0)then 
        CreateLine('Owns this many bonuses : ',Mod.PlayerGameData.WinCon.Ownedbonuses, Mod.Settings.Ownedbonuses,0);
    end;
    if (Mod.Settings.Killedarmies > 0)then 
        CreateLine('Killed this many armies : ',Mod.PlayerGameData.WinCon.Killedarmies, Mod.Settings.Killedarmies,0);
    end;
    if (Mod.Settings.Lostarmies > 0)then    
        CreateLine('Lost this many armies : ',Mod.PlayerGameData.WinCon.Lostarmies, Mod.Settings.Lostarmies,0);
    end;
    if (Mod.Settings.Ownedarmies > 0)then    
        CreateLine('Owns this many armies : ',Mod.PlayerGameData.WinCon.Ownedarmies, Mod.Settings.Ownedarmies,0);
    end;
    if (Mod.Settings.Eleminateais > 0)then    
        CreateLine('Eliminated this many AIs : ',Mod.PlayerGameData.WinCon.Eleminateais, Mod.Settings.Eleminateais,0);
    end;
    if (Mod.Settings.Eleminateplayers > 0)then    
        CreateLine('Eliminated this many players : ',Mod.PlayerGameData.WinCon.Eleminateplayers, Mod.Settings.Eleminateplayers,0);
    end;
    if (Mod.Settings.Eleminateaisandplayers  > 0)then    
        CreateLine('Eliminated this many AIs and players : ',Mod.PlayerGameData.WinCon.Eleminateaisandplayers, Mod.Settings.Eleminateaisandplayers,0);
    end;

  if(Mod.Settings.terrcondition ~= nil)then
      local hasterr = false;
      for _,condition in pairs(Mod.Settings.terrcondition)do
          hasterr = true;
          if(Mod.PlayerGameData.WinCon.HoldTerritories ~= nil and Mod.PlayerGameData.WinCon.HoldTerritories[getterrid(game,condition.Terrname)] ~= nil)then
              local terrid = getterrid(game,condition.Terrname);
              if(game.LatestStanding.Territories[terrid].OwnerPlayerID == game.Us.ID)then
                   CreateLine('Hold the territory ' .. condition.Terrname ..  ' for this many turns : ',Mod.PlayerGameData.WinCon.HoldTerritories[terrid], condition.Turnnum,-1);
              else
                  CreateLine('Hold the territory ' .. condition.Terrname ..  ' for this many turns : ',"not owned", condition.Turnnum,-1);
              end
          else
              local terrid = getterrid(game,condition.Terrname);
              if(terrid == -1)then
                  UI.CreateLabel(rootParent).SetText("Warning the territory " .. condition.Terrname .. " doesn't exist").SetColor('#FF0000');
              else
                  CreateLine('Hold the territory ' .. condition.Terrname ..  ' for this many turns : ',"", condition.Turnnum,-1);
              end
          end
      end
      if(hasterr == true)then
          UI.CreateLabel(rootParent).SetText("If you lose one of the territories, the condition restarts, when you get it again").SetColor('#FF0000');
      end
  end

  UI.CreateButton(rootParent).SetText("Go Back").SetColor("#0000FF").SetOnClick(function() 		
        RefreshMainDialog(close, game);
    end);
end

function getterrid(game,name)
  for _,terr in pairs(game.Map.Territories)do
      if(terr.Name == name)then
          return terr.ID;
      end
  end
  return -1;
end
function CreateLine(settingname,completed,variable,default)
  local lab = UI.CreateLabel(root);
  if(completed == nil)then
      completed = 0;
  end
  if(variable == nil)then
      if(completed ~= "")then
          lab.SetText(settingname .. completed .. '/' .. default);
      else
          lab.SetText(settingname .. default);
      end
  else
      if(completed ~= "")then
          lab.SetText(settingname .. completed .. '/' .. variable);
      else
          lab.SetText(settingname .. variable);
      end
  end
  if(variable ~= default)then
      lab.SetColor('#FF0000');
  end
end