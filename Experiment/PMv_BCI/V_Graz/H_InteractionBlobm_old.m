%%
Z_Constants;
addpath ./scripts;

%% perform analyses
load(fullfile(META_DIR, 'areas.mat'));

%% lets build a table of electrode information
trodes = [];

SHOW_INT_PLOTS = true;

ctr = 0;
for zid = SIDS
    sid = zid{:};
    ctr = ctr + 1;
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_interactions']));
    load(fullfile(META_DIR, [sid '_epochs']),'montage');
    load(fullfile(META_DIR, [sid '_results']), 'class', 'cchan');
    
    trs = trodesOfInterest{ctr};
    trs = trs(trs~=cchan);
    
    for chan = 1:size(alignedAverages, 1)
%         interaction = squeeze(alignedEarly(chan,:,:));
%         interaction = squeeze(alignedLate(chan,:,:));
        interaction = squeeze(alignedAverages(chan,:,:));
        interaction = repairSTWCPlot(interaction);
        lags = allLags(chan, :);
        t = allTs(chan, :);
                
        
        nint = (interaction - mean(interaction(:))) / std(interaction(:));        
        
        % focus only on the time period of interest
        tkeep = t >= -.5 & t <= .5;
        interaction = interaction(:, tkeep);
        nint = nint(:,tkeep);
        t = t(tkeep);

        thresh = 2;
        
        nzint = nint;
        nzint(nzint < thresh) = 0;

        labels = bwlabel(nzint);
        
        if (length(unique(labels)) > 1) % i.e. not just zero
            pixelValues = regionprops(labels, interaction .* (nzint > 0), 'pixelvalues');

            % here is the center of mass approach to blob selection
            masses = zeros(size(pixelValues));
            for z = 1:length(pixelValues)
                masses(z) = sum(pixelValues(z).PixelValues);
            end
            [weight,label] = max(masses);
            weight = log(weight);

%             % here is the 'biggest peak' approach
%             heights = zeros(size(pixelValues));
%             for z = 1:length(pixelValues)
%                 heights(z) = max(pixelValues(z).PixelValues);
%             end
%             [weight, label] = max(heights);

            labels(labels ~= label) = 0;
            labels = double(labels > 0);
            masked = interaction .* labels;

%             % weighted centroid approach to lag finding
%             center = regionprops(labels, masked, 'weightedcentroid');
%             tcenter = t(constrain(round(center.WeightedCentroid(1)), 1, length(t)));
%             lcenter = lags(constrain(round(center.WeightedCentroid(2)), 1, length(lags)));
            
            % max value approach to lag finding
            [lidx, tidx] = find(masked == max(max(masked)), 1, 'first');
            tcenter = t(tidx);
            lcenter = lags(lidx);

            if (SHOW_INT_PLOTS)
                % draw an image
                figure
                imagesc(t, lags, nzint);

                vline(0,'k:');
                hline(0,'k:');

                vline(tcenter);
                hline(lcenter);
                set_colormap_threshold(gcf, [-thresh thresh], [-5 5], [1 1 1]);

                title(sprintf('%s, %d (%d), lag=%f, time=%f', sid, trs(chan), class(trs(chan)), lcenter,tcenter));
            end

            % update electrode info
            % row 1 is sid
            % row 2 is channel number
            % row 3-5 are tal coords
            % row 6 is class (-1,0,1,2)
            % row 7 is interaction coeff
            % row 8 is interaction time
            % row 9 is interaction lag
            locs = trodeLocsFromMontage(sid, montage, true);

            trodes(end+1, :) = [...
                ctr ...
                trs(chan) ...
                locs(trs(chan),1) ...
                locs(trs(chan),2) ...
                locs(trs(chan),3) ...
                class(trs(chan)) ...
                weight ...
                tcenter ...
                lcenter ...
                ];
        end
    end
    
    toc;
end

%% take a look at some results
% gscatter(trodes(:, 6), trodes(:, 7), trodes(:,1));
% gscatter(trodes(:, 6), trodes(:, 8), trodes(:,1));
% gscatter(trodes(:, 6), trodes(:, 9), trodes(:,1));

%% interaction between lag and time by class
figure, 
ax = scatter(trodes(:,8), trodes(:,9));
hold on;
gscatter(trodes(:,8), trodes(:,9), trodes(:,6));
xlabel('time rel. HG onset (sec)');
ylabel('lag (sec) [neg implies ctl leads]');
axis ij;
xlim([-.5 .5]);
ylim([-.25 .25]);
vline(0, 'k:');
hline(0, 'k:');

legendOff(ax);
legend('non-modulated','control-like','effort', 'location', 'northwest');
title ('interaction between lag and time by class');

SaveFig(OUTPUT_DIR, 'scatter', 'eps', '-r600');
%% stats on mean lags and times for classes

feat = 9;

fprintf('summary\n');
fprintf(' trode counts: %d (%d %d %d)\n', length(trodes), sum(trodes(:,6)==0) , sum(trodes(:,6)==1) , sum(trodes(:,6)==2) );

[h, p] = ttest(trodes(:, feat));
if (h==1)
    fprintf(' PMv lag was significant @ p = %0.4f\n', p);
else
    fprintf(' PMv lag was NOT significant @ p = %0.4f\n', p);
end

for iclass = 0:2
    [h, p] = ttest(trodes(trodes(:,6)==iclass, feat));
    if (h==1)
        fprintf(' lag for class %d was significant @ p = %0.4f\n', iclass, p);
    else
        fprintf(' lag for class %d was NOT significant @ p = %0.4f\n', iclass, p);
    end
end

for pair = nchoosek(0:2, 2)'
    [h, p] = ttest2(trodes(trodes(:,6)==pair(1), feat), trodes(trodes(:,6)==pair(2), feat));
    if (h==1)
        fprintf(' lag difference for %d<=>%d was significant @ p = %0.4f\n', pair(1), pair(2), p);
    else
        fprintf(' lag difference for %d<=>%d was NOT significant @ p = %0.4f\n', pair(1), pair(2), p);
    end
end

% [h, p] = ttest(trodes(trodes(:,6)==2, 9))
% [h, p] = ttest(trodes(trodes(:,6)==1, 9))
% [h, p] = ttest(trodes(trodes(:,6)==0, 9))
% 
% [h, p] = ttest(trodes(:, 9))
% 
% [h,p] = ttest2(trodes(trodes(:,6)==1, 9), trodes(trodes(:,6)==0, 9))

% %% interaction between lag and time by subject
% figure, gscatter(trodes(:,8), trodes(:,9), trodes(:,1));
% title ('interaction between lag and time by subject');
% 
% %% weight as a function of time
% [~, idx] = sort(trodes(:,7),'descend');
% figure, stem(abs(trodes(idx,8)), trodes(idx,7));
% title ('weight as a function of time');

% locs = trodes(:, 3:5);
% locs(:, 1) = abs(locs(:, 1))+3;
% % 
% figure;
% PlotDotsDirect('tail', locs, trodes(:,6),'r',[0 2], 5, 'recon_colormap', [], false);
% title('class');
% % 
% % figure;
% % PlotDotsDirect('tail', locs, trodes(:,7),'r',[min(trodes(:,7)) max(trodes(:,7))], 5, 'recon_colormap', [], false);
% % title('weight');
% % 
% % figure;
% % PlotDotsDirect('tail', locs, trodes(:,8),'r',[min(trodes(:,8)) max(trodes(:,8))], 5, 'recon_colormap', [], false);
% % title('tcenter');
% % 
% figure;
% PlotDotsDirect('tail', locs, trodes(:,9),'r',[min(trodes(:,9)) max(trodes(:,9))], 5, 'recon_colormap', [], false);
% title('lcenter');
