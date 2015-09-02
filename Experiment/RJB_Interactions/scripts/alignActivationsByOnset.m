function [alignedActivations, t_relOnset, shift] = alignActivationsByOnset(tempActivations, onsetSamples, t)
    shift = onsetSamples-round(mean(onsetSamples));
    
    newI = (1-(min(shift))):(length(t)-max(shift));
    t_relOnset = t(newI) - t(round(mean(onsetSamples)));
    
    alignedActivations = zeros(length(newI), size(tempActivations,2));
         
    for c = 1:length(onsetSamples)
        alignedActivations(:, c) = tempActivations(newI+shift(c), c);
    end
end