%% needed variables
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');

% subject
subjid = '6b68ef';

% input files
files = listDatFiles(subjid, 'goal_bci');

% files = files(3);
files = files(1:2);

%% set up the temporary directory structures
metaFilepath = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
subjectMetaFilepath = fullfile(metaFilepath, subjid);
TouchDir(subjectMetaFilepath);

%% first, determine if it's necessary to rerun BCI2000 to get the features of interest
% we store the AR coefficients meta data files

featurePaths = {};

for fileIdx = 1:length(files)
    fprintf('checking for a feature file for %s, %s ... ', subjid, files{fileIdx});
    
    [~, fname] = fileparts(files{fileIdx});
    storagePath = fullfile(subjectMetaFilepath, [datestr(read_bcidate(files{fileIdx}), 'dd-mmm-yyyy') '_' fname '.mat']);
    
%     if (0)
    if (exist(storagePath, 'file'))
        % don't need to extract
        fprintf('found.\n');
    else
        fprintf('not found, performing extraction.\n');
        
        recFilepath = files{fileIdx};
        
        [~, montageFilepath] = loadCorrespondingMontage(recFilepath);        
        output = generateBCIFeatures(recFilepath, montageFilepath);
        
        save(storagePath, 'output', 'recFilepath', 'montageFilepath');
    end
    
    featurePaths{fileIdx} = storagePath;
end

%% next, extract the targeting and hold features for all channels, as well as the target types

targets = [];
features = [];

for fileIdx = 1:length(featurePaths)
    load(featurePaths{fileIdx});
    
    sta = output.States;
    par = output.Parms;
    feats = output.Signal;
    
    preStarts = find(diff([0; double(sta.TargetCode)]) > 0);
    preEnds = find(diff([0; double(sta.Feedback)]) > 0);
    
    if (preEnds(end) < preStarts(end) || length(preEnds) ~= length(preStarts) || preEnds(1) < preStarts(1))
        error('houston, we have a problem');
    end

    nullTargets = sta.TargetCode(preStarts) == 9;
    preStarts(nullTargets) = [];
    preEnds(nullTargets) = [];
    
%     % this is a hack, but necessary
%     if (strcmp(subjid, '6b68ef') == 1 && fileIdx == 1)
%         preStarts(1:3) = [];
%         preEnds(1:3) = [];
%     end
    
    targets = cat(1, targets, sta.TargetCode(preStarts));
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
[hits, counts] = nFoldSVM(features', labels, length(labels), 'libsvm');
fprintf('average classification performance (LEAVE-ONE-OUT): %f\n', mean(hits./counts));

% svm = libsvmtrain(double(labels), features, '-q -t 0 -b 1');
% write out a model file for all of the data, instead of training a matlab
% svm instance

libsvmexedir = fullfile(myGetenv('gridlab_ext_dir'), 'external', 'libsvm-3.17', 'windows');
svmTrainExePathAndOpts = fullfile(libsvmexedir, 'svm-train.exe -q -t 0 -b 1');
svmTrainDataPath = fullfile(META_DIR, subjid, 'SvmTrainingData');
libsvmwrite(svmTrainDataPath, double(labels), sparse(features));
res = system([svmTrainExePathAndOpts ' ' svmTrainDataPath]);

