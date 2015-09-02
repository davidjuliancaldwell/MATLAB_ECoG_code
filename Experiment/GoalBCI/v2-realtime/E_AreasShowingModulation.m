tcs;
Constants;

TouchDir(fullfile(OUTPUT_DIR, 'dump'));

%%
for c = 1:length(SIDS)    
    sid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, Montage] = goalDataFiles(sid);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)));
    
    keepers = ismember(targets, 1:8);
    
    if (c == 3)
        restMeans = restMeans(1:62, :, :);
%         tgtMeans = tgtMeans(1:62, :, :);
%         holdMeans = holdMeans(1:62, :, :);
        preFbMeans = preFbMeans(1:62, :, :);
        fbMeans = fbMeans(1:62, :, :);
    end
    
    for bandIdx = 1:size(restMeans, 3)        
        for phase = 1:2
            switch(phase)
%                 case 1 % targeting
%                     cmp = tgtMeans;
%                     str = 'targeting';
%                 case 2 % hold
%                     cmp = holdMeans;
%                     str = 'hold';
                case 1 % preFb (targeting & hold)
                    cmp = preFbMeans;
                    str = 'prefb';
                case 2 % fb
                    cmp = fbMeans;
                    str = 'fb';
            end
                    
            [h, p, ~, t] = ttest2(restMeans(:, keepers, bandIdx), cmp(:, keepers, bandIdx), 'dim', 2);
            t = t.tstat;

            doBrainPlotWithDots(sid, t, p);
            txt = [subcode '-' str '-' BAND_NAMES{bandIdx}];
            title(txt);

            SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
            close;
            
        end        
    end
end