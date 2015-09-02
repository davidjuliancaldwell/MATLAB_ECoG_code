%% TODO, needs to cross validate recording DATE for BCI2k File and EDF.
%% Doesn't currently happen and this can lead to false results.

curDir = pwd;

%% select files of interest and get output filename
cd (myGetenv('subject_dir'));

fprintf('select an edf file: \n');
[filename, directory] = uigetfile('*.rec;*.edf','MultiSelect', 'off');
edfFilename = [directory filename];

fprintf('select a bci2k file: \n');
[filename, directory] = uigetfile('*.dat','MultiSelect', 'off');
bci2kFilename = [directory filename];

subjid = extractSubjid(bci2kFilename);

%% load bci2kdata
[sig, sta, par] = load_bcidat(bci2kFilename);
defMaxChanNum = size(sig,2);


%% get channel montages for comparison
bChans = input(sprintf('channels from the BCI2K file to compare (default is [1:%d]): ', defMaxChanNum));

if (isempty(bChans))
    bChans = 1:defMaxChanNum;
end

cChans = input(sprintf('channels from the Clinical file to compare (default is [2:%d]): ', defMaxChanNum+1));

if (isempty(cChans))
    cChans = 2:defMaxChanNum+1;
end

[clinicalMontage, channelConfig] = getMontageFromEDF(edfFilename);

fprintf(' here is the clinical montage: \n\n');

for c = 1:length(clinicalMontage)
    fprintf('  %d) %s\n', c, clinicalMontage{c});
end

selectedMontage = input(sprintf('select the components of the clinical montage to extract (typical matlab vector format [a b:c]): '));
sChans = find(ismember(channelConfig, selectedMontage));

%% match bcidata to clinical data

% [signals, offsets] = matchClinicalData(edfFilename, bci2kFilename, true, 2:chans+1);
[signals, offsets] = matchClinicalData(edfFilename, bci2kFilename, true, cChans, bChans, sChans);


%% save result

% massage the offsets a little bit to account for synch errors either on
% our side or the clinical side
offsets = round(offsets/100)*100;

offsets
mode(offsets)

fprintf('clinical data matched, %f percent of channels correlated gave the same offset (%d of %d) \n', sum(offsets == mode(offsets)) / length(offsets) * 100, sum(offsets == mode(offsets)), length(offsets));
result = input('  is this sufficient to save the clinical data? ([Y]\\n): ', 's');

trodesFilename = [myGetenv('subject_dir') subjid '\trodes.mat'];
if (exist(trodesFilename, 'file'))
    load(trodesFilename);
end % otherwise all the trodes will be 0,0,0

if (isempty(result) || strcmp(lower(result), 'y') == 1)
    defOutputFilename = strrep(bci2kFilename, '.dat', '_clinical.mat');
    outputFilename = input(sprintf('filename to save [%s]: ', strrep(defOutputFilename,'\','\\')), 's');

    if (isempty(outputFilename))
        outputFilename = defOutputFilename;
    end    
    
    mOutputFilename = strrep(outputFilename, '.mat', '_montage.mat');
    
    bci2kFs = par.SamplingRate.NumericValue;

    EDF = sdfopen(edfFilename, 'r', 2);
    fs = round(mode(EDF.SampleRate));
    sdfclose(EDF);

%     feedback = resampleBci2kDiscreteState(sta.Feedback, bci2kFs, fs);
%     targetCode = resampleBci2kDiscreteState(sta.TargetCode, bci2kFs, fs);
%     resultCode = resampleBci2kDiscreteState(sta.ResultCode, bci2kFs, fs);
% 
%     fprintf('saving %s\n', outputFilename);
%     save(outputFilename, 'signals', 'feedback', 'targetCode', 'resultCode', 'fs');

    stimulusCode = resampleBci2kDiscreteState(sta.StimulusCode, bci2kFs, fs);
    
    fprintf('saving %s\n', outputFilename);
    save(outputFilename, 'signals', 'stimulusCode', 'fs');
    
    for c = 1:length(selectedMontage)
        Montage.Montage(c) = sum(channelConfig == selectedMontage(c));
    end
    
    Montage.MontageTokenized = {clinicalMontage{selectedMontage}};

    Montage.MontageTrodes = [];
    
    for c = 1:length(Montage.MontageTokenized)
        % build montage string
        if (c == 1)
            Montage.MontageString = Montage.MontageTokenized{c};
        else
            Montage.MontageString = [Montage.MontageString ' ' Montage.MontageTokenized{c}];
        end
        
        % build electrodes
        mElt = regexpi(Montage.MontageTokenized{c}, '([a-z]+).+', 'tokens', 'once');
        mElt = mElt{1};
        
        if (exist(mElt, 'var'))
            eval(sprintf('Montage.MontageTrodes = cat(1, Montage.MontageTrodes, %s);', mElt));
        else
            warning ('could not find electrode locations for %s, these will need to be set manually in the montage file', mElt);
            Montage.MontageTrodes = cat(1, Montage.MontageTrodes, zeros(Montage.Montage(c), 3));
        end
    end

    fprintf('Bad channels must be updated manually in the montage.\n');

    fprintf('saving %s\n', mOutputFilename);
    save(mOutputFilename, 'Montage');
    
end

cd (curDir);
    

% %% create the appropriate variables in the .mat file
% % signals, feedback, targetCode, resultCode, fs, Montage
% bci2kFs = par.SamplingRate.NumericValue;
% 
% EDF = sdfopen(edfFilename, 'r', 2);
% fs = round(mode(EDF.SampleRate));
% sdfclose(EDF);
% 
% feedback = resampleBci2kDiscreteState(sta.Feedback, bci2kFs, fs);
% targetCode = resampleBci2kDiscreteState(sta.TargetCode, bci2kFs, fs);
% resultCode = resampleBci2kDiscreteState(sta.ResultCode, bci2kFs, fs);
% 
% montageFilename = strrep(bci2kFilename, '.dat', '_montage.mat');
% if (exist(montageFilename, 'file'))
%     load(montageFilename);
% else
%     Montage.Montage = size(signals, 2);
%     Montage.BadChannels = [];
% end
% 
% save(outputFilename, 'signals', 'feedback', 'targetCode', 'resultCode', 'fs');
% 
% cd (curDir);
% 
