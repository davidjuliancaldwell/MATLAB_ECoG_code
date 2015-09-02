% % [signal states params] = load_bcidat('C:\Research\Data\Connectivity\octb09_mot_t_hS001R01.dat');
% % [signal states params] = load_bcidat('D:\Research\Data\Patients\0dd118\d5\0dd118_finger_twister001\0dd118_finger_twisterS001R03');
% 
fprintf('Preparing data \n');
fprintf('  [Loading BCI]\n');
[signal states params] = load_bcidat('D:\Research\Data\Patients\c9f430\D1\c9f430_mot_h001\c9f430_mot_hS001R05');

fprintf('  [Downsampling to Grid]\n');
signal = double(signal(:,1:64));

fprintf('  [Fixing States]\n');
for field = fields(states)';
    states.(field{:}) = single(states.(field{:}));
end
fprintf('  [Cleaning Params]\n');
params = CleanBCI2000ParamStruct(params);

fprintf('  [Notch]\n');
signal = NotchFilter(signal, [60 120 180], params.SamplingRate);

fprintf('  [CAR]\n');
signal = ReferenceCAR([16 16 16 16 ],[],signal);

fprintf('  [HG Band pass]\n');
bp = BandPassFilter(signal,[75 200], params.SamplingRate);

fprintf('  [Hilb Amp]\n');
sigAmp = abs(hilbert(bp));

%%
windowSize = 300; % samples
prePostLag = 200; % samples

downsamplePicturesBy = 2;

for srcChan = 1:64
    outputDir = sprintf('%s\\sepa10c_windowed\\srcChan %03i\\', getenv('output_dir'), srcChan);
    [a b c] = mkdir(outputDir);
   
    x = single(sigAmp(:,srcChan));
    
    destChans = setdiff(1:64,srcChan);
%     destChans = 57;
    tic    
    for destChan = destChans
        fprintf('SrcChan(%2i) DestChan(%2i) - ',srcChan, destChan);
        
        y = single(sigAmp(:,destChan));

        
        fprintf(' [Processing]');
%         out = CudaMex_v2(x,y,windowSize, prePostLag);
        out = gausswc(x,y,windowSize, prePostLag, single(gausswin(windowSize)));

        %% Plotting
        fprintf(' [Plotting]');
        figure;
        
        secondsBefore = 0.5; % seconds
        secondsAfter = 5; % seconds
        
        for stimCode = 0:3
            
            epochs = getEpochs(states.StimulusCode,stimCode);
            
            averageCov = zeros(prePostLag*2+1,round((secondsBefore + secondsAfter)* params.SamplingRate));
            numValidFlexs = 0;
            for epoch = epochs
                eRange = epoch + (-round(secondsBefore * params.SamplingRate):round(secondsAfter * params.SamplingRate)-1);
                try
                    averageCov = averageCov + out(:,eRange);
                    numValidFlexs = numValidFlexs + 1;
                catch e
%                     fprintf('Range error\n');
                end
            end
            
            averageCov = averageCov ./ numValidFlexs;
            
            subplot(1,4,stimCode+1);
            imagesc([-secondsBefore:.1:secondsAfter],[-prePostLag:prePostLag],averageCov(:,1:downsamplePicturesBy:end)); title(sprintf('StimulusCode %i',stimCode));
        end
            
        fprintf(' [Saving]');
        saveas(gcf,sprintf('%schan%02i-chan%02i.fig',outputDir,srcChan,destChan));
        close(gcf);
        
        fprintf(' done\n');
    end
    
    toc;
end
