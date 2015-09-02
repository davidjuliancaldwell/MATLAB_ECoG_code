function [latencies, misses] = latencyTest(filename)
%    filename = 'LatencyTestS001R02.dat';
    [signals, states, params] = load_bcidat(filename);
    
    stimuli = double(signals(:,5));
    request = double(states.SendingStim);
    diffemg = (double(signals(:,1))-double(signals(:,2)));
 
    downcount = 1000;
    emghits = [];
    
    for idx = 1:length(diffemg)
        if (diffemg(idx) > 200 && downcount > 200)
            downcount = 0;
            emghits(length(emghits)+1) = idx;
        elseif (diffemg(idx) > 200 && downcount <= 200)
            downcount = 0;
        elseif (diffemg(idx) <= 200)
            downcount = downcount + 1;
        end
    end
    
    [peaks, locs] = findpeaks(-1*stimuli, 'MINPEAKHEIGHT', max(-1*stimuli)*0.5);
    
    rtlatencies = zeros(size(emghits));
    
    for idx = 1:length(emghits)
        temp = min(locs(locs>emghits(idx)));
        if (temp)
            rtlatencies(idx) = temp - emghits(idx);
        end
    end
   
    rtlatencies = rtlatencies (rtlatencies < 500);
    rtlatencies = rtlatencies (rtlatencies > 0);
    
    clf;
    plot(locs, ones(size(locs)), 'k.'); hold on;
    plot(stimuli/max(stimuli),'b');
    plot(diffemg/max(diffemg),'g');
    plot(emghits, ones(size(emghits)), 'r.');
    hold off;
    
    latencies = [];
    latencyCount = 0;
    misses = [];
    missCount = 0;
    
    seekLength = params.SampleBlockSize.NumericValue*2;
    lastRequest = 0;
    for sample = 1:length(request)
        if (request(sample) > 0.5 && lastRequest == 0)
            lastRequest = request(sample);
            
            prevCount = latencyCount;
            
            for seeker = sample:(sample+seekLength)
                if(find(locs == seeker)) 
                    latencies(latencyCount + 1) = seeker - sample;
                    latencyCount = latencyCount + 1;
                    break;
                end
            end
            
            if (latencyCount == prevCount)
                misses(missCount + 1) = sample;
                missCount = missCount + 1;
            end
        elseif (request(sample) < 0.5 && lastRequest > 0.5)
            lastRequest = request(sample);
        end
    end
    
    fprintf('performed latency test on %s\n', filename);
    fprintf('  max stim frequency: %d\n', params.MaxFrequency.NumericValue);
    fprintf('  block size: %d\n', params.SampleBlockSize.NumericValue);
    fprintf('  sample rate: %d\n', params.SamplingRate.NumericValue);
    fprintf('\n');
    sampLat = 1/2/(params.SamplingRate.NumericValue / params.SampleBlockSize.NumericValue);

    fprintf('  round trip latency %f ms, std_dev: %f ms\n', mean(rtlatencies), std(rtlatencies));
    fprintf('  measured processing latency %f ms, std_dev: %f ms\n', mean(latencies), std(latencies));
    fprintf('\n');
    fprintf('  number of successful stim requests %d\n', latencyCount);
    fprintf('  number of missed stim requests %d\n', missCount);
    fprintf('  success rate %f percent\n', latencyCount / (latencyCount + missCount) * 100);
end