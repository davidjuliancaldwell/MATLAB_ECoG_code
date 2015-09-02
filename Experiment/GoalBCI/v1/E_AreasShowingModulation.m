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
    
    keepers = ismember(targets, 1:8);
    
    for bandIdx = 1:size(restMeans, 3)
        if (c == 3)
            restMeans = restMeans(1:62, :, :);
            tgtMeans = tgtMeans(1:62, :, :);
            holdMeans = holdMeans(1:62, :, :);
            fbMeans = fbMeans(1:62, :, :);
        end
        
        [tgth, tgtp, ~, tgtt] = ttest2(restMeans(:, keepers, bandIdx), tgtMeans(:, keepers, bandIdx), 'dim', 2);
        tgtt = tgtt.tstat;
        
        doBrainPlotWithDots(sid, tgtt, tgtp);
        txt = [subcode '-targeting-' BAND_NAMES{bandIdx}];
        title(txt);
        
        SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
        close;
        
        [holdh, holdp, ~, holdt] = ttest2(restMeans(:, keepers, bandIdx), holdMeans(:, keepers, bandIdx), 'dim', 2);
        holdt = holdt.tstat;
        
        doBrainPlotWithDots(sid, holdt, holdp);
        txt = [subcode '-hold-' BAND_NAMES{bandIdx}];
        title(txt);
        
        SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
        close;
                
        [fbh, fbp, ~, fbt] = ttest2(restMeans(:, keepers, bandIdx), fbMeans(:, keepers, bandIdx), 'dim', 2);
        fbt = fbt.tstat;
        
        doBrainPlotWithDots(sid, fbt, fbp);
        txt = [subcode '-fb-' BAND_NAMES{bandIdx}];
        title(txt);
        
        SaveFig(fullfile(OUTPUT_DIR, 'dump'), txt, 'png');
        close;        
    end
end