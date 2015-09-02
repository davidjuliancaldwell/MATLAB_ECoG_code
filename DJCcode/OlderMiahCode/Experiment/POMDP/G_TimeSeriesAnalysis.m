Z_Constants;

addpath ./scripts;

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, [sid '_epochs.mat']), 'epochs', 't', '*Dur', 'ress', 'tgts', 'bad_channels', 'montage', 'hemi', 'bad_marker', 'cchan');

%     epochs(isnan(epochs)) = 0;
    
    %% regression playground

    winsize = 20; % 20 samples at 100 Hz is 200 msec
    stepsize = 10; % 10 samples at 100 Hz is 100 msec
    
    stepends = stepsize:stepsize:size(epochs, 4);
    stepstarts = stepends-winsize+1;
    stepstarts = max(stepstarts, 1);
    
    repochs = arrayfun(@(x,y) mean(epochs(:,:,:,x:y), 4), stepstarts, stepends, 'UniformOutput', false);
    repochs = cat(4, repochs{:});
    
    rt = t(stepends);
    
    % if we want to normalize against the baseline for each trial
    repochs = repochs - repmat(mean(repochs(:,:,:,rt<=-preDur),4), [1 1 1 length(rt)]);
%     repochs(isnan(repochs)) = 0;
        
%     %% this section removes all the miss trials, comment if you want to keep all trials
%     hits = tgts==ress;
%     tgts(~hits) = [];
%     repochs(:, ~hits, :, :) = [];
    
%     %% this section removes time periods before or after the trial, comment if you want to keep all time
%     badt = rt < -preDur | rt > fbDur;
%     repochs(:,:,:,badt) = [];
%     rt(badt) = [];
    
    %% this section removes all electrodes but the grid, assuming that the grid is the first montage element
    if (~strfind(lower(montage.MontageTokenized{1}), 'grid')) 
        error('grid element assumption failed');
    end
    
    if (strcmp(sid ,'58411c'))
        Nchans = 64;
    else
        Nchans = montage.Montage(1);
    end
    
    bad_channels(bad_channels > Nchans) = [];
    repochs = repochs(:,:,1:Nchans,:);
    
    %%
    % ok, now, marching through time, we're going to look at the predictive
    % power of each channel / freq / time
    up = double(tgts==1);
    
    % initialize some variables
    blobs = {};
    blobsize = {};
    blobdistro = [];
    tstats = {};
    
    % calculate the real stats
    for freqi = 1:size(repochs, 1)
        mepochs = squeeze(repochs(freqi, :, :, :));
        
        [h, p, ~, tstat] = ttest2(mepochs(up==1,:,:),mepochs(up==0,:,:),'dim', 1, 'var', 'unequal');
        h = squeeze(h);
        h(isnan(h)) = 0;
        tstat = squeeze(tstat.tstat);
        tstat(~h) = 0;
        tstats{freqi} = tstat;
    
        gridtstat = linToGrid(tstat, 1);
        blobs{freqi} = bwlabeln(gridtstat);
        blobsize{freqi} = regionprops(blobs{freqi}, 'FilledArea');
        blobsize{freqi} = [blobsize{freqi}(:).FilledArea];                
        
        % do the bootstrap
        NN = 100;
        
        for N = 1:NN
            fprintf('.');
        end
        fprintf('\n');
        
        for N = 1:NN
            fprintf('.');
            sup = shuffle(up);
            [h, p, ~, tstat] = ttest2(mepochs(sup==1,:,:),mepochs(sup==0,:,:),'dim', 1, 'var', 'unequal');
            h = squeeze(h);
            h(isnan(h)) = 0;
            tstat = squeeze(tstat.tstat);
            tstat(~h) = 0;
            
            gridtstat = linToGrid(tstat, 1);
            randblobs = bwlabeln(gridtstat);
            randsize = regionprops(randblobs, 'FilledArea');
            blobdistro(freqi, N) = max([randsize(:).FilledArea]);                
        end        
        fprintf('\n');        
    end    
    
    sigthresh = prctile(blobdistro, 100-5, 2); % no correction
%     sigthresh = prctile(blobdistro, 100-(5/size(repochs, 1)), 2); % bonf correction across frequencies            
    
    %% now viz
    figure;
    
    load recon_colormap

    cval = max(max(max(abs(cat(3,tstats{:})))));
    
    for bandi = 1:size(repochs, 1)
        subplot(3,2,bandi);

        h = ismember(blobs{bandi}, find(blobsize{bandi}>=sigthresh(bandi)));
        temp = tstats{bandi} .* gridToLin(h, 1:2);
        
        imagesc(rt, 1:size(repochs, 3), temp);
        vline([-preDur 0 fbDur], 'k');
        colormap(cm);
        set(gca, 'clim', [-cval cval]);
        colorbar;
        title(BAND_NAMES{bandi});
    end
    
    mtit(sid);
    
    fname = sprintf('what_when_where_%s', sid);
    SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
    SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
    
    save(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), 'tstats', 'blob*', 'repochs', 'montage', 'rt', 'tgts', 'sigthresh', 'winsize', 'stepsize');    
end