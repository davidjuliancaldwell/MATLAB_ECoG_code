%%
Z_Constants;

DO_TIMESERIES = false;
DO_EPOCHS = true;

%% perform analyses

for zid = SIDS
    sid = zid{:};
    
    % temporary, necessary until C_EpochCollect is run again
    [~,~,~, cchan] = filesForSubjid(sid);

    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_epochs']));
    load(fullfile(META_DIR, [sid '_results']));
    ups = tgts == 1;
    subjOutputDir = fullfile(OUTPUT_DIR, sid);
    TouchDir(subjOutputDir);

    toc;
    
    %% Generate plots for time series of ups vs down trials, these will be saved in subject specific directories
    % for the sake of sanity
    
    if (DO_TIMESERIES && strcmp(sid, 'fc9643'))
        fprintf(' generating timeseries figures: ');
        tic;


        for chan = 1:size(epochs_hg, 1)
            figure;
            sfac = 10;
            
            ax(1) = plot(t, GaussianSmooth(muUp_hg(chan, :) + semUp_hg(chan, :), sfac), 'r:'); hold on;
            ax(2) = plot(t, GaussianSmooth(muUp_hg(chan, :) - semUp_hg(chan, :), sfac), 'r:');
            ax(3) = plot(t, GaussianSmooth(muDown_hg(chan, :) + semDown_hg(chan, :), sfac), 'b:');
            ax(4) = plot(t, GaussianSmooth(muDown_hg(chan, :) - semDown_hg(chan, :), sfac), 'b:');
            legendOff(ax); clear ax;

            hold on;
            plot(t, GaussianSmooth(muUp_hg(chan, :), sfac), 'r', 'linew', 2);
            plot(t, GaussianSmooth(muDown_hg(chan, :), sfac), 'b', 'linew', 2);

            ax(1) = vline(-preDur, 'k');
            ax(2) = vline(0, 'k');
            ax(3) = vline(fbDur, 'k');
            set(ax, 'linew', 2);

            xlabel('time (s)');
            ylabel('|HG|');
            title([sid ' ' trodeNameFromMontage(chan, montage)]);
            legend('Up', 'Down');
            SaveFig(subjOutputDir, ['ts_' num2str(chan)], 'png', '-r600');
            close;
        end    
        toc;    
    end
    
    %% perform analyses for mean activation by in the pre phase and the fb phase    
    
    if (DO_EPOCHS)
        fprintf(' generating epoch-based plots: ');
        tic;

        for phase = {'taskp','taskf','pre','fb'}
            eval(sprintf('t = %sT_hg;', phase{:}));
            eval(sprintf('h = %sH_hg;', phase{:}));

            figure;
            lims = max(abs(t));
            lims = [-lims lims];

            for c = 1:2
                subplot(1,2,c);
                PlotDotsDirect(sid, montage.MontageTrodes(~h, :), t(~h), hemi, lims, 8, 'recon_colormap', [], false, false);        
                if (sum(h) > 0)
                    PlotDotsDirect(sid, montage.MontageTrodes(h, :), t(h), hemi, lims, 15, 'recon_colormap', [], false, true);        
                end
                view(90+(c-1)*180,0);
                colorbar;         

                if (montage.MontageTrodes(cchan, 1) > 0 && c == 1)
                    plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'ko', 'linew', 2, 'markersize', 18)
                elseif (montage.MontageTrodes(cchan, 1) <= 0 && c == 2)
                    plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'ko', 'linew', 2, 'markersize', 18)
                end

            end

            maximize;
            mtit(sprintf('%s - %s', sid, phase{:}), 'xoff', 0, 'yoff', -0.10);    
            SaveFig(subjOutputDir, sprintf('epoch_%s', phase{:}), 'png', '-r600');
            close
        end

        toc;   
    end        
end

