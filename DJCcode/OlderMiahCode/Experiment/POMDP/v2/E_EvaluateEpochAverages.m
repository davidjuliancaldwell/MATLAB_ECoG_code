Z_Constants;

addpath ./scripts;

%% make plots showing significant correlations between band powers and trial type

alllocs.pre = cell(6,1);
alllocs.fb = cell(6,1);

allr2s.pre = cell(6,1);
allr2s.fb = cell(6,1);

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, [sid '_epochs.mat']), '*feats', 'tgts', '*ress', 'bad*', 'montage', 'cchan');
    locs = trodeLocsFromMontage(sid, montage, true);
    
    % *feats is freq x obs x chans
    
    % screen out bad channels / epochs
    bad_trials = all(bad_marker, 1);
    prefeats(:, bad_trials, :) = [];
    fbfeats(:, bad_trials, :) = [];
    tgts(bad_trials) = [];
        
    for iter = {{prefeats, 'pre'}, {fbfeats, 'fb'}}
        feats = iter{1}{1};
        type = iter{1}{2};
        
        [r2, r2sign, thresh] = featCorr(permute(feats, [1 3 2]), double(tgts==1));            
        r2(isnan(r2)) = 0;
        r2sign(isnan(r2sign)) = 1;
        r2(:, bad_channels) = 0;
        
%         figure;
%         imagesc(r2.*r2sign);
%         set_colormap_threshold(gcf, [-thresh thresh], [-1 1], [.5 .5 .5]);
%         
%         xlabel('Channel');
%         ylabel('Frequency');
%         set(gca, 'yticklabel', BAND_NAMES);
%         title(sprintf('Band-power Correlation with trial type: %s %s', sid, type));
%         
%         colorbar;

% %             % perform PCA on a by-frequency basis
% %             nfeats = 5;
% %             pcafeats = zeros(size(feats, 1), nfeats, size(feats, 2));
% %             
% %             for bandi = 1:size(r2, 1)
% %                 data = squeeze(feats(bandi, :, :));
% %                 zdata = zscore(data);
% %                 
% %                 [proj, filt, varfrac] = mpca(zdata);
% %                 
% %                 pcafeats(bandi, :, :) = proj(:, 1:nfeats)';
% %                 [max(abs(r2(bandi, :))) max(corr(proj, tgts==1).^2)]
% %             end
            
% %         % perform CSP on a by-frequency basis
% %         nfeats = 2;
% %         cspfeats = zeros(size(feats, 1), nfeats, size(feats, 2));
% % %         good_channels = setdiff(1:size(feats,3), bad_channels);
% %         
% %         for bandi = 1:size(r2, 1)        
% %             mr2 = r2(bandi, :);
% %             mr2(bad_channels) = [];
% %             [~, besti] = sort(mr2, 'descend');
% %             
% %             res = CSP(squeeze(feats(bandi,tgts==1,besti(1:10)))', squeeze(feats(bandi,tgts==2,besti(1:10)))');
% % 
% %             cspfeats(bandi, :, :) = res([1:(1+(nfeats-2)/2) (end-(nfeats-2)/2):end], :);
% %             % plot
% %             subplot(3,2,bandi);
% %             gscatter(res(1, :), res(end, :), tgts); 
% %             title(BAND_NAMES{bandi});
% %         end
% %         [cspr2, cspr2sign, cspthresh] = featCorr(cspfeats, double(tgts==1));            
% %         
% %         figure; (imagesc(cspr2.*cspr2sign));
% %         set_colormap_threshold(gcf, [-cspthresh cspthresh], [-1 1], [.5 .5 .5])
% %         colorbar;
         
        % save a few things for group viz
        for bandi = 1:size(r2, 1)
            sigs = r2(bandi, :) > thresh;
            
            % special case for the control channel
            if (bandi == 5 && strcmp(type, 'fb'))
                sigs(cchan) = 0;
            end
            
            alllocs.(type){bandi} = cat(1, alllocs.(type){bandi}, locs(sigs, :));
            allr2s.(type){bandi} = cat(1, allr2s.(type){bandi}, (r2sign(bandi, sigs) .* r2(bandi, sigs))');
        end
    end        
end

%% show significantly correlated features by frequency on a template brain

for bandi = 1:length(BAND_NAMES)
    for iter = {'pre', 'fb'}
        locs = alllocs.(iter{1}){bandi};
        r2s = allr2s.(iter{1}){bandi};
        
        if (~isempty(r2s))
            %  convet back to rs, for easy viz
            sig = sign(r2s);
            r2s = sig .* sqrt(abs(r2s));
            
            figure;
            PlotDotsDirect('tail', projectToHemisphere(locs, 'r'), r2s, 'r', [-1 1], 10, 'recon_colormap', [], false);
            title(sprintf('%s %s', BAND_NAMES{bandi}, iter{1}));
            load('recon_colormap');
            colormap(cm);
            colorbar;
            
            SaveFig(OUTPUT_DIR, sprintf('%s_%s_corr', BAND_NAMES{bandi}, iter{1}), 'png');
        end
    end
end