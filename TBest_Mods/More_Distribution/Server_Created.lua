function Server_Created(Game, settings)
    --If we have wastlands, make sure they are a uniqe size. 
    if (settings.NumberOfWastelands > 0) then
        while (settings.WastelandSize  == settings.InitialNeutralsInDistribution or settings.WastelandSize == settings.InitialNonDistributionArmies)do
            settings.WastelandSize = settings.WastelandSize + 1;
        end;
    end;
end;