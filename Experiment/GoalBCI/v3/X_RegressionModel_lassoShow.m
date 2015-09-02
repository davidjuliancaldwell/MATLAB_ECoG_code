%% define constants
addpath ./functions
Z_Constants;

%%
alllocs = [];
allweights = [];
allsources = [];

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    %% load in data and get set up
    fprintf ('processing %s: \n', subcode);
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'fs', 'cchan', 'hemi', 'montage', 'bad_channels');    
    load(fullfile(META_DIR, ['lasso ' subjid '.mat']), 'outcomes', 'predictors', 'lags', 'coeffs', 'mses', ...
        'MAX_LAG_SEC', 'LAG_STEP_SAMPLES', 'DO_PREROLL', 'DECIMATE_FAC', 'DF_MAX');
    
    txts = {'Velocity', 'Error', 'Interaction', 'Direction'};

    %% show the lag/channel coefficient plots for each subject
    load('america');
    
    figure
    D = length(txts);
    for d = 1:D
        subplot(1,D,d);
        start = (d-1)*length(lags)+1;
        endd  = min(d*length(lags), size(coeffs, 1));
        
        X = coeffs(start:endd,:);
        
        if (isvector(X))
            plot(1:size(coeffs, 2), X, 'k-','linew', 2);
            hold on;
            plot(find(X~=0), X(X~=0), 'k.', 'markersize', 20);
            plot(cchan, X(cchan), 'go', 'linew', 2, 'markersize', 10);
            
            xlabel('channel');
            ylabel('Lasso coefficient');
            xlim([1 size(coeffs, 2)])
            tickCchan(gca, cchan, 'x');
            
        else
            imagesc(1:size(coeffs, 2), lags/fs, X);
            colorbarLabel(colorbar,'Lasso coefficient');
            colormap(cm);
            set(gca,'clim',[-max(abs(X(:))) max(abs(X(:)))]);
            xlabel('channel');
            ylabel('lag (sec) [neg -> brain leads]');
            tickCchan(gca, cchan, 'x');
        end
        
        title(txts{d});
    end
    
    set(gcf, 'pos', [26 474 1859 504]);
    
    SaveFig(OUTPUT_DIR, ['lasso ' subjid], 'eps', '-r300');
    
    %% this assumes that direction was the last thing to have been processed
    figure
    w = X;
    w(w==0) = NaN;
    PlotDotsDirect(subjid, montage.MontageTrodes, w, hemi, [-max(abs(w)) max(abs(w))] , 15, 'america', [], []);
    
    if (isnan(X(cchan)))
        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', 5);
    else
        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', 15);
    end
    
    colorbarLabel(colorbar, 'Lasso coefficient');
    colormap(cm);

    if (strcmp(subjid, 'd6c834'))
        view(-112, 51);
    elseif (strcmp(subjid, '5050b0'))
        view(-38, 32);
    end        

    SaveFig(OUTPUT_DIR, ['lasso brain ' subjid], 'png', '-r300');
    
    %% save for a group view
    keeps = X~=0;
    
    if (any(keeps))
        ttrodes = trodeLocsFromMontage(subjid, montage, true);
        alllocs = cat(1, alllocs, ttrodes(keeps, :));
        allweights = cat(2, allweights, X(keeps)); 
        allsources = cat(2, allsources, c*ones(1, sum(keeps)));
    end
    
    close all
end

%% plot the aggregate on a tail brain
figure

projected = projectToHemisphere(alllocs, 'r');
PlotDotsDirect('tail', projected, allweights, 'r', [-prctile(allweights,95) prctile(allweights,95)], 10, 'america', allsources, true);
colormap(cm);
colorbarLabel(colorbar, 'Lasso coefficients');
title('Aggregate directional coefficients');

SaveFig(OUTPUT_DIR, 'lasso brain all', 'png', '-r300');


% figure
% PlotGaussDirect('tail', projected, allweights, 'r', [-prctile(allweights,80) prctile(allweights,80)], 'america');
