%%
Z_Constants;
addpath ./scripts;

%% 

load(fullfile(META_DIR, 'screened_interactions.mat'), 'resultA');

badsub = find(strcmp(SIDS, '38e116'));
resultA(ismember(resultA(:, 1), badsub), :) = [];

keeps = resultA(:, 10) <= 0.05 & resultA(:, 9) == 1;

ihists = zeros(241, sum(keeps));
classes = zeros(sum(keeps), 1);
count = 0;

ctr = 0;
for ctr = 1:length(SIDS)
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject    
    
    load(fullfile(META_DIR, [sid '_results']), 'bas', 'class', 'hmats', 'tlocs');
    load(fullfile(META_DIR, [sid '_extracted']), 'trodes', 't', 'alignedT', 'fs');
    
    tConsidered = t >= 0 & t < 1;
    tAConsidered = alignedT >= -0.502 & alignedT <= 0.5;
    
    controlLocs(ctr, :) = tlocs(trodes(1), :);
    
    %% first, go out and get all the simulation results
    allmaxes = [];
    allmins = [];
    
    arrs = [];
    
    for chani = 2:length(trodes)
        chan = trodes(chani);
        
        load(fullfile(META_DIR, sid, [sid '_simulations_' num2str(chan) '.mat']), '*mins*', '*maxes*');
        if (size(maxes, 2) ~= 100 || size(mins, 2) ~= 100)
            warning(sprintf('incorrect number of simulation runs for %s', sid));
        else            
            allmaxes = cat(2, allmaxes, maxes);        
            allmins  = cat(2, allmins, mins);
            
            arrs(:,:,end+1) = maxes;
        end
    end       
    
%     % sort out what the thresholds are for this specific subject
    
    lims = max(arrs, [], 3);
    
    for interactionType = 1:size(lims, 1)
        lims(interactionType, :) = sort(lims(interactionType, :), 'descend');
    end
    
    % get uncorrected distributions
    arrs = sort(arrs,2,'descend');
        
    %% now, evaluate all interactions
    for chani = 2:length(trodes)
        chan = trodes(chani);
        
        idx = find(resultA(:,1) == ctr & resultA(:,2) == chan & resultA(:, 9) == 1);
        
        if (resultA(idx, 10) <= 0.05) % this is an interaction of interest
                        
            % now load the interaction data
            load(fullfile(META_DIR, sid, [sid '_interactions_' num2str(chan) '.mat']), 'lags', 'mAlInt');
            lags = lags / fs;
            
%             [weight, tcenter, lcenter] = findBestLag(squeeze(mAlInt(d,:,tAConsidered)), alignedT(tAConsidered), lags, lims(d, 5), SHOW_INT_PLOTS);
% 

            collapsedInteraction = squeeze(mAlInt(1,:,tAConsidered));
            collapsedInteraction = double(collapsedInteraction >= lims(1,5));
%             collapsedInteraction = collapsedInteraction .* double(collapsedInteraction >= lims(1,5));
            collapsedInteraction = sum(collapsedInteraction, 2);
            collapsedInteraction = collapsedInteraction / max(collapsedInteraction);
            
            count = count + 1;
            ihists(:, count) = collapsedInteraction;
            classes(count) = resultA(idx, 6);
            
            if (count == 2)
                figure;
                lagPlot2(squeeze(mAlInt(1, :, tAConsidered)), squeeze(mAlInt(1, :, tAConsidered)) >= lims(1, 5), [], [], [], [], alignedT(tAConsidered), lags)

                % TODO
                figure
                plot(collapsedInteraction, lags);
                ylim([min(lags) max(lags)]);
                xlabel('normalized fraction of significant pixels');
                ylabel('lag(s)');
                axis ij
                xlim([-0.1 1.1])
            end
                
%             lagPlot(squeeze(mAlInt(1, :, tAConsidered)), (squeeze(mAlInt(1, :, tAConsidered)) >= lims(1, 5)), ...
%                     squeeze(mAlIntEarly(1, :, tAConsidered)), (squeeze(mAlIntEarly(1, :, tAConsidered)) >= earlyarrs(1, 5, chani)), ...
%                     squeeze(mAlIntLate(1, :, tAConsidered)), (squeeze(mAlIntLate(1, :, tAConsidered)) >= latearrs(1, 5, chani)), ...
%                     alignedT(tAConsidered), lags);
            
        end      
    end
end

%% do the plot
figure
subplot(211);
imagesc(1:size(ihists, 2), lags, ihists);
xlabel('interaction #');
ylabel('lag (s)');
subplot(212);

plot(lags, sum(ihists, 2) / size(ihists, 2), 'k', 'linew', 2);
hold on;

uclasses = unique(classes);

color = 'rgb';
classnames = {'nonmod', 'ctllike', 'effort'};

leg = {};
leg{1} = sprintf('all (N=%d)', size(ihists, 2));

for classi = 1:length(uclasses)
    temp = sum(ihists(:, classes==uclasses(classi)), 2) / sum(classes==uclasses(classi));
    plot(lags, temp, color(classi), 'linew', 2);
    leg{end+1} = sprintf('%s (N=%d)', classnames{classi}, sum(classes==uclasses(classi)));
end
hold off;

xlim([min(lags) max(lags)]);
xlabel('Lag (s)');
ylabel('Lag distribution of sig interactions (fraction)');
legend(leg);

