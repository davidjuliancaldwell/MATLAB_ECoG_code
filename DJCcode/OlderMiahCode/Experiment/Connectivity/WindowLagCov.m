useGPU = 0;

% [signal states params] = load_bcidat('C:\Research\Data\Connectivity\octb09_mot_t_hS001R01.dat');
% [signal states params] = load_bcidat('D:\Research\Data\Patients\0dd118\d5\0dd118_finger_twister001\0dd118_finger_twisterS001R03');
[signal states params] = load_bcidat('D:\Research\Data\Patients\38e116\d1\38e116_fingerflex_L001\38e116_fingerflex_LS001R02');
signal = double(signal(:,1:64));
for field = fields(states)';
    states.(field{:}) = single(states.(field{:}));
end
params = CleanBCI2000ParamStruct(params);

signal = NotchFilter(signal, [60 120 180], params.SamplingRate);


signal = ReferenceCAR([16 16 16 16 ],[4],signal);

bp = BandPassFilter(signal,[75 200], params.SamplingRate);

if useGPU
    sigAmp = gdouble(abs(hilbert(bp)));
else
    sigAmp = abs(hilbert(bp));
end

windowSize = 300; % samples

prePostLag = 400; % samples

samplesToSkip = 50;

valueIndices = ones(prePostLag*2+1, windowSize+1);
valueIndices(:,1) = cumsum(valueIndices(:,1));
valueIndices = cumsum(valueIndices,2)';

% 
% srcChan = 17;
% destChan = 18;
% for srcChan = [17 18 19 20 25 26 27 28 1:16 21:24 29:64]
for srcChan = 54:-1:1
    outputDir = sprintf('%s\\WindowLagCov\\srcChan %03i\\', getenv('output_dir'), srcChan);
    [a b c] = mkdir(outputDir);
   
    x = sigAmp(:,srcChan);
    
    destChans = setdiff(1:64,srcChan);
    
%     parfor destChan = 55
    for destChan = destChans
        fprintf('SrcChan(%2i) DestChan(%2i)...\n',srcChan, destChan);
    %     x = gdouble(sigAmp(:,srcChan));
    %     y = gdouble(sigAmp(:,destChan));
        
        y = sigAmp(:,destChan);

        slidingWindowBegin = windowSize/2+1;%+prePostLag;
        slidingWindowEnd = length(x) - windowSize/2-1;%-prePostLag;

        numWindows = length(slidingWindowBegin:samplesToSkip:slidingWindowEnd);

        if useGPU
            out = gdouble(zeros(numWindows,prePostLag*2+1));
        else
            out = zeros(numWindows,prePostLag*2+1);
        end
        tic

        for outIdx = 1:numWindows
            values = ones(size(valueIndices,1),size(valueIndices,2)+1); 
            currentSample = slidingWindowBegin + (outIdx-1) * samplesToSkip;

            sourceSampleCenteredWindow = (currentSample-windowSize/2):(currentSample+windowSize/2);

            destSampleCenteredRange = (currentSample - windowSize/2 - prePostLag):(currentSample + windowSize/2 + prePostLag);
            destSampleCenteredRange(destSampleCenteredRange < 1) = 1;
            destSampleCenteredRange(destSampleCenteredRange > length(x)) = length(x);
            ySample = y(destSampleCenteredRange);
            values(:,2:end) = ySample(valueIndices);
            values(:,1) = x(sourceSampleCenteredWindow);
            f = cov(values);

            
            
%             if useGPU
%                 idx = gdouble(1);
%                 indices = gdouble(ones(windowSize + 1,prePostLag * 2 + 1));
%             else
%                 idx = 1;
%                 indices = ones(windowSize + 1,prePostLag * 2 + 1);
%             end
%             indices = ones(windowSize + 1,prePostLag * 2 + 1);
%             indices(:,1) = sourceSampleCenteredWindow - prePostLag;
%             indices = cumsum(indices,2);
%             indices(indices<1) = 1;
%             indices(indices>length(x)) = length(x);
%             values = y(indices');
            

%             f = corrcoef([x(sourceSampleCenteredWindow) values']);
%             f = cov([x(sourceSampleCenteredWindow) values]);
            
            out(outIdx,:) = f(2:end,1);
        %     outIdx = outIdx + 1;
        end
        toc

        %% Glove testing
        figure;
        
        secondsBefore = -0.25; % seconds
        secondsAfter = .25; % seconds
        
        subplot(1,7,1);
%         restEpochs = getEpochs(states.StimulusCode,1);
        
        
        
        
        maxClim = -1;
        for stimCode = 2:7

            subplot(1,7,stimCode);

%             gloveFlexs = identifyGloveMotion(states,params,22,1200,[-600 2400], [-600 0], stimCode, 'allpeaks',1);
            gloveFlexs = GetPeakCurl(states,params,stimCode);


            
            periodBefore = abs(round(secondsBefore / (samplesToSkip / params.SamplingRate)));
            periodAfter = abs(round(secondsAfter / (samplesToSkip / params.SamplingRate)));

            gloveFlexs = round(gloveFlexs/samplesToSkip);

            averageCov = zeros(periodBefore + periodAfter, prePostLag*2+1);



            numValidFlexs = 0;
            for sc = gloveFlexs'
                try
                    averageCov = averageCov + out(sc-periodBefore:sc+periodAfter-1,:);
                    numValidFlexs = numValidFlexs + 1;
                catch
                end
            end

            averageCov = averageCov ./ numValidFlexs;

%             figure;
            if useGPU
                imagesc([secondsBefore:.1:secondsAfter],[-prePostLag:prePostLag],double(averageCov)'); title(sprintf('StimulusCode %i',stimCode));
            else
                imagesc([secondsBefore:.1:secondsAfter],[-prePostLag:prePostLag],averageCov'); title(sprintf('StimulusCode %i',stimCode));
            end
            hold on;
            plot([0 0], [prePostLag] * [-1 1],'k:');
            maxClim = max(maxClim,max(abs(get(gca,'clim'))));

        end
        %%
        for stimCode = [1:7]
            subplot(1,7,stimCode);

            set(gca,'clim',[-maxClim maxClim]);
            set_colormap_threshold(gca, [-maxClim maxClim]*.2, [-maxClim maxClim], [1 1 1]);
            if stimCode==2
    %             colorbar;
            end
        end

        saveas(gcf,sprintf('%schan%02i-chan%02i.fig',outputDir,srcChan,destChan));
        close(gcf);
    end
end
