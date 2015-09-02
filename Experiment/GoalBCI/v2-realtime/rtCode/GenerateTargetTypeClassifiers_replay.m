%% needed variables
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');

% subject
subjid = 'd6c834';

% input files
% files = listDatFiles(subjid, 'goal_bci');
files = goalDataFiles(subjid);

% files = files(3);
% files = files(1:2);

%% set up the temporary directory structures
metaFilepath = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'playback');
subjectMetaFilepath = fullfile(metaFilepath, subjid);
TouchDir(subjectMetaFilepath);

%% first, determine if it's necessary to rerun BCI2000 to get the features of interest
% we store the AR coefficients meta data files

featurePaths = {};
missing = 0;

for fileIdx = 1:length(files)
    fprintf('checking for a feature file for %s, %s ... ', subjid, files{fileIdx});
    
    [~, fname] = fileparts(files{fileIdx});
    % this is the location of the replayed bci2000 file with the features
    % states generated... such a hack.
    storagePath = fullfile(subjectMetaFilepath, [fname '_replay.dat']);
    
    if (exist(storagePath, 'file'))
        % don't need to extract
        fprintf('found.\n');
    else        
        fprintf('not found, it is necessary to use the file playback module to generate features for these recordings.\n');
        missing = 1;
    end
    
    featurePaths{fileIdx} = storagePath;
end

if missing
    error('please generate the missing files and copy them to the appropriate location, per above, then re-run this script.');
else
    fprintf('All Files Found!\n');
end


%% next, extract the targeting and hold features for all channels, as well as the target types

targets = [];
features = [];

for fileIdx = 1:length(featurePaths)
    [~,replaysta,~] = load_bcidat(featurePaths{fileIdx});
    [~,sta,par] = load_bcidat(files{fileIdx});

    feats = extractFloatStates(replaysta);
%     feats = getSpectralEstimatesFromStates(replaysta);
%     feats = feats / 100;
    
    len = min(length(sta.TargetCode), size(feats,1));
    
    feats = feats(1:len, :);
    sta.TargetCode = sta.TargetCode(1:len);
    sta.Feedback = sta.Feedback(1:len);
    
    preStarts = find(diff([0; double(sta.TargetCode)]) > 0);
    preEnds = find(diff([0; double(sta.Feedback)]) > 0);
    
    if (strcmp(subjid, '6cc87c') == 1 && fileIdx == 3)
        preStarts(1:2) = [];
        preEnds(1) = [];
    end
    
    if (preEnds(end) < preStarts(end) || length(preEnds) ~= length(preStarts) || preEnds(1) < preStarts(1))
        error('houston, we have a problem');
    end

    nullTargets = sta.TargetCode(preStarts) == 9;
    preStarts(nullTargets) = [];
    preEnds(nullTargets) = [];
    
    % this is a hack, but necessary
    if (strcmp(subjid, '6b68ef') == 1 && fileIdx == 1)
        preStarts(1:1) = [];
        preEnds(1:1) = [];
    end
    
    targets = cat(1, targets, sta.TargetCode(preStarts));
    % this is using the difference between the targeting phase and the rest
    % phase as the feature
%     features = cat(1, features, getEpochMeans(feats, preStarts, preEnds)'-getEpochMeans(feats, preStarts-par.SamplingRate.NumericValue, preStarts-1)');
    % this is just using the abs power during the targeting phase as the
    % feature
    features = cat(1, features, getEpochMeans(feats, preStarts, preEnds)');
%     features = cat(1, features, getEpochMeans(feats, preStarts, preStarts+ round((preEnds-preStarts)/2))');
end

%% lastly, train a classifier, save the model and report results

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

labels = ismember(targets, UP);

% effectively leave one out
addpath(fullfile(myGetenv('gridlab_ext_dir'), 'External', 'libsvm-3.17', 'matlab'));

features([1 22],:) = [];
labels([1 22]) = [];

[acc, c, gamma] = mCrossval(features', labels, 5);
% [acc, c, gamma] = parameterSweepingNFoldSVM(features', labels, 5)
fprintf('average classification performance (nFold): %f\n', acc);

% [hits, counts] = nFoldSVM(features', labels, length(labels), 'libsvm');
% fprintf('average classification performance (LEAVE-ONE-OUT): %f\n', mean(hits./counts));

% svm = libsvmtrain(double(labels), features, '-q -t 0 -b 1');
% write out a model file for all of the data, instead of training a matlab
% svm instance
return;

libsvmexedir = fullfile(myGetenv('gridlab_ext_dir'), 'external', 'libsvm-3.17', 'windows');
svmTrainExePathAndOpts = fullfile(libsvmexedir, 'svm-train.exe -q -t 0 -b 1');
svmTrainDataPath = fullfile(META_DIR, subjid, 'SvmTrainingData');
libsvmwrite(svmTrainDataPath, double(labels), sparse(features));
res = system([svmTrainExePathAndOpts ' ' svmTrainDataPath]);

