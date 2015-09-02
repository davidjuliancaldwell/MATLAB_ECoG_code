% plot some basic things like subject coverage
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};
SUBCODES = {'S1','S2','S3','S4'};

BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];
BAND_NAMES = {'delta', 'theta', 'alpha', 'beta', 'gamma'};

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

%%

for c = 1:length(SIDS)    
    sid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, Montage] = goalDataFiles(sid);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)));
        
    isUp = ismember(targets, UP);
    isDown = ismember(targets, DOWN);
    
    isBig = ismember(targets, BIG);
    isSmall = ismember(targets, SMALL);
    
    isNear = ismember(targets, NEAR);
    isFar = ismember(targets, FAR);
    
    for bandIdx = 5:size(restMeans, 3)
        if (c == 3)
            restMeans = restMeans(1:62, :, :);
            tgtMeans = tgtMeans(1:62, :, :);
            holdMeans = holdMeans(1:62, :, :);
            fbMeans = fbMeans(1:62, :, :);
        end
        
        for condition = 3%1:3
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

            for period = 1:3
                switch (period)
                    case 1
                        means = tgtMeans;
                        stxt = '-targeting-';
                    case 2
                        means = holdMeans;
                        stxt = '-hold-';
                    case 3
                        means = fbMeans;
                        stxt = '-fb-';
                end
                
                [h, p, ~, t] = ttest2(means(:, a, bandIdx), means(:, b, bandIdx), 'dim', 2);
                t = t.tstat;

                doBrainPlotWithDots(sid, t, p);
                txt = [subcode stxt ttxt BAND_NAMES{bandIdx}];
                title(txt);
return
                SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
                close;            
            end       
        end
    end
end