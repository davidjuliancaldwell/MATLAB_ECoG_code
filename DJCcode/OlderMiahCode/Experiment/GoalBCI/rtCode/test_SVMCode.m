%% this is a simple script to test against the real-time Bci2000 impl of the svm.  it's currently set up to use the third file from the first
% day of 6b68ef as test data against the model that was trained on the
% first two days.  can test outcomes and posterior probabilities against
% the rt impl.

%% needed variables
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');

% subject
subjid = '6b68ef';

% input files
files = listDatFiles(subjid, 'goal_bci');

files = files(3);

%% set up the temporary directory structures
metaFilepath = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
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

%% get the features

targets = [];
features = [];


for fileIdx = 1:length(files)
    [~,replaysta,~] = load_bcidat(featurePaths{fileIdx});
    [~,sta,par] = load_bcidat(files{fileIdx});
    
    feats = getSpectralEstimatesFromStates(replaysta);
    feats = feats / 100;
    
    len = min(length(sta.TargetCode), size(feats,1));
    
    feats = feats(1:len, :);
    sta.TargetCode = sta.TargetCode(1:len);
    sta.Feedback = sta.Feedback(1:len);
    
    preStarts = find(diff([0; double(sta.TargetCode)]) > 0);
    preEnds = find(diff([0; double(sta.Feedback)]) > 0);
    
    if (preEnds(end) < preStarts(end) || length(preEnds) ~= length(preStarts) || preEnds(1) < preStarts(1))
        error('houston, we have a problem');
    end

    nullTargets = sta.TargetCode(preStarts) == 9;
    preStarts(nullTargets) = [];
    preEnds(nullTargets) = [];
    
    targets = cat(1, targets, sta.TargetCode(preStarts));
    features = cat(1, features, getEpochMeans(feats, preStarts, preEnds)');
end

svmModelPath = fullfile(META_DIR, subjid, 'SvmTrainingData.model');
svm = mSVM;
svm.loadModel(svmModelPath);
[labels, probabilities] = svm.predict(features);

