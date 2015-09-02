% [signal states params] = load_bcidat('C:\Research\Data\Connectivity\octb09_mot_t_hS001R01.dat');
[signal states params] = load_bcidat('D:\Research\Data\Patients\0dd118\d5\0dd118_finger_twister001\0dd118_finger_twisterS001R03');

fprintf('Preparing data \n');
fprintf(' [Loading BCI]');
[signal states params] = load_bcidat('D:\Research\Data\Patients\38e116\d1\38e116_fingerflex_L001\38e116_fingerflex_LS001R02');

fprintf(' [Downsampling to Grid]');
signal = double(signal(:,1:64));

fprintf(' [Fixing States]');
for field = fields(states)';
    states.(field{:}) = single(states.(field{:}));
end
fprintf(' [Cleaning Params]');
params = CleanBCI2000ParamStruct(params);

fprintf(' [Notch]');
signal = NotchFilter(signal, [60 120 180], params.SamplingRate);

fprintf(' [CAR]');
signal = ReferenceCAR([16 16 16 16 ],[],signal);

fprintf(' [HG Band pass]');
bp = BandPassFilter(signal,[75 200], params.SamplingRate);

fprintf(' [Hilb Amp]');
sigAmp = abs(hilbert(bp));
fprintf(' done\n');
%%
windowSize = 300; % samples
prePostLag = 200; % samples

downsamplePicturesBy = 2;

fprintf('Calculating glove flexs');
    allGloveFlexs = {};
    for sc = 1:7
        fprintf(' [%i]', sc);
        allGloveFlexs{end+1} = GetPeakCurl(states,params,sc);
    end
fprintf(' done\n');

for srcChan = 1:64
    outputDir = sprintf('%s\\fingerflex\\srcChan %03i\\', getenv('output_dir'), srcChan);
    [a b c] = mkdir(outputDir);
   
    x = single(sigAmp(:,srcChan));
    
    destChans = setdiff(32:64,srcChan);
%     destChans = 57;
    tic    
    for destChan = destChans
        fprintf('SrcChan(%2i) DestChan(%2i) - ',srcChan, destChan);
        
        y = single(sigAmp(:,destChan));

        
        fprintf(' [Processing]');
        out = CudaMex_v2(x,y,windowSize, prePostLag);

        %% Glove testing
        figure;
        
        secondsBefore = 0.5; % seconds
        secondsAfter = 0.5; % seconds
        
        subplot(1,7,1);
%         restEpochs = getEpochs(states.StimulusCode,1);
        
        
        
        fprintf(' [Segmenting]');
        maxClim = -1;
        for stimCode = 2:7

            gloveFlexs = allGloveFlexs{stimCode};
           
            subplot(1,7,stimCode);

            
  
            periodBefore = round(params.SamplingRate * secondsBefore);
            periodAfter = round(params.SamplingRate * secondsAfter);

            averageCov = zeros(prePostLag*2+1,periodBefore + periodAfter);

            numValidFlexs = 0;
            for sc = gloveFlexs'
                try
                    averageCov = averageCov + out(:,sc-periodBefore:sc+periodAfter-1);
                    numValidFlexs = numValidFlexs + 1;
                catch
                    %fprintf('ERROR\n');
                end
            end

            averageCov = averageCov ./ numValidFlexs;


            imagesc([-secondsBefore:.1:secondsAfter],[-prePostLag:prePostLag],averageCov(:,1:downsamplePicturesBy:end)); title(sprintf('StimulusCode %i',stimCode));

            hold on;
            plot([0 0], [prePostLag] * [-1 1],'k:');
            maxClim = max(maxClim,max(abs(get(gca,'clim'))));

        end
        %%
%         fprintf(' [Replotting]');
%         for stimCode = [1:7]
%             subplot(1,7,stimCode);
% 
%             set(gca,'clim',[-maxClim maxClim]);
%             set_colormap_threshold(gca, [-maxClim maxClim]*.2, [-maxClim maxClim], [1 1 1]);
%             if stimCode==2
%     %             colorbar;
%             end
%         end

        fprintf(' [Saving]');
        saveas(gcf,sprintf('%schan%02i-chan%02i.fig',outputDir,srcChan,destChan));
        close(gcf);
        
        fprintf(' done\n');
    end
    
    toc;
end
