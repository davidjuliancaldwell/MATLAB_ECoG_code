%% computing zscore - DJC 8-14-2015 

function zscored = zscoreDJC(signalsMax,referenceMean,referenceSig)
% function zscored = zscoreAgainstInterest(signals, reference)
% signals is a matrix containing the maximum value of 
% calculates the zscore of the maximum amplitude in the CCEP of interest compared to signals during a rest period

        %number of samples before for -200 to -5 ms before stimulus 
        
        mu = mean(reference);
        sig = std(reference);
        
        zscored = (signalMax - referenceMean) ./ referenceSIg;

end