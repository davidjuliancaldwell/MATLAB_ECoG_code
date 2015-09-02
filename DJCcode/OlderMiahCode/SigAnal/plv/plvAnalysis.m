function [plv, combinations] = plvAnalysis(sig, sta, par, srcSignals, interest, fts, fs, triggerOn, doPlots)
    data = sig(:,srcSignals);

    filterFilename = ['FIR_filters_' num2str(fs) 'Hz.mat'];
    
    if (exist(filterFilename, 'file'))
        fprintf('using predetermined FIR filters, should run much faster\n');
        load(filterFilename);
    else
        as = [];
        bs = [];
        filterFrequencies = [];
    end
    
    combinations = nchoosek(srcSignals, 2);    
    
    switch (triggerOn)
        case 'cue'
            [starts, ends] = getEpochs(sta.StimulusCode, interest);
            % ditch the epochs of variable length
            idxs = find((starts - ends) ~= mode(starts - ends));
            starts(idxs) = [];
            ends(idxs) = [];
        case 'finger'
            [starts, ch] = identifyGloveMotion(sta, par, 22, fs, [-0.5*fs 1.5*fs], [-0.5*fs 0], interest, 'onset', 0.2);
            starts(ch < 0) = [];
            ends = starts + 2*fs;
    end
    
    for idx = 1:length(fts)
        ft = fts(idx);
        fprintf('frequency %d\n', ft);
        
%         idx = find(fts == ft);

        if (sum(filterFrequencies == ft) > 0)
            % predetermined filter is available
            a = as(filterFrequencies == ft, :);
            b = bs(filterFrequencies == ft, :);
        else
            [a, b] = makeFIR(ft, 2, fs);
        end

        filteredData = zeros(size(data));

        for c  = 1:size(data, 2)
            filteredData(:,c) = filter(a, b, data(:,c));
        end; %clear c;

        waveletSigma = 7/ft;
        waveletT     = -waveletSigma:1/fs:waveletSigma;
%         waveletT     = -3*waveletSigma:1/fs:waveletSigma*3;
        wavelet      = exp(-waveletT.^2/(2*waveletSigma^2)).*exp(1i*2*pi*ft*waveletT);

%         curConvData = zeros(size(filteredData));
        convolvedData = zeros(size(filteredData));
        
        for c = 1:size(data, 2)
            temp = conv(wavelet, filteredData(:,c));
            convolvedData(:,c) = temp(length(wavelet):end);
        end; %clear c;

        instPhase = angle(convolvedData);

        phaseByEpoch = getEpochSignal(instPhase, starts, ends);

        curPlv = zeros(size(phaseByEpoch,1), size(combinations,1));
        
        for c = 1:size(combinations,1)
            fprintf('  combination %d\n', c);
%             trode1 = find(srcSignals == combinations(c,1));
%             trode2 = find(srcSignals == combinations(c,2));

            theta = squeeze(phaseByEpoch(:,srcSignals == combinations(c,1),:)) - ...
                squeeze(phaseByEpoch(:,srcSignals == combinations(c,2),:));
            etheta = exp(1i*theta);

%             plv(:,idx,c) = abs(sum(etheta, 2))/length(starts);
            curPlv(:,c) = abs(sum(etheta, 2))/length(starts);
        end; 
        
        plv(:,idx,:) = curPlv;

    end

    %% visualize

    if (doPlots == true)
        t = (1:size(plv,1))/fs;

        for c = 1:size(combinations, 1)
            figure;
            imagesc(t, fts, plv(:,:,c)', [0 1]);
            axis xy;
            colorbar;
            xlabel('time (s)');
            ylabel('frequency (Hz)');

            title(sprintf('PLV electrode %d to %d', combinations(c,1), combinations(c,2)));
        end
    end
end