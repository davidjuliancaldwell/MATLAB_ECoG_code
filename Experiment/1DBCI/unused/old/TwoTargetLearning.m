% targets = {'octb09_mot', 'octb09_im', 'hh_mot','hh_im','aprb10_im_t', 'aprb10_mot_t', 'aprb10_im_eyebrows', 'jc_mot','jt2_mot','juna09_mot','juna09_im','maya10_im','mg_im','deca10_mot'};
targets = {'juna09_im'};

compareCase = 'rest'; % 'rest' or 'down'

flag = 0;
for target = targets
    figure;
    target = target{:}; %#ok<FXSET>
    clear checkStorageTime bciType controlChannel forceControlChannel

    allUp = [];
    allDown = [];
    allCompared = [];
    
    switch(target)
        case 'octb09_mot'

            files = {
                'D:\research\subjects\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat',...
                'D:\research\subjects\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat',...
                'D:\research\subjects\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R03.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat',...
                'D:\research\subjects\fc9643\D4\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat'
            };
            checkStorageTime = 1;
            bciType = 'RJB';
%             forceControlChannel = 24;
        case 'octb09_im'
            files = {
                'D:\research\subjects\fc9643\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R02.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R04.dat',...
                'D:\research\subjects\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R05.dat',...
                'D:\research\subjects\fc9643\D4\fc9643_ud_im_t001\fc9643_ud_im_tS001R01.dat',...
                };
            checkStorageTime = 1;
            bciType = 'RJB';
            forceControlChannel = 29;
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
                'D:\research\subjects\30052b\D1\30052b_ud_im_t001\30052b_ud_im_tS001R02.dat',...
                'D:\research\subjects\30052b\D1\30052b_ud_im_t001\30052b_ud_im_tS001R03.dat',...
                'D:\research\subjects\30052b\D2\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',...
                'D:\research\subjects\30052b\D2\30052b_ud_im_t001\30052b_ud_im_tS001R03.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R02.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R04.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R05.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R06.dat',...
                'D:\research\subjects\30052b\D3\30052b_ud_im_t001\30052b_ud_im_tS001R07.dat',...
                'D:\research\subjects\30052b\D4\30052b_ud_im_t001\30052b_ud_im_tS001R01.dat',...
                };
            bciType = 'RJB';
            checkStorageTime = 1;
            forceControlChannel = 29;
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

    end

    prevDateNum = -1;
    prevControlChannel = -1;

    allEpochs = [];

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
%         signal = ReferenceCAR(Montage.Montage, Montage.BadChannels, signal);

        % Select only our control signal
        ccSignal = signal(:,controlChannel);

        % Band pass for control range
        fprintf(' Band passing...\n');
        ccAmp = abs(hilbert(BandPassFilter(ccSignal, [min(controlRange), max(controlRange)], params.SamplingRate, 6)));
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
        ccSumAmp = conv(ccAmp,convWindow,'same');

        % Segment based on epoch power

        for epoch = epochs'
            epochs(epoch(1),8) = mean(ccSumAmp(epoch(4):epoch(5)));
            epochs(epoch(1),9) = std(ccSumAmp(epoch(4):epoch(5)));
        end

        switch compareCase
            case 'rest'
                % Calculate Z-Score
                for epoch = epochs'
                    epochs(epoch(1),10) = (epoch(8) - mean(epochs(epochs(:,6)==0,8))) ./ mean(epochs(epochs(:,6)==0,9));
                end
%                 subplot(3,1,1);
                tc=1; colors = 'rb'; plot(offset + find(epochs(:,6)==tc), epochs(epochs(:,6)==tc,10),[colors(tc) '.']); hold on;
                tc=2; colors = 'rb'; plot(offset + find(epochs(:,6)==tc), epochs(epochs(:,6)==tc,10),[colors(tc) '.']); hold on;
                
                allUp = vertcat(allUp, [offset + find(epochs(:,6)==1) epochs(epochs(:,6)==1,10)]);
                allDown = vertcat(allDown, [offset + find(epochs(:,6)==2) epochs(epochs(:,6)==2,10)]);
                
                plot(offset + find(epochs(:,6)~=epochs(:,7)), epochs(epochs(:,6)~=epochs(:,7),10),'ks'); hold on;
                drawnow;
            case 'down'
                % Calculate Z-Score
                for epoch = epochs'
                    epochs(epoch(1),10) = (epoch(8) - mean(epochs(epochs(:,6)==2,8))) ./ mean(epochs(epochs(:,6)==2,9));
                end
                tc=1; colors = 'rb'; plot(offset + find(epochs(:,6)==tc), epochs(epochs(:,6)==tc,10),[colors(tc) '.']); hold on;
                allCompared = vertcat(allCompared,[offset + find(epochs(:,6)==1) epochs(epochs(:,6)==1,10)]);
            otherwise
                error('compareCase needs to be ''rest'' or ''down''\n');
        end
     
        
        offset = offset + size(epochs,1);
    end
    title(sprintf('%s - Control Channel %i', strrep(target,'_','\_'), controlChannel));
    axis tight;

    %%
    if isempty(allCompared)
%         subplot(3,1,1);
        hold on;
        if strcmp(target,'juna09_im')==1
            allUp(1,2) = 0;
        end
        f = GaussianSmooth(allUp(:,2),15);

        plot(allUp(:,1),f,'linewidth',2,'color','r');
        f = GaussianSmooth(allDown(:,2),15);
        plot(allDown(:,1),f,'linewidth',2,'color','b');
%         
%         subplot(3,1,2);
%         interpx = 1:0.1:max([allUp(:,1);allDown(:,1)]); 
%         f = GaussianSmooth(allUp(:,2),15);
%         interpYUp = interp1(allUp(:,1),f,interpx);
%         f = GaussianSmooth(allDown(:,2),15);
%         interpYDown = interp1(allDown(:,1),f,interpx);
%         
%         plot(interpx, interpYUp - interpYDown);
%         axis tight;
%         
%         subplot(3,1,3);
%         plot(interpx(1:end-1),diff(interpYUp - interpYDown));
%         hold on; 
%         plot(interpx(1:end-2),diff(GaussianSmooth(diff(interpYUp - interpYDown),20))*10,'r');
%         axis tight
    else
        f = GaussianSmooth(allCompared(:,2),15);
        plot(allCompared(:,1),f,'linewidth',2,'color','b');
    end
%     print('-dpsc2', '-noui', '-adobecset', '-painters', sprintf('d:\\Downloads\\Dropbox\\Thesis\\Papers\\TNSRE 2011\\figures\\raw matlab\\%s_withlines.eps',target));
end