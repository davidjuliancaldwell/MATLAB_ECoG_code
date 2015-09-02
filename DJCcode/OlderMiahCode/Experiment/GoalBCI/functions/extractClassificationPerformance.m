function [labels, estimates, probabilities, biased] = extractClassificationPerformance(sta)
    Constants;
    [fbStarts, ~] = getEpochs(sta.Feedback, 1, false);
    
    labels = ismember(sta.TargetCode(fbStarts), UP);
    estimates = sta.ClassificationLabel(fbStarts) == 1;
    probabilities = double(sta.ClassificationPosterior1K(fbStarts)) / 1000;
    biased = sta.DidBias(fbStarts) == 1;
end