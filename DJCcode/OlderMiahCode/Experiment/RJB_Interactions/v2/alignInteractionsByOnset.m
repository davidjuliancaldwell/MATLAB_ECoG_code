function [alignedInteractions, t_relOnset] = alignInteractionsByOnset(tempInteractions, onsetSamples, t)
    shift = onsetSamples-round(mean(onsetSamples));
    
    newI = (1-(min(shift))):(length(t)-max(shift));
    t_relOnset = t(newI) - t(round(mean(onsetSamples)));
    
    alignedInteractions = zeros(size(tempInteractions, 1), size(tempInteractions,2), length(newI));
         
    for c = 1:length(onsetSamples)
        alignedInteractions(c, :, :) = tempInteractions(c, :, newI+shift(c));
    end
end