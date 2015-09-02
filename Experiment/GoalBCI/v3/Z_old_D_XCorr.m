%% define constants
addpath ./functions
Z_Constants;

%%

DO_CHANCE = false;
DO_ACTUAL = true;

N = 1000;
MAX_LAG_SEC = 2;

gpu = hasGPU();
% gpu = false;
 
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');

    if (DO_CHANCE)
        tic
        
        p_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 1));
        v_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 1));
        e_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 1));
        d_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 1));
        
%         p_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 2), size(data, 1));
%         v_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 2), size(data, 1));
%         e_simulations = zeros(2*MAX_LAG_SEC*fs+1, N, size(data, 2), size(data, 1));
        
        if (gpu)
            p_simulations = gpuArray(p_simulations);
            v_simulations = gpuArray(v_simulations);
            e_simulations = gpuArray(e_simulations);
            d_simulations = gpuArray(d_simulations);
        end
        
        for chan = 1:size(data, 1)
            fprintf('.');
  
            if (~ismember(chan, bad_channels))
                for e = 1:size(data, 2)
                    brain = data{chan, e};    

                    % cursor position
                    position = paths{e};
                    % cursor velocity
                    velocity = [0; diff(paths{e})];        
                    % cursor unsigned error
                    error = abs(diffs{e});
                    % derivative of error
                    derror = [0; diff(abs(diffs{e}))];

                    if (gpu)
                        brain = gpuArray(brain);
                        position = gpuArray(position);
                        velocity = gpuArray(velocity);
                        error = gpuArray(error);
                        derror = gpuArray(derror);
                    end

                    startIdx = find(t > 0, 1, 'first')+2;
                    endIdx = length(error)-postDur*fs;

                    if (endIdx>startIdx)
                        br = brain(startIdx:endIdx) - mean(brain(startIdx:endIdx));
                        po = position(startIdx:endIdx) - mean(position(startIdx:endIdx));
                        ve = velocity(startIdx:endIdx) - mean(velocity(startIdx:endIdx));
                        er = error(startIdx:endIdx) - mean(error(startIdx:endIdx));
                        de = derror(startIdx:endIdx) - mean(derror(startIdx:endIdx));
                        
                        if (gpu)
    %                         tic
                            br = gather(br);
                            sbr = zeros(length(br), N);
    %                         sbr = gpuArray(sbr);

                            for n = 1:N
                                sbr(:,n) = br(randperm(length(br)));
                            end
                            sbr = gpuArray(sbr);
    %                         toc

    %                         p_simulations(:,:,e,chan) = mXcorr(po, sbr, MAX_LAG_SEC*fs);
    %                         v_simulations(:,:,e,chan) = mXcorr(ve, sbr, MAX_LAG_SEC*fs);
    %                         e_simulations(:,:,e,chan) = mXcorr(er, sbr, MAX_LAG_SEC*fs);

                            p_simulations(:,:,chan) = p_simulations(:,:,chan) + mXcorr(po, sbr, MAX_LAG_SEC*fs);
                            if (any(isnan(p_simulations(:))))
                                beep; beep; beep; beep; beep
                                fprintf('some of the simulations were nans!');                                
                            end
                            
                            v_simulations(:,:,chan) = v_simulations(:,:,chan) + mXcorr(ve, sbr, MAX_LAG_SEC*fs);
                            e_simulations(:,:,chan) = e_simulations(:,:,chan) + mXcorr(er, sbr, MAX_LAG_SEC*fs);
                            d_simulations(:,:,chan) = d_simulations(:,:,chan) + mXcorr(de, sbr, MAX_LAG_SEC*fs);

                        else                    
                            for n = 1:N
        %                         sbr = shuffle(br);
                                sbr = br(randperm(length(br)));

    %                             p_simulations(:,n,e,chan) = xcorr(sbr,po,MAX_LAG_SEC*fs,'coeff');
    %                             v_simulations(:,n,e,chan) = xcorr(sbr,ve,MAX_LAG_SEC*fs,'coeff');
    %                             e_simulations(:,n,e,chan) = xcorr(sbr,er,MAX_LAG_SEC*fs,'coeff');

                                p_simulations(:,n,chan) = p_simulations(:,n,chan) + xcorr(sbr,po,MAX_LAG_SEC*fs,'coeff');
                                v_simulations(:,n,chan) = v_simulations(:,n,chan) + xcorr(sbr,ve,MAX_LAG_SEC*fs,'coeff');
                                e_simulations(:,n,chan) = e_simulations(:,n,chan) + xcorr(sbr,er,MAX_LAG_SEC*fs,'coeff');

                            end                    
                        end
                    end
                end 
            end
        end    

        fprintf('\n');
        
%         p_simulations = squeeze(mean(p_simulations, 3));
%         v_simulations = squeeze(mean(v_simulations, 3));
%         e_simulations = squeeze(mean(e_simulations, 3));

        p_simulations = p_simulations / size(data, 2);
        v_simulations = v_simulations / size(data, 2);
        e_simulations = e_simulations / size(data, 2);
        d_simulations = d_simulations / size(data, 2);
        
        if (gpu)
            p_simulations = gather(p_simulations);
            v_simulations = gather(v_simulations);
            e_simulations = gather(e_simulations);
            d_simulations = gather(d_simulations);
        end
        
        save(fullfile(META_DIR, sprintf('%s-xcorr-simulations', subjid)), '*_simulations');
        
        toc                
    else
        load(fullfile(META_DIR, sprintf('%s-xcorr-simulations', subjid)), '*_simulations');
    end
    
    
    
    if (DO_ACTUAL)
%         SMOOTH_SEC = 2;
        
        pCorr = zeros(2*MAX_LAG_SEC*fs + 1, size(data, 2), size(data, 1));
        eCorr = zeros(2*MAX_LAG_SEC*fs + 1, size(data, 2), size(data, 1));
        vCorr = zeros(2*MAX_LAG_SEC*fs + 1, size(data, 2), size(data, 1));
        dCorr = zeros(2*MAX_LAG_SEC*fs + 1, size(data, 2), size(data, 1));
        
        for chan = 1:size(data, 1)
            fprintf('x');
  
            if (~ismember(chan, bad_channels))
                for e = 1:size(data, 2)
                    brain = data{chan, e};    

                    % cursor position
                    position = paths{e};
                    % cursor velocity
                    velocity = [0; diff(paths{e})];        
                    % cursor unsigned error
                    error = abs(diffs{e});
                    % change in error
                    derror = [0; diff(abs(diffs{e}))];

                    startIdx = find(t > 0, 1, 'first')+2;
                    endIdx = length(error)-postDur*fs;

                    if (endIdx>startIdx)
                        br = brain(startIdx:endIdx) - mean(brain(startIdx:endIdx));
                        po = position(startIdx:endIdx) - mean(position(startIdx:endIdx));
                        ve = velocity(startIdx:endIdx) - mean(velocity(startIdx:endIdx));
                        er = error(startIdx:endIdx) - mean(error(startIdx:endIdx));
                        de = derror(startIdx:endIdx) - mean(derror(startIdx:endIdx));
                        
                        [pCorr(:, e, chan), ~] = xcorr(po, br, MAX_LAG_SEC*fs, 'coeff');
                        [vCorr(:, e, chan), ~] = xcorr(ve, br, MAX_LAG_SEC*fs, 'coeff');
                        [eCorr(:, e, chan), ~] = xcorr(er, br, MAX_LAG_SEC*fs, 'coeff');                        
                        [dCorr(:, e, chan), lags] = xcorr(de, br, MAX_LAG_SEC*fs, 'coeff');                        
                    end
                end                         
            end
        end
        
%         % do any smoothing that we plan on doing
%         for sim = 1:size(p_simulations, 2)
%             p_simulations(:,sim,:) = GaussianSmooth(squeeze(p_simulations(:,sim,:)),SMOOTH_SEC*fs);
%             v_simulations(:,sim,:) = GaussianSmooth(squeeze(v_simulations(:,sim,:)),SMOOTH_SEC*fs);
%             e_simulations(:,sim,:) = GaussianSmooth(squeeze(e_simulations(:,sim,:)),SMOOTH_SEC*fs);
%         end
%         
%         for e = 1:size(pCorr, 2)
%             pCorr(:, e, :) = GaussianSmooth(squeeze(pCorr(:, e, :)), SMOOTH_SEC*fs);
%             vCorr(:, e, :) = GaussianSmooth(squeeze(vCorr(:, e, :)), SMOOTH_SEC*fs);
%             eCorr(:, e, :) = GaussianSmooth(squeeze(eCorr(:, e, :)), SMOOTH_SEC*fs);
%         end
        
        fprintf('\n');
        
        pDistro = cat(2, max(reshape(permute(p_simulations, [2 1 3]), [size(p_simulations, 2), size(p_simulations, 1)*size(p_simulations, 3)]), [], 2), ...
                            min(reshape(permute(p_simulations, [2 1 3]), [size(p_simulations, 2), size(p_simulations, 1)*size(p_simulations, 3)]), [], 2));
        vDistro = cat(2, max(reshape(permute(v_simulations, [2 1 3]), [size(v_simulations, 2), size(v_simulations, 1)*size(v_simulations, 3)]), [], 2), ...
                            min(reshape(permute(v_simulations, [2 1 3]), [size(v_simulations, 2), size(v_simulations, 1)*size(v_simulations, 3)]), [], 2));
        eDistro = cat(2, max(reshape(permute(e_simulations, [2 1 3]), [size(e_simulations, 2), size(e_simulations, 1)*size(e_simulations, 3)]), [], 2), ...
                            min(reshape(permute(e_simulations, [2 1 3]), [size(e_simulations, 2), size(e_simulations, 1)*size(e_simulations, 3)]), [], 2));
        dDistro = cat(2, max(reshape(permute(d_simulations, [2 1 3]), [size(d_simulations, 2), size(d_simulations, 1)*size(d_simulations, 3)]), [], 2), ...
                            min(reshape(permute(d_simulations, [2 1 3]), [size(d_simulations, 2), size(d_simulations, 1)*size(d_simulations, 3)]), [], 2));

        save(fullfile(META_DIR, sprintf('%s-xcorr-results.mat', subjid)), '*Corr', '*Distro', 'lags', 'fs', 'cchan', 'hemi', 'montage', 'bad_channels');
                        
        figure
        maximize;        
              
        for sub = {{pCorr, p_simulations, 'position', 1},{vCorr, v_simulations, 'velocity', 2},{eCorr, e_simulations, 'absError', 3},{dCorr, d_simulations, 'dAbsError', 4}}
            cx = sub{1}{1};
            sim = sub{1}{2};
            lab = sub{1}{3};
            idx = sub{1}{4};
            
            cx(isnan(cx))=0;
            
            subplot(1, 4, idx);
            
            highdistro = max(reshape(permute(sim, [2 1 3]), [size(sim, 2), size(sim, 1)*size(sim, 3)]), [], 2);
            highcrit = prctile(highdistro, 97.5);        
            
            lowdistro = min(reshape(permute(sim, [2 1 3]), [size(sim, 2), size(sim, 1)*size(sim, 3)]), [], 2);
            lowcrit = prctile(lowdistro, 2.5);        
            muCx = squeeze(mean(cx, 2));
                       
            imagesc(1:size(cx, 3), lags/fs, muCx .* double(muCx >= highcrit) + muCx .* double(muCx <= lowcrit));            
            load america
            colormap(cm);
            set(gca, 'clim', [-max(abs(muCx(:))) max(abs(muCx(:)))]);
%             set_colormap_threshold(gcf, [lowcrit highcrit], [-max(abs(muCx(:))) max(abs(muCx(:)))], [.5 .5 .5]);
                        
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
            title(lab);
            cb = colorbar;
            colorbarLabel(cb, 'normalized cross-correlation');            
        end
        
%         maximize;
        mtit(subjid, 'xoff', 0, 'yoff', 0.025);
        
        SaveFig(OUTPUT_DIR, sprintf('%s-xcorr',subjid), 'png', '-r300');
        SaveFig(OUTPUT_DIR, sprintf('%s-xcorr',subjid), 'eps', '-r600');

    end        
end
