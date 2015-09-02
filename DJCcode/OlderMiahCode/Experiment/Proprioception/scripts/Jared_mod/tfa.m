%% do time frequency plots for all electrodes that have significant
%% interactions

%modified DJC 7/2014 to do [1:200] rather than [1:3:200], and alternate
%between [-1 1] or [-2 2] for viewing. To try and match Jared's graphs,
%also try [-1.5 1.5] Modified back to [1:3:200], Miah said [1:200] would
%probably be overkill

%modified output of function DJC 7/2014
function [t,fw,normC] = tfa(HGSigs, BetaSigs, windows, ts, Montage, aggregate, activities, fs, restLength, legendEntries)

doTFA = input('do time frequency analyses [y]/n: ', 's');
if (strcmpi(doTFA, 'n'))
    return; % early return
end
 
trodeList = input ('list the electrodes to be analyzed in matlab vector format. \n  Leave blank if you want to analyze electrodes with significant RSA values: ', 's');
% find electrodes of interest
if (isempty(trodeList) == false)
    eval(sprintf('interesting = %s', trodeList));
else
    interesting = find(sum(HGSigs,1) > 0 | sum(BetaSigs,1) > 0);
end

if isempty(interesting);
    fprintf('no significant RSAs found...\n')
    return;
end

fw = [1:3:200]; %modified by DJC back and forth between 1:200 and 1:3:200

% we're making a plot for each electrode for each activity
% and grouping the plots by activity (all electrodes in a figure)
for activityIdx = 1:length(activities)
    figure;
    wins = windows{activityIdx}(:,interesting,:);
    t = ts{activityIdx};
    
    obsCount = size(wins, 1);
    dim = ceil(sqrt(length(interesting)));

    if (obsCount > 0) % means there's one or more observation of this activity
        for chanIdx = 1:length(interesting)
            subplot(dim,dim,chanIdx);
            
            [C, ~, ~, ~] = time_frequency_wavelet(squeeze(wins(:,chanIdx,:)), fw, fs, 1, 1, 'CPUtest');
            normC=normalize_plv(C',C(t>min(t)+0.2*restLength/fs & t<-0.2*restLength/fs,:)');

            image = imagesc(t,fw,normC);
            axis xy;
            set_colormap_threshold(gcf, [-2 2], [-10 10], [1 1 1]);   % changed to [-1 1] DJC 7/2014     
            title(trodeNameFromMontage(interesting(chanIdx),Montage)); 
        end
    end
    maximize;
    if (aggregate)
        mtit('aggregate', 'xoff', 0, 'yoff', 0.025);
    else
        try mtit(legendEntries{activityIdx}, 'xoff', 0, 'yoff', 0.025);
        catch mtit('Time-frequency for activity', 'xoff', 0, 'yoff', 0.025);
            fprintf('No legend entries...may result if using glove epochs...\n')
        end
    end
end
    