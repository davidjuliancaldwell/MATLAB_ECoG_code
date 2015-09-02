%% this script regenerates paths from ECoG recordings
% It currently doesn't work.
% tim sent an email on 3/4 with an attachment and 'reverse engineering' in
% the body with a script that lise wrote to do the AR stuff.

% Also look at a chat from tim on that same day for additional details
% Tim: sent
% 3:15 PM things to keep in mind:
%   intial normalizer files can be found in the parameters
% 3:16 PM 2) best case is to try to recreate the paths
%   by using a datafile where they WERE recorded
%   to double-check
%   3) check the "windowsize" parameter (or whatever its called)
%   most of the subjects had a 500ms period
%  me: yes, that was my plan. And it was the approach that I was taking using the fileplayback module, but the paths that I was getting were way off
%  Tim: where the power was summed over the last 500ms

clear;
fig_setup;

num = 5;

subjid = subjids{num};
id = ids{num};
% clear num;

[files, side, div] = getBCIFilesForSubjid(subjid);

fprintf('running analysis for %s\n', subjid);

bitdepth = 16;

for file = files
    display(file{:});
    
    [sig, sta, par] = load_bcidat(file{:});
    
    workingSignal = double(sig(:,par.TransmitChList.NumericValue));

    powerEstimate = zeros(size(workingSignal));
    bins = par.FirstBinCenter.NumericValue:par.BinWidth.NumericValue:par.LastBinCenter.NumericValue;

    for sample = 1:size(workingSignal, 1)
        samplesToLookBack = par.SamplingRate.NumericValue * par.WindowLength.NumericValue;
        x = workingSignal(max(1,sample-samplesToLookBack):sample, :);
        
        if length(x) > 2*par.ModelOrder.NumericValue
            for chan = 1:size(x, 2)
                [Pxx, w] = pyulear(x, par.ModelOrder.NumericValue);
            end
            
            %modelParams = ar(x, par.ModelOrder.NumericValue);
        else
            powerEstimate(sample, :) = 0;
        end
    end        
        
    % TEMP, delete me when ready
    break;
end