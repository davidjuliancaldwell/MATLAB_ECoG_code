% targets = {'octb09_mot', 'octb09_im', 'hh_mot','hh_im','aprb10_im_t', 'aprb10_mot_t', 'aprb10_im_eyebrows', 'jc_mot','jt2_mot','juna09_mot','juna09_im','maya10_im','mg_im','deca10_mot'};
% targets = {'maya10_im','mg_im','deca10_mot'};
targets = {'octb09_im'};
% targets = {'hh_mot'};

compareCase = 'rest'; % 'rest' or 'down'

dataDir = myGetenv('subject_dir');

flag = 0;
for target = targets
%     figure;
    target = target{:}; %#ok<FXSET>
    clear checkStorageTime bciType controlChannel forceControlChannel

    allUp = [];
    allDown = [];
    allCompared = [];
    
    clear stages;
    
    switch(target)
        case 'octb09_mot'

            files = {
                [dataDir '\fc9643\data\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat'],...
                [dataDir '\fc9643\data\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat'],...
                [dataDir '\fc9643\data\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R03.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat'],...
                [dataDir '\fc9643\data\D4\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat']
            };
%             files = {
%                 [dataDir 'octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R01.dat'],...
%                 [dataDir 'octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.dat'],...
%                 [dataDir 'octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R03.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R01.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.dat'],...
%                 [dataDir 'octb09\D4\octb09_ud_mot_t001\octb09_ud_mot_tS001R01.dat']
%             };
            checkStorageTime = 1;
            bciType = 'RJB';
            forceControlChannel = 24;
            stages = [1 68; 69 126; 127 210];
        case 'octb09_im'
            files = {
                [dataDir '\fc9643\data\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R02.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R04.dat'],...
                [dataDir '\fc9643\data\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R05.dat'],...
                [dataDir '\fc9643\data\D4\fc9643_ud_im_t001\fc9643_ud_im_tS001R01.dat'],...
                };
%             files = {
%                 [dataDir 'octb09\D2\octb09_ud_im_t001\octb09_ud_im_tS001R03.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_im_t001\octb09_ud_im_tS001R02.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_im_t001\octb09_ud_im_tS001R03.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_im_t001\octb09_ud_im_tS001R04.dat'],...
%                 [dataDir 'octb09\D3\octb09_ud_im_t001\octb09_ud_im_tS001R05.dat'],...
%                 [dataDir 'octb09\D4\octb09_ud_im_t001\octb09_ud_im_tS001R01.dat'],...
%                 };            
            checkStorageTime = 1;
            bciType = 'RJB';
            forceControlChannel = 24;
            stages = [1 68; 69 126; 127 210];
            
        case 'hh_mot'
            files = {
                'd:\Research\Data\bci\hh_mot\D1\hh_ud_mot_tongueS001R04.dat',...
                'd:\Research\Data\bci\hh_mot\D1\hh_ud_mot_tongueS001R05.dat',...
                'd:\Research\Data\bci\hh_mot\D2\hh_ud_mot_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_mot\D3\hh_ud_mot_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_mot\D4\hh_ud_mot_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_mot\D5\hh_ud_mot_tongueS001R01.dat'
            };
            checkStorageTime = 0;
            bciType = 'ud';
            controlChannel = 43;
            controlRange = [80:98];
            % Stage1: 1-61 stage2: 62:321 stage3:322-534
            stages = [1 61; 62 321; 322 534];
        case 'aprb10_im_t'
            files = {
                'd:\Research\Data\bci\aprb10_im_t\D1\aprb10_ud_im_tS001R02.dat',...
                'd:\Research\Data\bci\aprb10_im_t\D1\aprb10_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\aprb10_im_t\D1\aprb10_ud_im_tS001R06.dat',...
                'd:\Research\Data\bci\aprb10_im_t\D1\aprb10_ud_im_tS001R07.dat',...
                'd:\Research\Data\bci\aprb10_im_t\D2\aprb10_ud_im_tS001R01.dat',...
                'd:\Research\Data\bci\aprb10_im_t\D2\aprb10_ud_im_tS001R02.dat',... % Why not this one? 
                };
            checkStorageTime = 1;
            bciType = 'RJB';
            forceControlChannel = 55;
            
        case 'aprb10_mot_t'
            files = {
                'd:\Research\Data\bci\aprb10_mot_t\D1\aprb10_ud_mot_tS001R01.dat',...
                'd:\Research\Data\bci\aprb10_mot_t\D1\aprb10_ud_mot_tS001R04.dat',...
                'd:\Research\Data\bci\aprb10_mot_t\D1\aprb10_ud_mot_tS001R05.dat',...
                'd:\Research\Data\bci\aprb10_mot_t\D2\aprb10_ud_mot_tS001R01.dat',...
                'd:\Research\Data\bci\aprb10_mot_t\D2\aprb10_ud_mot_tS001R02.dat',...
                'd:\Research\Data\bci\aprb10_mot_t\D2\aprb10_ud_mot_tS001R03.dat',...
                };
            checkStorageTime = 1;
            bciType = 'RJB';
            forceControlChannel = 56;
            stages = [1 40; 41 120; 121 208];
        case 'aprb10_im_eyebrows'
            % FAILED
            files = {
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R01.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R02.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R03.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R04.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R05.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R06.dat',...
                'd:\Research\Data\bci\aprb10_im_eyebrow\D2\aprb10_ud_im_eyebrowsS001R07.dat',...
                };
            checkStorageTime = 1;
            bciType = 'RJB';
        case 'hh_im'
            files = {
                'd:\Research\Data\bci\hh_im\D1\hh_ud_im_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_im\D1\hh_ud_im_tongueS001R02.dat',...
                'd:\Research\Data\bci\hh_im\D1\hh_ud_im_tongueS001R03.dat',...
                'd:\Research\Data\bci\hh_im\D2\hh_ud_im_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_im\D2\hh_ud_im_tongueS001R02.dat',...
                'd:\Research\Data\bci\hh_im\D3\hh_ud_im_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_im\D3\hh_ud_im_tongueS001R02.dat',...
                'd:\Research\Data\bci\hh_im\D3\hh_ud_im_tongueS001R03.dat',...
                'd:\Research\Data\bci\hh_im\D4\hh_ud_im_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_im\D4\hh_ud_im_tongueS001R02.dat',...
                'd:\Research\Data\bci\hh_im\D4\hh_ud_im_tongueS001R03.dat',...
                'd:\Research\Data\bci\hh_im\D4\hh_ud_im_tongueS001R04.dat',...
                'd:\Research\Data\bci\hh_im\D4\hh_ud_im_tongueS001R05.dat',...
                'd:\Research\Data\bci\hh_im\D5\hh_ud_im_tongueS001R01.dat',...
                'd:\Research\Data\bci\hh_im\D5\hh_ud_im_tongueS001R02.dat',...
                'd:\Research\Data\bci\hh_im\D5\hh_ud_im_tongueS001R03.dat',...
                'd:\Research\Data\bci\hh_im\D5\hh_ud_im_tongueS001R04.dat',...
                };
            checkStorageTime = 0;
            bciType = 'ud';
            controlChannel = 43;
            controlRange = [80:98];
        case 'jc_mot'
            files = {
                'd:\Research\Data\bci\jc_mot\D1S1\jc_ud_tongue-bS001R01.dat',...
                'd:\Research\Data\bci\jc_mot\D1S1\jc_ud_tongue-bS001R02.dat',...
                'd:\Research\Data\bci\jc_mot\D1S1\jc_ud_tongue-bS001R03.dat',...
                'd:\Research\Data\bci\jc_mot\D1S2\jc_ud_tongue-cS001R01.dat',...
                'd:\Research\Data\bci\jc_mot\D2\jc_ud_tongue-dS001R02.dat',...
            };
            checkStorageTime = 0;
            bciType = 'ud';
            controlChannel = 13;
            controlRange = [80:98];
            stages = [1 100; 101 289; 290 346];
        case 'jt2_mot'
            files = {
                'd:\Research\Data\bci\jt2_mot\D1\jt2_ud_tongue-aS001R01.dat',...
                'd:\Research\Data\bci\jt2_mot\D1\jt2_ud_tongue-aS001R02.dat',...
                'd:\Research\Data\bci\jt2_mot\D1\jt2_ud_tongue-aS001R03.dat',...
                'd:\Research\Data\bci\jt2_mot\D1S2\jt2_ud_tongue-dS001R01.dat',...
                };
            checkStorageTime = 0;
            bciType = 'ud';
            controlChannel = 64;
            controlRange = [80:86];
            stages = [1 90; 91 170; 171 251];
        case 'deca10_mot'
            files = {
                'd:\Research\Data\bci\deca10_mot\D1\deca10_ud_mot_hS001R01.dat',...
                'd:\Research\Data\bci\deca10_mot\D1\deca10_ud_mot_hS001R03.dat',...
                'd:\Research\Data\bci\deca10_mot\D2\deca10_ud_mot_hS001R02.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
        case 'deca10_im'
            files = {
                'd:\Research\Data\bci\deca10_im\D1\deca10_ud_im_hS001R02.dat',...
                'd:\Research\Data\bci\deca10_im\D1\deca10_ud_im_hS001R03.dat',...
                'd:\Research\Data\bci\deca10_im\D1\deca10_ud_im_hS001R04.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
        case 'juna09_mot'
            files = {
                'd:\Research\Data\bci\juna09_mot\D1\30052b_ud_mot_tS001R02.dat',...
                'd:\Research\Data\bci\juna09_mot\D1\30052b_ud_mot_tS001R03.dat',...
                'd:\Research\Data\bci\juna09_mot\D1\30052b_ud_mot_tS001R04.dat',...
                'd:\Research\Data\bci\juna09_mot\D1\30052b_ud_mot_tS001R05.dat',...
                'd:\Research\Data\bci\juna09_mot\D2\30052b_ud_mot_tS001R01.dat',...
                'd:\Research\Data\bci\juna09_mot\D2\30052b_ud_mot_tS001R02.dat',...
%                 'd:\Research\Data\bci\juna09_mot\D2\30052b_ud_mot_tS001R03.dat',...
%                 'd:\Research\Data\bci\juna09_mot\D2\30052b_ud_mot_tS001R04.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
        case 'juna09_im'
            files = {
                'd:\Research\Data\bci\juna09_im\D1\30052b_ud_im_tS001R02.dat',...
                'd:\Research\Data\bci\juna09_im\D1\30052b_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\juna09_im\D2\30052b_ud_im_tS001R01.dat',...
                'd:\Research\Data\bci\juna09_im\D2\30052b_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R01.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R02.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R04.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R05.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R06.dat',...
                'd:\Research\Data\bci\juna09_im\D3\30052b_ud_im_tS001R07.dat',...
                'd:\Research\Data\bci\juna09_im\D4\30052b_ud_im_tS001R01.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
            forceControlChannel = 29;
            stages = [1 58; 59 170; 171 390];
        case 'maya10_im'
            files = {
                'd:\Research\Data\bci\maya10_im\D2\26cb98_ud_im_tS001R01.dat',...
                'd:\Research\Data\bci\maya10_im\D2\26cb98_ud_im_tS001R02.dat',...
                'd:\Research\Data\bci\maya10_im\D2\26cb98_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\maya10_im\D2S2\26cb98_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\maya10_im\D2S2\26cb98_ud_im_tS001R04.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
            stages = [1 38; 39 94; 95 177];
        case 'mg_im'
            files = {
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R01.dat',...
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R02.dat',...
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R03.dat',...
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R04.dat',...
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R05.dat',...
                'd:\Research\Data\bci\mg_im\D2\mg_ud_im_tS001R06.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
            stages = [1 100; 101 162; 163 210];

    end
    
    fprintf('Stages: ');
    fprintf('%i ',stages);
    fprintf('\n');

    prevDateNum = -1;
    prevControlChannel = -1;

    allEpochs = [];
    allZScores = [];

    offset = 0;

    for file = files
        file = file{:};
        [signal states params] = load_bcidat(file);
        signal = double(signal);

        for field = fields(states)';
            states.(field{:}) = single(states.(field{:}));
        end

        params = CleanBCI2000ParamStruct(params);

        fprintf('-----\n');
        fprintf(' File: %s\n', file);

        % Check to make sure the files were recorded in the correct order
        if checkStorageTime == 1
            fprintf(' Storage Time: %s\n', params.StorageTime{1});
            dn = datenum(params.StorageTime{1}(4:end));
            fprintf(' Datenum: %f\n', dn);
            if dn < prevDateNum
                error('Date goes backwards!!\n File %s is out of order', file);
            end
            prevDateNum = dn;
        end

        switch bciType
            case 'RJB'

                controlChannels = str2double(params.Classifier);
                controlChannel = params.TransmitChList(controlChannels(:,1));
                if length(unique(controlChannel)) > 1
                    error ('Multiple channels detected! %i', controlChannel)
                end
                clear controlChannels
                controlChannel = unique(controlChannel);

                if exist('forceControlChannel')
                    fprintf('FORCING Control channel to %i\n', forceControlChannel);
                    controlChannel = forceControlChannel;
                end

                if prevControlChannel == -1
                    prevControlChannel = controlChannel;
                end

                if prevControlChannel ~= controlChannel
                    fprintf('WARNING: Different control channel %i for file %s\n', controlChannel, file);
                end

                lowRange = params.FirstBinCenter - params.BinWidth / 2;
                controlRange = [];
                for i=1:size(params.Classifier,1)
                    bin = str2double(params.Classifier{i,2});
                    controlRange = [controlRange (lowRange:lowRange+params.BinWidth) + (bin-1)*params.BinWidth];
                end
                windowLength = params.WindowLength;
            case 'ud'
                windowLength = 0.5;
        end
        fprintf(' Control channel: %i\n', controlChannel);
        fprintf(' Control range: [%f-%f] Hz\n', min(controlRange), max(controlRange));

        % Notch filter and CAR data
        load([file(1:end-4) '_montage.mat']);
        fprintf(' Notching...\n');
        signal = NotchFilter(signal, [60 120 180], params.SamplingRate);
%         fprintf(' CAR referencing...\n');
        signal = ReferenceCAR(Montage.Montage, Montage.BadChannels, signal);

        % Select only our control signal
%         ccSignal = signal(:,controlChannel);

        % Band pass for control range
        fprintf(' Band passing...\n');
         
        ccAmp = abs(hilbert(BandPassFilter(signal, [75 150], params.SamplingRate, 6)));
    %     ccAmp = ccAmp .^2;

        % Set up epochs
        epochs = ones(length(find(diff(states.TargetCode)~= 0)),1);
        epochs(:,1) = cumsum(epochs(:,1));
        newEpochAt = find(diff(states.TargetCode) ~= 0);
        epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];

        feedbackStartAt = find(diff(states.Feedback) ~= 0);
        feedbacks = [feedbackStartAt(1:end-1)+1 feedbackStartAt(2:end)];

        switch bciType
            case 'ud'
                % hack for Kai's UD
                if size(feedbacks,1) < size(epochs,1)
                    epochs(end - (size(epochs,1) - size(feedbacks,1)) + 1:end,:) = [];
                elseif size(feedbacks,1) > size(epochs,1)
                    feedbacks(end - (size(feedbacks,1) - size(epochs,1)) + 1:end,:) = [];
                end
        end
        epochs(:,4:5) = feedbacks;
        epochs(:,6) = states.TargetCode(epochs(:,3));
        epochs(:,7) = states.ResultCode(epochs(:,3));
        epochs(epochs(:,6) == 0,4:5) = epochs(epochs(:,6) == 0,2:3);

        % Sum up previous X ms of data
        sumWindowLength = windowLength * params.SamplingRate;
        convWindow = zeros(2*sumWindowLength,1);
        convWindow(sumWindowLength+1:end) = 1 / sumWindowLength;

        fprintf(' Summing previous %i samples...\n', sumWindowLength);
        ccSumAmp = conv2(ccAmp,convWindow,'same');
        
        allChanEpochMeans = zeros(size(epochs,1),size(signal,2));
        allChanEpochStds = zeros(size(epochs,1),size(signal,2));
        allChanEpochZScores = zeros(size(epochs,1),size(signal,2));
        
        fprintf(' Calculating mean/std power for all epochs for all channels...\n')
        for chan=1:size(signal,2)
            for epoch = epochs'
                allChanEpochMeans(epoch(1),chan) = mean(ccSumAmp(epoch(4):epoch(5),chan));
                allChanEpochStds(epoch(1),chan) = std(ccSumAmp(epoch(4):epoch(5),chan));
            end
        end
        
        restMean = mean(allChanEpochMeans(epochs(:,6)==0,:),1);
        restStd = std(allChanEpochMeans(epochs(:,6)==0,:),1);
        
        allChanEpochZScores = bsxfun(@minus, allChanEpochMeans, restMean);
        allChanEpochZScores = bsxfun(@rdivide, allChanEpochZScores, restStd);
        
        allEpochs = [allEpochs; epochs];
        allZScores = [allZScores; allChanEpochZScores];
    end
    
mkdir(sprintf('%s\\RemoteLearning', myGetenv('output_dir')));
save(sprintf('%s\\RemoteLearning\\%s.mat', myGetenv('output_dir'), target), ...
    'allEpochs', 'allZScores', 'stages');
    
% [a b c] = eval(sprintf('mkdir(''d:\\research\\output\\RemoteLearning\\'');'));
% eval(sprintf('save d:\\research\\output\\RemoteLearning\\%s.mat allEpochs allZScores stages', target));
end

%% jdw add
fbs = allEpochs(allEpochs(:,6) ~= 0, :);
fbzs = allZScores(allEpochs(:,6) ~= 0, :);

ups = fbzs(fbs(:,6)==1,24);
upls = find(fbs(:,6)==1);

dns = fbzs(fbs(:,6)==2,24);
dnls = find(fbs(:,6)==2);

plot(upls, ups, 'r.','markersize',10);
hold on;
plot(dnls, dns, 'b.','markersize',10);
plot(upls, mSmooth(ups, 20), 'r-', 'linewidth', 2);
plot(dnls, mSmooth(dns, 20), 'b-', 'linewidth', 2);
hold off;

return
%%
allEpochs(:,1) = cumsum(ones(length(allEpochs),1));
colors = [1 0 0; 0 1 0; 0 0 1];
stageIdx = 1;
for stage = stages'
    stageEpochs = allEpochs(allEpochs(:,1) <= stage(2) & allEpochs(:,1) >= stage(1),:);
    stageZScore = allZScores(stageEpochs(:,1),:);
    up = stageEpochs(:,6) == 1;
    down = stageEpochs(:,6) == 2;
    
    numChans = size(allZScores,2);
    numRows = ceil(numChans / 8);

    for chan=1:numChans
        upValue = mean(stageZScore(up,chan));
        downValue = mean(stageZScore(down,chan));
        subplot(numRows,8,chan);
        patch([stageIdx-.25 stageIdx-.25 stageIdx+.25 stageIdx+.25]-.125, [0 upValue upValue 0],colors(stageIdx,:));
        hold on;
        patch([stageIdx-.25 stageIdx-.25 stageIdx+.25 stageIdx+.25]+.125, [0 downValue downValue 0],[.2 .2 .2]);
        
        
    end
    stageIdx = stageIdx + 1;
%     stageEpochs
end

absYLim = [];
for chan=1:numChans
    subplot(numRows,8,chan);
    subYLim = get(gca,'ylim');
    if isempty(absYLim)
        absYLim = subYLim;
    else
        if sum(abs(subYLim) > abs(absYLim)) > 0
            absYLim = subYLim;
        end
    end
end

for chan=1:numChans
    subplot(numRows,8,chan);
    set(gca,'ylim',[-max(abs(absYLim)) max(abs(absYLim))]);
end