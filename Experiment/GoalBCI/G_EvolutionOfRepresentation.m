% this script will be very similar to the previous poster where we look at
% how many areas show significant power changes in HG as a fxn of time
% within the trial.  What we would hope to see is that at about t=500msec
% this number pops way up.

Z_Constants;
addpath ./functions;

SIDS(end) = [];

%% process each subject in a row
allts = [];

MIN_T = -2;
MAX_T = 1.5;

FORCE_RANDOM = false;
NN = 100;

sigthresh = [];
randfile = fullfile(META_DIR, 'random_blobs.mat');
if (exist(randfile, 'file') && ~FORCE_RANDOM)
    fprintf('using previously created random blobs\n');
    load(randfile);
    doRandom = false;
else
    fprintf('going to recreate random blobs\n');
    doRandom = true;
end

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('%s-epochs.mat', sid)));

    lastt = find(t <= 1.5, 1, 'last');    
    epochs = zeros(size(data, 2), size(data, 1), lastt);
    
    for e = 1:size(data, 2)
%         temp = [data{:,e}];
        temp = GaussianSmooth([data{:,e}], round(.50*fs));
        epochs(e, :, :) = temp(1:lastt, :)';
    end    

    epochs(:, bad_channels, :) = 0;
    
    % ok, now, marching through time, we're going to look at the predictive
    % power of each channel / freq / time
    up = double(~ismember(targets, DOWN));
        
    % calculate the real stats
    [h, p, ~, tstat] = ttest2(epochs(up==1,:,:),epochs(up==0,:,:),'dim', 1, 'var', 'unequal');
    h = squeeze(h);
    h(isnan(h)) = 0;
    tstat = squeeze(tstat.tstat);
    mtstat = tstat; % save for later
    mtstat(isnan(mtstat)) = 0;
    
    tstat(~h) = 0;
    
    gridtstat = linToGrid(tstat, 1);
    blobs = bwlabeln(gridtstat);
    blobsize = regionprops(blobs, 'FilledArea');
    blobsize = [blobsize(:).FilledArea];                

    % do the bootstrap to determine what the significance level should be
    if (doRandom)

        for N = 1:NN
            fprintf('.');
        end
        fprintf('\n');

%         blobdistro = zeros(NN, 1);
        blobdistro = [];
        
        for N = 1:NN
            fprintf('.');
            sup = shuffle(up);
            [h, p, ~, randtstat] = ttest2(epochs(sup==1,:,:),epochs(sup==0,:,:),'dim', 1, 'var', 'unequal');
            h = squeeze(h);
            h(isnan(h)) = 0;
            randtstat = squeeze(randtstat.tstat);
            randtstat(~h) = 0;

            randgridtstat = linToGrid(randtstat, 1);
            randblobs = bwlabeln(randgridtstat);
            randsize = regionprops(randblobs, 'FilledArea');
%             blobdistro(N) = max([randsize(:).FilledArea]);                
            blobdistro = cat(2, blobdistro, [randsize(:).FilledArea]);
        end        
        fprintf('\n');        

        sigthresh(c) = prctile(blobdistro, 100-5); % no correction
    end
    
%     %% now viz
    h = gridToLin(ismember(blobs, find(blobsize>=sigthresh(c))), 1:2);    
    tstat = tstat .* h;
        
    figure
%     subplot(211);
    imagesc(t(1:lastt), 1:size(tstat, 1), tstat);
    load('america'); colormap(cm);
    if (length(unique(tstat)) > 1)
        set(gca, 'clim', [-max(abs(tstat(:))) max(abs(tstat(:)))]);    
    end
    
    colorbar;
    vline([-preDur 0]);
    title(SIDS{c}, 'fontsize', 24);
    
    ticks = get(gca, 'ytick');
    ticks = sort(union(ticks, cchan));
    set(gca, 'ytick', ticks);
    ticklabels = arrayfun(@(x) num2str(x), ticks, 'UniformOutput', false);
    ticklabels{strcmp(ticklabels, num2str(cchan))} = '*';
    set(gca, 'yticklabel', ticklabels);
    
    xlabel('time (s)', 'fontsize', 24);
    ylabel('channel', 'fontsize', 24);
    set(gca, 'fontsize', 18);
    
%     subplot(212);
%     prettyline(t(1:lastt), squeeze(epochs(:,cchan,:))', up, 'rb');
%     title(['cchan ' num2str(cchan)]);        
%     legend('down','up','location', 'northwest');
%     
%     vline([-preDur 0]);
%     ax = colorbar; set(ax,'Visible','off')

%     SaveFig(OUTPUT_DIR, ['www ' sid], 'eps', '-r300');

        
    % and save for later
    
%     allts(c, :) = mean(tstat(:, t>=MIN_T & t<=MAX_T));
%     foo = (sort(abs(mtstat), 'descend'));
%     allts(c, :) = mean(foo(1:5, t>=MIN_T & t <=MAX_T));

%     allts(c, :) = sum(tstat(:, t>=MIN_T & t<=MAX_T) ~= 0) / size(tstat, 1);    
    allts(c, :) = mean(abs(tstat(:, t>=MIN_T & t<=MAX_T)));
end

save(randfile, 'sigthresh');

%%
figure
tk = t(t>=MIN_T&t<=MAX_T);
plot(tk, mean(allts), 'k', 'linew', 2);
hold on;
plot(tk, mean(allts)+sem(allts), 'k:');
plot(tk, mean(allts)-sem(allts), 'k:');

title('Strength of direction representation', 'fontsize', 24);

ylabel('mean |t-statistic|', 'fontsize', 24);
% ylabel('Average t-statistic', 'fontsize', 24);
xlabel('Time in trial (s)', 'fontsize', 24);
set(gca, 'fontsize', 18);
legend(sprintf('mean (N=%d)',size(allts,1)), 'SEM', 'location', 'northwest');
vline(0, 'k:');
xlim([ min(tk) max(tk)]);

SaveFig(OUTPUT_DIR, 'fb ts', 'eps', '-r300');
SaveFig(OUTPUT_DIR, 'fb ts', 'png', '-r300');

% % % %%
% % % figure
% % % tk = t(t>=MIN_T&t<=MAX_T);
% % % plot(tk, mean(allts), 'k', 'linew', 2);
% % % hold on;
% % % plot(tk, mean(allts)+sem(allts), 'k:');
% % % plot(tk, mean(allts)-sem(allts), 'k:');
% % % 
% % % ylabel('Average t-statistic');
% % % xlabel('Time in trial (s)');
% % % legend('mean', 'SEM');
% % % vline(0, 'k:');
% % % 
% % % SaveFig(OUTPUT_DIR, 'fb ts', 'eps', '-r300');