function loc = getCtlLoc(subjid, isTail)
    if (strcmp(subjid, '26cb98'))
        mtg.MontageTokenized = {'Grid(36)'};
    elseif (strcmp(subjid, '38e116'))
        mtg.MontageTokenized = {'Grid(33)'};
    elseif (strcmp(subjid, '4568f4'))
        mtg.MontageTokenized = {'Grid(56)'};
    elseif (strcmp(subjid, '30052b'))
        mtg.MontageTokenized = {'Grid(29)'};
    elseif (strcmp(subjid, 'fc9643'))
        mtg.MontageTokenized = {'Grid(24)'};
    elseif (strcmp(subjid, 'mg'))
        mtg.MontageTokenized = {'Grid(12)'};
    elseif (strcmp(subjid, '04b3d5'))
        mtg.MontageTokenized = {'Grid(45)'};
    else
        warning ('unknown subjid entered');
        loc = [];
        return;
    end    
    loc = trodeLocsFromMontage(subjid, mtg, isTail);
end