% targets = {'octb09', 'deca10'};
targets = {'octb09_5targ'};

for target = targets
    figure;
    target = target{:}; %#ok<FXSET>
    clear checkStorageTime bciType controlChannel forceControlChannel
    
    switch(target)
        case 'octb09_3targ'

            files = {
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R02.dat',...
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R03.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4\octb09_ud_mot_t_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4\octb09_ud_mot_t_3targS001R02.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4S2\octb09_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4S2\octb09_3targS001R02.dat',...
            };
            checkStorageTime = 1;
        case 'octb09_5targ'

            files = {
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R01.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R02.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R03.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R04.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R06.dat',...
            };
            checkStorageTime = 1;
        case 'octb09_alltarg'
            files = {
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R02.dat',...
                'C:\Research\Data\bci\octb09_3targ\D3\octb09_ud_3targS001R03.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4\octb09_ud_mot_t_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4\octb09_ud_mot_t_3targS001R02.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4S2\octb09_3targS001R01.dat',...
                'C:\Research\Data\bci\octb09_3targ\D4S2\octb09_3targS001R02.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R01.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R02.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R03.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R04.dat',...
                'C:\Research\Data\bci\octb09_5targ\D4S2\octb09_5targS001R06.dat',....
%                 'C:\Research\Data\bci\octb09_3targ\D5\octb09_3targS001R03.dat',...
%                 'C:\Research\Data\bci\octb09_3targ\D5\octb09_3targS001R04
%                 .dat',...
%                 'C:\Research\Data\bci\octb09_5targ\D5\octb09_5targS001R01.dat',...
%                 'C:\Research\Data\bci\octb09_5targ\D5\octb09_5targS001R02.dat',...
                };
                checkStorageTime = 1;
        case 'deca10_alltarg'
            files = {
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_3targS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_5targS001R01.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_5targS001R03.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_6targS001R03.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D2\38e116_3targ_imS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D2\38e116_6targ_imS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_3targS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_6targS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_7targS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_5targS001R04.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_7targS001R03.dat',...
                
            };
            checkStorageTime = 1;
            
        case 'deca10_3targ'
            files = {
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_3targS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D2\38e116_3targ_imS001R02.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_3targS001R02.dat',...                
            };
            checkStorageTime = 1;
            
        case 'deca10_5targ'
            files = {
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_5targS001R01.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D1\38e116_5targS001R03.dat',...
                'C:\Research\Data\bci\deca10_multitarg\D3\38e116_5targS001R04.dat',...
                
            };
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
%         fprintf('HACK! Changing to broad-band!\n');
%         ccAmp = abs(hilbert(BandPassFilter(ccSignal, [75 200], params.SamplingRate, 6)));
    %     ccAmp = ccAmp .^2;

        % Set up epochs
        epochs = ones(length(find(diff(states.TargetCode)~= 0)),1);
        epochs(:,1) = cumsum(epochs(:,1));
        newEpochAt = find(diff(states.TargetCode) ~= 0);
        epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];

        feedbackStartAt = find(diff(states.Feedback) ~= 0);
        feedbacks = [feedbackStartAt(1:end-1)+1 feedbackStartAt(2:end)];
%%
        if size(feedbacks,1) == size(epochs,1)-1
            epochs(end,:) = [];
        end
        epochs(:,4:5) = feedbacks;
        epochs(:,6) = states.TargetCode(epochs(:,3));
        epochs(:,7) = states.ResultCode(epochs(:,3));
        epochs(epochs(:,6) == 0,4:5) = epochs(epochs(:,6) == 0,2:3);
        
        fprintf(' Accuracy: %3.2f%% - (%i/%i)\n', 100* sum(epochs(epochs(:,6) ~= 0,6) == epochs(epochs(:,6) ~= 0,7)) / size(epochs(epochs(:,6) ~= 0),1), sum(epochs(epochs(:,6) ~= 0,6) == epochs(epochs(:,6) ~= 0,7)), size(epochs(epochs(:,6) ~= 0),1));

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

       
        % Calculate Z-Score
        for epoch = epochs'
            epochs(epoch(1),10) = (epoch(8) - mean(epochs(epochs(:,6)==0,8))) ./ mean(epochs(epochs(:,6)==0,9));
        end
        
        switch length(setdiff(unique(epochs(:,6)),0))
            case 3
                colors = 'rgb';
            case 4
                colors = 'rgyb';
            case 5
                colors = 'rcgmb';
            case 6
                colors = 'rckgmb';
            case 7
                colors = 'rckgymb';
        end
%         colors = 'rcgkb';
%         colors = 'rgb';
      %%  
        eoffset = offset;
        for tc = setdiff(unique(epochs(:,6)),0)'
            subplot(3,1,1);
            hold on;
            plot(offset + find(epochs(:,6)==tc), epochs(epochs(:,6)==tc,10),[colors(tc) '.']); hold on;
            subplot(3,1,2);
            hold on;
            xVal = offset + size(epochs,1)/2;
            meanVal = mean(epochs(epochs(:,6)==tc,10));
            plot(xVal+tc, meanVal,[colors(tc) 's']);
            stdVal = std(epochs(epochs(:,6)==tc,10));
            plot([xVal-1 xVal+1] + tc, meanVal + [-1 1] .* stdVal, colors(tc));
            subplot(3,1,3);
            hold on;
            numTargs = size(find(epochs(:,6)==tc),1);
            plot(eoffset + [1:numTargs], epochs(epochs(:,6)==tc,10), [colors(tc) '.']);
            eoffset = eoffset + numTargs;
        end

        offset = offset + size(epochs,1);
        set(gca,'xlim',[0 offset]);
    end
    title(sprintf('%s - Control Channel %i', strrep(target,'_','\_'), controlChannel));
    axis tight;
    set(gca,'xlim',[0 offset]);

    %%
%     if isempty(allCompared)
%         subplot(2,1,1);
%         hold on;
%         f = GaussianSmooth(allUp(:,2),15);
%         plot(allUp(:,1),f,'linewidth',2,'color','r');
%         f = GaussianSmooth(allDown(:,2),15);
%         plot(allDown(:,1),f,'linewidth',2,'color','b');
%         
%         subplot(2,1,2);
%         interpx = 1:0.1:max([allUp(:,1);allDown(:,1)]); 
%         f = GaussianSmooth(allUp(:,2),15);
%         interpYUp = interp1(allUp(:,1),f,interpx);
%         f = GaussianSmooth(allDown(:,2),15);
%         interpYDown = interp1(allDown(:,1),f,interpx);
%         
%         plot(interpx, interpYUp - interpYDown);
%         axis tight;
%     else
%         f = GaussianSmooth(allCompared(:,2),15);
%         plot(allCompared(:,1),f,'linewidth',2,'color','b');
%     end
%     print('-djpeg', sprintf('C:\\Downloads\\Dropbox\\Thesis\\Papers\\TNSRE 2011\\figures\\raw matlab\\JeffProofs\\%s.jpg',target));
end