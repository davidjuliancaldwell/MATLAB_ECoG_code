% %%%% OPTIONS
% 
% delayRestBegin = 1200; % Samples to shift the epoch by to account for reaction time
% preEpochBegin = 600;
% postEpochEnd = 1200;
% dataDir = [myGetenv('subject_dir') '\'];
% 
% 
% % fileName = [dataDir genPID('deca10')
% % '\d1\38e116_im_t_h001\38e116_im_t_hS001R01.dat']; % Imagery
% 
% [fileName path] = uigetfile([getenv('subject_dir') '*.dat']);
% 
% fileName = [path fileName];
% 
% encodedSubjID = fileName(length(myGetenv('subject_dir'))+[1:find(fileName(length(myGetenv('subject_dir'))+1:end)=='\',1,'first')-1]);
% subjID = reverseEncoding(encodedSubjID);
% 
% fprintf('Will save intermediate files in directory: %s\\\n', getenv('output_dir'));
% outputSubDir = input('Subdirectory to save to (i.e. ''sfn2011\\channel01'') => ','s');
% saveTarget = input('Subdirectory to save to (i.e. ''deca10_imagery'') => ','s');
% restCondition = input('Rest condition (single numerical value) => ');
% 
% fprintf('[Loading data]');
% [sig states parms] = load_bcidat(fileName);
% montageFile = [fileName(1:find(fileName=='.',1,'last')-1) '_montage.mat'];
% load(montageFile);
% 
% fprintf(' [Cleaning]');
% for field = fields(states)';
%     states.(field{:}) = single(states.(field{:}));
% end
% flds = fieldnames(parms);
% for i=flds';
%     try
%         tempField = parms.(i{1});
%     %         fprintf('%s ',tempField.Type);
%         switch tempField.Type
%             case 'string'
%                 eval(sprintf('params.%s = tempField.Value;',i{1}));
%             case 'matrix'
%                 eval(sprintf('params.%s = tempField.Value;',i{1}));
%             otherwise
%                 numVal = double(tempField.NumericValue);
%                 eval(sprintf('params.%s = numVal;',i{1}));
%         end
%     catch
%         bad = cell2mat(i);
%         fprintf('  ignoring params.%s, not numerical\n', bad);
%     end
% end
% clear parms
% 
% 
% sig = double(sig);
% 
% fprintf(' [Notch]');
% sig = NotchFilter(sig, [60 120 180], params.SamplingRate);
% 
% fprintf(' [CAR]');
% if mod(params.SamplingRate,1000) == 0
%     sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
% else
%     sig = ReferenceCAR([16 16 16 16], Montage.BadChannels, sig);
% end
% 
% fprintf(' [BandPass]');
% hfb = BandPassFilter(sig,[75 150], params.SamplingRate, 4);
% 
% fprintf(' [Power]');
% sigAmp = abs(hilbert(hfb));
% 
% fprintf(' [Smoothing]');
% 
% sigAmp = GaussianSmooth(sigAmp,params.SamplingRate/2);
% 
% fprintf(' [Epochs]');
% epochs = ones(length(find(diff(states.StimulusCode)~= 0)),1);
% epochs(:,1) = cumsum(epochs(:,1));
% newEpochAt = find(diff(states.StimulusCode) ~= 0);
% epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];
% epochs(:,4) = states.StimulusCode(epochs(:,3));
% 
% % Get rid of the last two trailing ones
% epochs(end-2:end,:) = [];
% 
% fprintf(' [ZScore]');
% 
% restEpochs = epochs(epochs(:,4) == restCondition,2:3);
% meanRestPeriods = [];
% stdRestPeriods = [];
% for rp = restEpochs'
%     meanRestPeriods = vertcat(meanRestPeriods,mean(sigAmp(rp(1)+delayRestBegin:rp(2),:),1));
%     stdRestPeriods = vertcat(stdRestPeriods,std(sigAmp(rp(1)+delayRestBegin:rp(2),:),1));
% end
% 
% zScoreAmp = bsxfun(@minus, sigAmp, mean(meanRestPeriods,1));
% zScoreAmp = bsxfun(@rdivide, zScoreAmp, mean(stdRestPeriods,1));

stimLength = params.StimulusDuration * params.SamplingRate + postEpochEnd+preEpochBegin;

scAverages = zeros(stimLength, 64, length(setdiff(nonzeros(unique(epochs(:,4))),restCondition)));
numStims = zeros(6,1);

%%
for epoch = epochs'
    sc = epoch(4);
    switch sc
        case 0
        case restCondition
        otherwise
            scIdx = find(setdiff(nonzeros(unique(epochs(:,4))),restCondition)==sc);
            scAverages(:,:,scIdx) = scAverages(:,:,scIdx) + zScoreAmp(epoch(2)-preEpochBegin:epoch(3)+postEpochEnd,:);
            numStims(scIdx) = numStims(scIdx) + 1;
    end
    
end

for sc = 1:size(scAverages,3)
    scAverages(:,:,sc) = scAverages(:,:,sc) ./ numStims(sc);
end

fullDir = [getenv('output_dir') '\' outputSubDir];

TouchDir(fullDir)

eval(sprintf('save %s\\%s.mat scAverages', fullDir, saveTarget));

%%
PlotCorticalDisplay(subjID,'l',Montage, {sprintf('%s\\%s.mat', fullDir, saveTarget)},@c_Epoch_Timeseries,preEpochBegin, postEpochEnd,[-5 8]);



fprintf('\n');


