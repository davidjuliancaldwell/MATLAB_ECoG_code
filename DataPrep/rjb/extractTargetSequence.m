function sequence = extractTargetSequence(sta)
    [starts,~] = getEpochs(sta.Feedback, 1, 0);
    sequence = sta.TargetCode(starts);
end