%%
Z_Constants;

%% perform analyses
load(fullfile(META_DIR, 'areas.mat'));

peakSave = {};
lagSave = {};

for ctr = 1:length(SIDS)
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    load(fullfile(META_DIR, [sid '_epochs_fs']));
    load(fullfile(META_DIR, [sid '_results']));
    
    ups = tgts == 1;
    hits = tgts == ress;
    accs(ctr) = mean(hits);
    
    [~,~,~,Montage,cchan] = filesForSubjid(sid);
    
    trs = trodesOfInterest{ctr};
    trs(trs==cchan) = [];
    
    ctl = squeeze(epochs(cchan, :, :));
    pmv = epochs(trs, :, :);
    
    %% do the decompositions
    fw = 1:1:100;
    
    [a, ~, tfctl] = time_frequency_wavelet(ctl', fw, fs, 1, 1, 'CPUtest');
    
    tfpmv = [];
    for pmvChan = 1:length(trs)
        [~, ~, tfpmv(pmvChan, :, :, :)] = time_frequency_wavelet(squeeze(pmv(pmvChan, :, :))', fw, fs, 1, 1, 'CPUtest');        
    end
    
    %%  calculate plvs

    for pmvChan = 1:length(trs)

        Z=tfctl.*conj(squeeze(tfpmv(pmvChan, :, :, :))); % multiplying X with complex conjugate of Y is the same as Z=aX.*aY.exp(i*pX)*exp(-i*pY).
        aZ=abs(Z);

               
        figure        
        for c = 1:4
            switch(c)
                case 1
                    idx = ups&hits; text = 'up & hit';
                case 2
                    idx = ups&~hits; text = 'up & miss';
                case 3
                    idx = ~ups&hits; text = 'down & hit';
                case 4
                    idx = ~ups&~hits; text = 'down & miss';
            end
             
            subplot(2,2,c);
            plv=abs(mean(Z(:,:,idx)./aZ(:,:,idx),3)); % PLV over trials
            nplv = normalize_plv(plv', plv(t > -preDur - itiDur & t < -preDur, :)')';
            imagesc(t, fw, nplv');
            axis xy
            xlabel('time (s)');
            ylabel('freq (hz)');
            set(vline([-preDur 0 fbDur], 'k'), 'linew', 2);
            colorbar;
            set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);
            title(text);
        end
        
        mtit((sprintf('PLV %s - %s up',sid, trodeNameFromMontage(trs(pmvChan), Montage))), 'xoff', 0, 'yoff', 0);
        maximize;
        SaveFig(OUTPUT_DIR, sprintf('%s_plv_%d', sid, trs(pmvChan)), 'png');
        close
    end
    
end
