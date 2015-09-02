addpath(fullfile(myGetenv('MATLAB_DEVEL_DIR'), 'SigAnal', 'xval'));
addpath(genpath('d:\research\code\gridlab\external\mRMR\'))
addpath(fullfile(myGetenv('gridlab_ext_dir'), 'External', 'libsvm-3.17', 'matlab'));

%% needed variables
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');

% subject
subjid = '979eab';

% input files
files = listDatFiles(subjid, 'goal_bci');

files = files(2:end);


badstr = input('list bad channels in matlab vector format: ', 's');
eval (sprintf('bads = %s;', badstr));
bads

%% set up the temporary directory structures
tic;

metaFilepath = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
subjectMetaFilepath = fullfile(metaFilepath, subjid);
TouchDir(subjectMetaFilepath);

%% next, extract the targeting and hold features for all channels, as well as the target types

targets = [];
features = [];

for fileIdx = 1:length(files)
    [sig,sta,par] = load_bcidat(files{fileIdx});
    feats = extractFloatStates(sta);
        
    preStarts = find(diff([0; double(sta.TargetCode)]) > 0);
    preEnds = find(diff([0; double(sta.Feedback)]) > 0);
    
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

% this is problematic because then the support vectors in the model don't
% include these channels
%features(:, bads) = [];

% let's try this instead
features(:, bads) = 0;

%% lastly, train a classifier, save the model and report results

% features(17,:) =[];
% labels(17) = [];


UP = [1 2 3 4];
labels = ismember(targets, UP);

% tic
% [hits, counts] = nFoldSVM(zscore(features)', labels, 5, 'libsvm');

partition = goal_determineFolds(labels, 5);
[acc, c, gamma] = mCrossvalSVM(features, labels', partition, struct(), []);

fprintf('average classification performance (nFold): %f\n', acc);

featureIndices = mrmr_corrq_d(features, labels, 10);
channelSelect = false(size(features,2),1);
channelSelect(featureIndices) = true;
features(:,~channelSelect) = 0;

% set up the path to the libsvm exe's directory
libsvmexedir = fullfile(myGetenv('gridlab_ext_dir'), 'external', 'libsvm-3.17', 'windows');

% add exe the command line options
svmTrainExePathAndOpts = fullfile(libsvmexedir, sprintf('svm-train.exe -q -t 0 -b 1 -c %f -g %f', c, gamma));

% path to where to write out hte model file
svmTrainDataPath = fullfile(META_DIR, subjid, 'SvmTrainingData');

% write out the training data
libsvmwrite(svmTrainDataPath, double(labels), sparse(features));

% run the classifier to build the model
res = system([svmTrainExePathAndOpts ' ' svmTrainDataPath]);

toc