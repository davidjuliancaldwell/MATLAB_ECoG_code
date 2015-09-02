% constants
tcs;
Constants;

TouchDir(fullfile(OUTPUT_DIR, 'dump'));

%%

for c = 1:length(SIDS)    
    sid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, Montage, ctl] = goalDataFiles(sid);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)));
        
    isUp = ismember(targets, UP);
    isDown = ismember(targets, DOWN);
    
    isBig = ismember(targets, BIG);
    isSmall = ismember(targets, SMALL);
    
    isNear = ismember(targets, NEAR);
    isFar = ismember(targets, FAR);

    if (c == 3)
        restMeans = restMeans(1:62, :, :);
        tgtMeans = tgtMeans(1:62, :, :);
        holdMeans = holdMeans(1:62, :, :);
        preFbMeans = preFbMeans(1:62, :, :);
        fbMeans = fbMeans(1:62, :, :);
    end
    
    figure;
    n = 0;
    
    for bandIdx = 1:size(restMeans, 3)        
        for period = 1:4
            switch (period)
                case 1
                    means = tgtMeans;
                    stxt = '-targeting-';
                case 2
                    means = holdMeans;
                    stxt = '-hold-';
                case 3
                    means = preFbMeans;
                    stxt = '-prefb-';
                case 4
                    means = fbMeans;
                    stxt = '-fb-';
            end

            for condition = 1%1:3
                switch (condition)
                    case 1
                        a = isUp;
                        b = isDown;
                        ttxt = 'up-down-';
                    case 2
                        a = isBig;
                        b = isSmall;
                        ttxt = 'big-small-';
                    case 3
                        a = isNear;
                        b = isFar;
                        ttxt = 'near-far-';
                end
                
                [h, p, ~, t] = ttest2(means(:, a, bandIdx), means(:, b, bandIdx), 'dim', 2);
                t = t.tstat;

                n = n + 1;
                subplot(size(restMeans,3),4,n);
                
                doBrainPlotWithDots(sid, t, p);
                plot3(Montage.MontageTrodes(ctl, 1), Montage.MontageTrodes(ctl, 2), Montage.MontageTrodes(ctl, 3), 'bo', 'markersize', 18, 'linewidth', 3);

                if (c == 1)
                    view(-40, 30);
                end
                
                txt = [subcode stxt ttxt BAND_NAMES{bandIdx}];
                title(txt);

%                 SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
%                 close;            
            end       
        end
    end
    maximize;
    SaveFig(fullfile(OUTPUT_DIR, 'dump'), subcode, 'png');
end