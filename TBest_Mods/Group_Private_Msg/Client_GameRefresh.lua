require('Utilities');
require('Client');
require('Client_PresentMenuUI')

--remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.
-- HighestAllianceIDSeen = 0;
-- HighestProposalIDSeen = 0; 

function Client_GameRefresh(game)
    --Skip if we're not in the game.  We can't use game.SendGameCustomMessage as a spectator
    if (game.Us == nil) then 
        return;
    end

    -- if (HighestAllianceIDSeen == 0 and Mod.PlayerGameData.HighestAllianceIDSeen ~= nil and Mod.PlayerGameData.HighestAllianceIDSeen > HighestAllianceIDSeen) then
        -- HighestAllianceIDSeen = Mod.PlayerGameData.HighestAllianceIDSeen;
    -- end
	print("Client_GameRefresh called RefreshGame")
	RefreshGame(game);
end