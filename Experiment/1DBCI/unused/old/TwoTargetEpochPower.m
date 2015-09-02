% subject = 'deca10';
% GoodMotorFiles = {
%     'd1\38e116_ud_mot_h001\38e116_ud_mot_hS001R01.dat',
%     'd1\38e116_ud_mot_h001\38e116_ud_mot_hS001R03.dat',
%     'd2\38e116_ud_mot_h001\38e116_ud_mot_hS001R02.dat',
%     'd3\38e116_2targ_fast001\38e116_2targ_fastS001R02.dat',
%     'd3\38e116_2targ_fast001\38e116_2targ_fastS001R03.dat',
% };
% 
% 
subject = '30052b';% 
GoodMotorFiles = {
    'day1s2\30052b_ud_mot_t001\30052b_ud_mot_tS001R02.dat',
    'day1s2\30052b_ud_mot_t001\30052b_ud_mot_tS001R03.dat',
    'day1s2\30052b_ud_mot_t001\30052b_ud_mot_tS001R04.dat',
    'day1s2\30052b_ud_mot_t001\30052b_ud_mot_tS001R05.dat',
    'day2\30052b_ud_mot_t001\30052b_ud_mot_tS001R01.dat',
    'day2\30052b_ud_mot_t001\30052b_ud_mot_tS001R02.dat',
};

% subject = 'juna09';
% GoodIMFiles = {
% %     'day1s2\30052b_ud_im_t001\30052b_ud_im_tS001R02.dat',
% %     'day1s2\30052b_ud_im_t001\30052b_ud_im_tS001R03.dat',
% %     'day2\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',
% %     'day2\30052b_ud_im_t001\30052b_ud_im_tS001R03.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R02.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R04.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R05.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R06.dat',
%     'day3\30052b_ud_im_t001\30052b_ud_im_tS001R07.dat',
%     'day4\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',
% };

baseDir = getSubjDir(subject);
eoff = 0;
for i=1:7
    file = GoodMotorFiles{i};
    fullFilePath = [baseDir file];

    [signal states parms] = load_bcidat(fullFilePath);

    montageFile = [fullFilePath(1:find(fullFilePath=='.',1,'last')-1) '_montage.mat'];
    try
        load(montageFile);
    catch
        error(sprintf('Couldn''t load montage for file %s.  Make sure you have run ScreenBadChannels.', montageFile));
    end

    %clean the States variable (make single precision instead of uint)
    for field = fields(states)';
        states.(field{:}) = single(states.(field{:}));
    end

    %clean the Parms variable (change to numerical value)
    flds = fieldnames(parms);
    for i=flds';
        try
            tempField = parms.(i{1});
        %         fprintf('%s ',tempField.Type);
            switch tempField.Type
                case 'string'
                    eval(sprintf('params.%s = tempField.Value;',i{1}));
                case 'matrix'
                    eval(sprintf('params.%s = tempField.Value;',i{1}));
                otherwise
                    numVal = double(tempField.NumericValue);
                    eval(sprintf('params.%s = numVal;',i{1}));
            end
        catch
            bad = cell2mat(i);
            fprintf('  ignoring params.%s, not numerical\n', bad);
        end
    end

    clear parms
    
    % determine control channel

    controlChannel = params.TransmitChList(str2double(params.Classifier{1,1}));
    
    fprintf('  -- Data recorded: %s\n', params.StorageTime{1});
    fprintf('  -- Control Channel: %i\n',controlChannel);

    %%%%% Clean signal 
%     fprintf('Cleaning signal\n');
    signal = double(signal);

    signal = NotchFilter(signal, [60 120 180], params.SamplingRate);

    if mod(params.SamplingRate,1000) == 0
%         fprintf('Neuroscan detected.  Re-referencing according to montage...\n');
        signal = ReferenceCAR(Montage.Montage, Montage.BadChannels, signal);
    else
%         fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
        signal = ReferenceCAR([16 16 16 16], Montage.BadChannels, signal);
    end
    
    %%%%% Band pass for chi range and get power
%     fprintf('Band passing\n');
    signalAmplitude = abs(hilbert(BandPassFilter(signal(:,controlChannel), [75 200], params.SamplingRate)));
    signalPower = signalAmplitude .^2;

    %%%%% Set up epochs 
    epochs = ones(length(find(diff(states.TargetCode)~= 0)),1);
    epochs(:,1) = cumsum(epochs(:,1));
    newEpochAt = find(diff(states.TargetCode) ~= 0);
    epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];

    feedbackStartAt = find(diff(states.Feedback) ~= 0);
    feedbacks = [feedbackStartAt(1:end-1)+1 feedbackStartAt(2:end)];
    % hack for Kai's UD
    if size(feedbacks,1) < size(epochs,1)
        epochs(end - (size(epochs,1) - size(feedbacks,1)) + 1:end,:) = [];
    elseif size(feedbacks,1) > size(epochs,1)
        feedbacks(end - (size(feedbacks,1) - size(epochs,1)) + 1:end,:) = [];
    end
    epochs(:,4:5) = feedbacks;
    epochs(:,6) = states.TargetCode(epochs(:,3));
    epochs(:,7) = states.ResultCode(epochs(:,3));

    % Since it takes into account a variable amount of previous samples, need
    % to sum over the previous X samples. NOTE: This might need to be
    % calculated prior to the band pass.  This is not explicitly how BCI2000
    % does it, but our analysis doesn't need to be exactly the same

    sumWindowLength = params.WindowLength * params.SamplingRate;
    convWindow = zeros(2*sumWindowLength,1);
    convWindow(sumWindowLength+1:end) = 1 / sumWindowLength;

%     fprintf('Meaning previous %i samples (%2.2fs) of signal amplitude...\n', sumWindowLength, params.WindowLength);
    sumSignalAmplitude = conv2(signalAmplitude,convWindow,'same');
%     fprintf('Meaning previous %i samples (%2.2fs) of signal power...\n', sumWindowLength, params.WindowLength);
    sumSignalPower = conv2(signalPower,convWindow,'same');

    meanAmplitudes = zeros(size(epochs,1),1);
    meanPowers = zeros(size(epochs,1),1);


    for epoch = epochs'
        meanAmplitudes(epoch(1)) = mean(sumSignalAmplitude(epoch(4):epoch(5)));
        meanPowers(epoch(1)) = mean(sumSignalPower(epoch(4):epoch(5)));
    end

%     subplot(2,1,1);
%     tc = 1; plot(epochs(epochs(:,6)==tc,1)+eoff,meanAmplitudes(epochs(:,6)==tc),'r.'); hold on;
%     tc = 2; plot(epochs(epochs(:,6)==tc,1)+eoff,meanAmplitudes(epochs(:,6)==tc),'b.'); hold on;
%     subplot(2,1,2);

    upEpochs = epochs(:,6)== 1 ;
    downEpochs = epochs(:,6) == 2;
    missedEpochs = epochs(:,6) ~= epochs(:,7);
    
    plot(epochs(upEpochs,1)+eoff,meanPowers(upEpochs),'r.'); hold on;
    plot(epochs(upEpochs & missedEpochs,1)+eoff,meanPowers(upEpochs & missedEpochs),'color','r','markersize',5,'marker','x','linestyle','none'); hold on;
    plot(epochs(downEpochs,1)+eoff,meanPowers(downEpochs),'b.'); hold on;
    plot(epochs(downEpochs & missedEpochs,1)+eoff,meanPowers(downEpochs & missedEpochs),'color','b','markersize',5,'marker','x','linestyle','none'); hold on;

    numTargs = sum(epochs(:,6) ~= 0);
    fprintf('Accuracy: %1.4f%%\n',sum(epochs(epochs(:,6) ~= 0,6)==epochs(epochs(:,6) ~= 0,7))/numTargs);
    
    eoff = eoff + size(epochs,1);
end

% % % % 
% % % % for asdf = fields(ff)'; 
% % % %     type = class(f.(asdf{1}));
% % % %     switch type
% % % %         case 'double'
% % % %             if f.(asdf{1}) ~= ff.(asdf{1}) 
% % % %                 fprintf('Diff: %s\n', asdf{1}); 
% % % %             end; 
% % % %         case 'cell'
% % % %             if length(f.(asdf{1})) == 0
% % % %                 continue;
% % % %             end
% % % %             if strcmp(f.(asdf{1}){1}, ff.(asdf{1}){1}) == 0
% % % %                 fprintf('Diff: %s\n', asdf{1}); 
% % % %             end; 
% % % %         otherwise
% % % %             fprintf('skipping %s, type %s\n', asdf{1}, type);
% % % %     end
% % % % end