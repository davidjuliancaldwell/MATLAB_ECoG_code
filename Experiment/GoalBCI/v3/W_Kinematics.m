%% define constants
addpath ./functions
Z_Constants;

%%

MAX_LAG_SEC = 1;
LAG_STEP_SAMPLES = 1;

DO_SIMULATIONS = 1;
DO_ACTUAL = 0;

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');

    velocity = cell(size(paths));
    error = velocity;
    derror = velocity;
    
    for e = 1:length(paths)
        % collect velocity and error
        velocity{e} = [0; diff(paths{e})];
        error{e}    = abs(diffs{e});
        derror{e}   = [0; diff(abs(diffs{e}))];
        
        % prune down to just be during the feedback period        
        start = find(t > 0, 1, 'first')+2;
        endd = length(error{e})-postDur*fs;
        
        for ch = 1:size(data, 1)
            temp = GaussianSmooth(data{ch, e}, 30);
            data{ch, e} = temp(start:endd);
            
%             data{ch, e} = (data{ch, e}(start:endd));
        end
                
        paths{e} = paths{e}(start:endd);
        
        velocity{e} = velocity{e}(start:endd);

        error{e} = error{e}(start:endd);
        
        derror{e} = derror{e}(start:endd);
        
%         plot(paths{e})
%         ylim([0 1])
%         hline(targetY{e}(end))
%         hline(targetY{e}(end)+targetD{e}(end)/2)
%         hline(targetY{e}(end)-targetD{e}(end)/2)

    end

    lags = -MAX_LAG_SEC*fs : LAG_STEP_SAMPLES : MAX_LAG_SEC*fs;
        
    goodChannelIndicator = true(size(data, 1), 1);
    goodChannelIndicator(bad_channels) = false;
        
    if (DO_SIMULATIONS)
        N = 1000;
        
        fprintf('p');
        temp = computeLaggedRegressionBootstrap(data(goodChannelIndicator, :)', paths, lags, N);        
        p_simulations = zeros(length(goodChannelIndicator), length(lags), N);
        p_simulations(goodChannelIndicator, :, :) = temp;
        
        fprintf('v');
        temp = computeLaggedRegressionBootstrap(data(goodChannelIndicator, :)', velocity, lags, N);
        v_simulations = zeros(length(goodChannelIndicator), length(lags), N);
        v_simulations(goodChannelIndicator, :, :) = temp;
        
        fprintf('e');
        temp = computeLaggedRegressionBootstrap(data(goodChannelIndicator, :)', error, lags, N);
        e_simulations = zeros(length(goodChannelIndicator), length(lags), N);
        e_simulations(goodChannelIndicator, :, :) = temp;
        
        fprintf('d\n');
        temp = computeLaggedRegressionBootstrap(data(goodChannelIndicator, :)', derror, lags, N);
        d_simulations = zeros(length(goodChannelIndicator), length(lags), N);
        d_simulations(goodChannelIndicator, :, :) = temp;
                        
        save(fullfile(META_DIR, sprintf('%s-regression-sims', subjid)), '*_simulations');            
    else    
        %load(fullfile(META_DIR, sprintf('%s-regression-sims', subjid)), '*_simulations');
    end
    
    if (DO_ACTUAL)
        figure
        maximize;        

        % do the regressions
        for sub = {{velocity, 'velocity', 2},{derror, 'dError', 4}}
%         for sub = {{paths, 'position', 1},{velocity, 'velocity', 2},{error, 'error', 3},{derror, 'dError', 4}}
            response = sub{1}{1};
            lab = sub{1}{2};
            idx = sub{1}{3};

            W_temp = computeLaggedRegression(data(goodChannelIndicator, :)', response, lags, 'pearson');
            W = zeros(size(data, 1), length(lags));
            W(goodChannelIndicator, :) = W_temp;

            % save for later
            correlations{idx} = W;
            labels{idx} = lab;

            subplot(1, 4, idx);

            imagesc(1:size(data, 1), lags/fs, W');            
            load america
            colormap(cm);
            set(gca, 'clim', [-max(abs(W(:))) max(abs(W(:)))]);

            % all this just to add a star for the cchan
            ticks = get(gca,'xtick');
            ticks = sort(union(ticks, cchan));
            labs = {};
            labs(ticks~=cchan) = arrayfun(@(x) num2str(x), ticks(ticks~=cchan),'UniformOutput', false);
            labs{ticks==cchan} = '*';
            set(gca, 'xtick', ticks);                       
            set(gca, 'xticklabel', labs)

            ylabel('lag (sec)');
            xlabel('channels');
            title(sprintf('%s', lab));
            cb = colorbar;
            colorbarLabel(cb, 'regression weight');            
        end

        mtit(subjid, 'xoff', 0, 'yoff', 0.025);

        SaveFig(OUTPUT_DIR, sprintf('%s-regress',subjid), 'png', '-r300');
        SaveFig(OUTPUT_DIR, sprintf('%s-regress',subjid), 'eps', '-r600');

        save(fullfile(META_DIR, sprintf('%s-regression', subjid)), 'correlations', 'labels', 'lags');
    end
end
