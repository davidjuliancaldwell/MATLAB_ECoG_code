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
% BANDS = [13 18; 70 200];
BAND_NAMES = {'delta', 'theta', 'alpha', 'beta', 'gamma'};

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

WINSIZE = 1;

%% run the analyses
addpath ./functions

FORCE_FEATURES = false;

for c = 1:length(SIDS)    
    %% feature extraction.  
    % Current implementation is to break up the targeting and hold periods in
    % to WINSIZE sec windows.  This should give approximately 15x64x5 features, 15
    % for the number of windows, 64 for the number of channels and 5 for the
    % frequency bins

    subjid = SIDS{c};
    subcode = SUBCODES{c};
    featureFile = fullfile(META_DIR, sprintf('%s-features.mat', subcode));
    
    % check to see if the file already exists or if we are forcing an overwrite
    if (~exist(featureFile, 'file') || FORCE_FEATURES)
        fprintf ('generating features for %s: \n', subcode);
        [files, ~, Montage] = goalDataFiles(subjid);

        features = [];
        targets = [];
        results = [];
        
        for fileIdx = 1:length(files)
            fprintf('  working on file %d of %d\n', fileIdx, length(files));
            
            [sig, sta, par] = load_bcidat(files{fileIdx});   

            if (fileIdx == 1 && strcmp(subjid, '6b68ef'))
                sig = sig(4e4:end, :);

                for fieldname = fieldnames(sta)'
                    temp = sta.(fieldname{:});
                    sta.(fieldname{:}) = temp(4e4:end, :);
                end
            end
                        
            [mFeatures, mTargets, mResults] = extractGoalBCIFeatures(sig, sta, par, BANDS, Montage, WINSIZE);
            
            features = cat(4, features, permute(mFeatures, [1 3 4 2]));
            targets = cat(1, targets, mTargets);
            results = cat(1, results, mResults);
        end
        
        save(featureFile, 'features', 'targets', 'results');
    else
        fprintf ('using previously generated features for %s: \n', subcode);
        load(featureFile);
    end
    
    features = features(:,:,:,:); % temp
    
    %% train and test model using leave-one-out validation    
    rFeatures = reshape(features, numel(features) / size(features, 4), size(features,4));

    % drop all of the null targets
    droppers = targets == 9;
    rFeatures(:, droppers) = [];
    targets(droppers) = [];
    results(droppers) = [];
    
%     tClass = ismember(targets, UP); mtitle = 'up v down';
%     tClass = ismember(targets, NEAR); mtitle = 'near v far';
    tClass = ismember(targets, BIG); mtitle = 'big v small';
%     isExtreme = (ismember(targets, BIG) & ismember(targets, NEAR)) | ...
%                 (ismember(targets, SMALL) & ismember(targets, FAR));    
%     rFeatures(:, ~isExtreme) = [];
%     targets(~isExtreme) = [];
%     tClass = ismember(targets, BIG) & ismember(targets, NEAR); mtitle = 'easiest v hardest';
    
    tClassHat = zeros(size(targets));

    
    lambdas = 10.^(-5:5);
    acc = [];
    
    for lambdaidx = 1:length(lambdas)
        lambdas(lambdaidx)
        acc(lambdaidx) = nFoldCrossValidation(rFeatures', tClass, 5, lambdas(lambdaidx));
    end
    
    figure
    semilogx(lambdas, acc, 'o-', 'color', theme_colors(blue, :), 'linewidth', 3, 'markersize', 8);
    xlabel('lambda');
    ylabel('accuracy');
    ylim([.3 .7]);
    ax = hline(.5, 'k:'); set(ax, 'linewidth', 2);
    title(sprintf('%s - %s', subcode, mtitle));
    SaveFig(OUTPUT_DIR, sprintf('%s-class-%s', subcode, mtitle), 'png');
    
%     for idx = 1:length(targets)
%         train = (1:length(targets)) ~= idx;
%         test = ~train;
% 
%         % SVM - matlab
% %         svm = svmtrain(rFeatures(:, train)', tClass(train)');
% %         tClassHat(idx) = svmclassify(svm, rFeatures(:, test)');
% 
%         % regression tree - matlab
%         tree = ClassificationTree.fit(rFeatures(:, train)', tClass(train)');
%         tClassHat(idx) = predict(tree, rFeatures(:, test)');
%     end
    
    mean(tClass==tClassHat)
end

