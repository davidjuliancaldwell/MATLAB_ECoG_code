% this script will be very similar to the previous poster where we look at
% how many areas show significant power changes in HG as a fxn of time
% within the trial.  What we would hope to see is that at about t=500msec
% this number pops way up.

Z_Constants;
addpath ./functions;

%% process each subject in a row
allts = [];

MIN_T = -2;
MAX_T = 1.5;

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('%s-epochs.mat', sid)));

    lastt = find(t <= 1.5, 1, 'last');    
    epochs = zeros(size(data, 2), size(data, 1), lastt);
    
    for e = 1:size(data, 2)
%         temp = [data{:,e}];
        temp = GaussianSmooth([data{:,e}], round(.250*fs));
        epochs(e, :, :) = temp(1:lastt, :)';
    end    

    epochs(:, bad_channels, :) = 0;
    
    % ok, now, marching through time, we're going to look at the predictive
    % power of each channel / freq / time
    up = double(~ismember(targets, DOWN));
    
    % initialize some variables
    blobs = {};
    blobsize = {};
    blobdistro = [];
    tstats = {};
    
    % calculate the real stats
%     for freqi = 1:size(repochs, 1)        

    [h, p, ~, tstat] = ttest2(epochs(up==1,:,:),epochs(up==0,:,:),'dim', 1, 'var', 'unequal');
    h = squeeze(h);
    h(isnan(h)) = 0;
    tstat = squeeze(tstat.tstat);
    
    tstat(~h) = 0;
    
    figure
    subplot(211);
    imagesc(t(1:lastt), 1:size(tstat, 1), tstat);
    load('america'); colormap(cm);
    set(gca, 'clim', [-max(abs(tstat(:))) max(abs(tstat(:)))]);    
    colorbar;
    vline([-preDur 0]);
    title(SIDS{c});
    
    subplot(212);
    prettyline(t(1:lastt), squeeze(epochs(:,cchan,:))', up, 'rb');
    title(['cchan ' num2str(cchan)]);        
    legend('down','up','location', 'northwest');
    
    vline([-preDur 0]);
    ax = colorbar; set(ax,'Visible','off')

    SaveFig(OUTPUT_DIR, ['www ' sid], 'eps', '-r300');

        
    allts(c, :) = mean(tstat(:, t>=MIN_T & t<=MAX_T));
%     allts(c, :) = max(tstat(:, t>=MIN_T & t<=MAX_T));
    
%         gridtstat = linToGrid(tstat, 1);
%         blobs = bwlabeln(gridtstat);
%         blobsize = regionprops(blobs, 'FilledArea');
%         blobsize = [blobsize(:).FilledArea];                
%         
%         % do the bootstrap
%         NN = 100;
%         
%         for N = 1:NN
%             fprintf('.');
%         end
%         fprintf('\n');
%         
%         for N = 1:NN
%             fprintf('.');
%             sup = shuffle(up);
%             [h, p, ~, tstat] = ttest2(epochs(sup==1,:,:),epochs(sup==0,:,:),'dim', 1, 'var', 'unequal');
%             h = squeeze(h);
%             h(isnan(h)) = 0;
%             tstat = squeeze(tstat.tstat);
%             tstat(~h) = 0;
%             
%             gridtstat = linToGrid(tstat, 1);
%             randblobs = bwlabeln(gridtstat);
%             randsize = regionprops(randblobs, 'FilledArea');
%             blobdistro(freqi, N) = max([randsize(:).FilledArea]);                
%         end        
%         fprintf('\n');        
% %     end    
%     
%     sigthresh = prctile(blobdistro, 100-5, 2); % no correction
% %     sigthresh = prctile(blobdistro, 100-(5/size(repochs, 1)), 2); % bonf correction across frequencies            
    
%     %% now viz
%     figure;
%     
%     load recon_colormap
% 
%     cval = max(max(max(abs(cat(3,tstats{:})))));
%     
%     for bandi = 1:size(repochs, 1)
%         subplot(3,2,bandi);
% 
%         h = ismember(blobs{bandi}, find(blobsize{bandi}>=sigthresh(bandi)));
%         temp = tstats{bandi} .* gridToLin(h, 1:2);
%         
%         imagesc(rt, 1:size(repochs, 3), temp);
%         vline([-preDur 0 fbDur], 'k');
%         colormap(cm);
%         set(gca, 'clim', [-cval cval]);
%         colorbar;
%         title(BAND_NAMES{bandi});
%     end
%     
%     mtit(sid);
%     
%     fname = sprintf('what_when_where_%s', sid);
%     SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
%     SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
%     
%     save(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), 'tstats', 'blob*', 'repochs', 'montage', 'rt', 'tgts', 'sigthresh', 'winsize', 'stepsize');    
end

%%
figure
tk = t(t>=MIN_T&t<=MAX_T);
plot(tk, median(allts), 'k', 'linew', 2);
hold on;
plot(tk, prctile(allts,75), 'k:');
plot(tk, prctile(allts,25), 'k:');

title('Strength of direction representation');

ylabel('Average t-statistic');
xlabel('Time in trial (s)');
legend(sprintf('median (N=%d)',size(allts,1)), 'quartiles', 'location', 'northwest');
vline(0, 'k:');

SaveFig(OUTPUT_DIR, 'fb ts', 'eps', '-r300');
SaveFig(OUTPUT_DIR, 'fb ts', 'png', '-r300');

% %%
% figure
% tk = t(t>=MIN_T&t<=MAX_T);
% plot(tk, mean(allts), 'k', 'linew', 2);
% hold on;
% plot(tk, mean(allts)+sem(allts), 'k:');
% plot(tk, mean(allts)-sem(allts), 'k:');
% 
% ylabel('Average t-statistic');
% xlabel('Time in trial (s)');
% legend('mean', 'SEM');
% vline(0, 'k:');
% 
% SaveFig(OUTPUT_DIR, 'fb ts', 'eps', '-r300');