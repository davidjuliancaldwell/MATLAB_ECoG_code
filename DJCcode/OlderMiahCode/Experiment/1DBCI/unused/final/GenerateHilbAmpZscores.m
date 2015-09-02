% generate zscores vs rest means for all trials within a bci run and save
% the output to a cache file

% this script makes no assumptions about using the same montage throughout
% the recording session.  If the montage changes then this script will
% blindly continue on as if it hadn't.  If the montage changes in such a
% way that a different number of channels are recorded then the script will
% probably break.

%% specify subject & task
dsFile = '..\ds\04b3d5_ud_im_t_ds.mat';

%% get the dataset for that subject & task
load(dsFile);

%% process all the recordings in the dataset and concatenate scores and
%% target codes
for recnum = 1:length(ds.recs)
    fprintf('processing recording %d of %d\n', recnum, length(ds.recs));

    [restTemp, tgtTemp, fbTemp, rewardTemp, tgtCodesTemp] = ...
        ProcessBCI2000Recording(ds.recs(recnum).dir, ds.recs(recnum).file, ds.recs(recnum).montage);

    if (~exist('restScores', 'var'))
        restScores = restTemp;
    else
        restScores = cat(1, restScores, restTemp);
    end

    if (~exist('tgtScores', 'var'))
        tgtScores = tgtTemp;
    else
        tgtScores = cat(1, tgtScores, tgtTemp);
    end

    if (~exist('fbScores', 'var'))
        fbScores = fbTemp;
    else
        fbScores = cat(1, fbScores, fbTemp);
    end

    if (~exist('rewardScores', 'var'))
        rewardScores = rewardTemp;
    else
        rewardScores = cat(1, rewardScores, rewardTemp);
    end

    if (~exist('tgtCodes', 'var'))
        tgtCodes = tgtCodesTemp;
    else
        tgtCodes = cat(1, tgtCodes, tgtCodesTemp);
    end
end


%% save the scores and target codes (so we don't have to re run the whole
%% ds).
idxs = strfind(dsFile, '\');
dsFilename = dsFile(idxs(end)+1:end);
save(['cache\' dsFilename '.cache.mat']);

%% plot on the pt specific brain, should be two figures, one for up
%% targets, one for down targets, with a subplot showing the cortex for
%% each phase of the task.

