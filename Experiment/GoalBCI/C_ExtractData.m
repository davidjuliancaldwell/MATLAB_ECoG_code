%% define constants
addpath ./functions
Z_Constants;

%%

for c = 10:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);

    load(fullfile(META_DIR, sprintf('%s-trial_info.mat', subjid)), 'trialStarts', 'trialEnds', 'trialFiles', 'bad_channels', 'bad_marker');    
    [files, hemi, montage, cchan] = goalDataFiles(subjid);
    
    bad_trials = all(bad_marker);
    
    trialStarts(bad_trials) = [];
    trialEnds(bad_trials) = [];
    trialFiles(bad_trials) = [];
       
    data = {};
    targets = [];
    paths = {};
    diffs = {};
    targetY = {};
    targetD = {};    
    
    for fileIdx = 1:length(files)
        fprintf('  file %d of %d\n', fileIdx, length(files));

        [sig, sta, par] = load_bcidat(files{fileIdx}); 

%         [sig, sta] = resynchGugerData2(sig, sta, bad_channels);
        
        % first, preprocess, filtering for HG
%         sig = ReferencePCA(montage.Montage, bad_channels, double(sig));
%         sig = ReferencePCA(GugerizeMontage(montage.Montage), bad_channels, double(sig));
        sig = ReferenceCAR(GugerizeMontage(montage.Montage), bad_channels, double(sig));        
        
        fs = par.SamplingRate.NumericValue;
        sig = hilbAmp(sig, [70 150], fs);                
%         sig = GaussianSmooth(sig, round(.3*fs));
        sig = log(sig.^2);
        
%         R = corr(sig);
%         figure
%         imagesc(R .* double(eye(64)==0)); colorbar;
%         title(sprintf('%s %d', subjid, fileIdx));
        
        % some quick bookkeeping / removal of null targets
        mTargets = double(sta.TargetCode(trialStarts(trialFiles==fileIdx)+par.ITIDuration.NumericValue*fs))';
        targets = cat(2, targets, mTargets);
                
        % now resample to the sample block sampling rate
        sbs = par.SampleBlockSize.NumericValue;
        sig = resample(sig, fs/sbs, fs);
        fs = fs / sbs;        
        
        % grab the neural data of interest
        mStarts = round(trialStarts(trialFiles==fileIdx) / sbs);
        mEnds   = round(trialEnds(trialFiles==fileIdx) / sbs) + par.PostFeedbackDuration.NumericValue * fs;
        
        mStarts(mTargets==9) = [];
        mEnds(mTargets==9) = [];
        
        if (mEnds(end) > length(sig))
            mStarts(end) = [];
            mEnds(end) = [];
            
%             error ('looks like adding the post trial brain data _is_ going to cause problems');
        end
        
        mdata = getEpochSignal(sig, mStarts, mEnds);
        
        if (~iscell(mdata))
            mdata = squeeze(mat2cell(mdata, 151, ones(size(mdata, 2),1), ones(size(mdata, 3),1)));
        end
        
        data = cat(2, data, mdata);
        
        if (~exist('itiDur','var'))
            itiDur = par.ITIDuration.NumericValue;
            preDur = par.PreFeedbackDuration.NumericValue;
            maxFbDur = par.MaxFeedbackDuration.NumericValue;
            postDur = par.PostFeedbackDuration.NumericValue;
            
            t = -itiDur-preDur : (1/fs) : maxFbDur+postDur;
        else
            if (itiDur ~= par.ITIDuration.NumericValue || ...
                preDur ~= par.PreFeedbackDuration.NumericValue || ...
                maxFbDur ~= par.MaxFeedbackDuration.NumericValue || ...
                postDur ~= par.PostFeedbackDuration.NumericValue)
                warning('apparent change in trial duration');
            end
        end
        
        % extract the path and target data
        normpath = map(double(sta.CursorPosY), 0, 4096, 0, 1);
        targy = NaN*ones(size(normpath));
        targd = targy;
        
        targy(sta.TargetCode ~= 0) = double(par.Targets.NumericValue(sta.TargetCode(sta.TargetCode ~= 0), 2)) / 100;
        targd(sta.TargetCode ~= 0) = double(par.Targets.NumericValue(sta.TargetCode(sta.TargetCode ~= 0), 5)) / 100;
        
        mpaths = squeeze(getEpochSignal(normpath(1:sbs:end), mStarts, mEnds));
        
        % correct the paths for the jump from the previous position...
        if (~iscell(mpaths))
            mpaths = mat2cell(mpaths,size(mpaths, 1), ones(size(mpaths, 2),1));
        end
        
        start = find(t>0, 1, 'first');                
        for z = 1:length(mpaths)
            mpaths{z}(1:start) = mpaths{z}(start+1);
        end
        
        paths = cat(2, paths, mpaths);
        
        mtargy = squeeze(getEpochSignal(targy(1:sbs:end), mStarts, mEnds));
        targetY = cat(2, targetY, mtargy);
        
        mtargd = squeeze(getEpochSignal(targd(1:sbs:end), mStarts, mEnds));
        targetD = cat(2, targetD, mtargd);
        
        mdiffs = squeeze(getEpochSignal(normpath(1:sbs:end)-targy(1:sbs:end), mStarts, mEnds));
        diffs = cat(2, diffs, mdiffs);                
    end
    
    targets (targets==9) = [];
    
    save(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');
    
    clearvars -except c SIDS SUBCODES META_DIR OUTPUT_DIR
end 

