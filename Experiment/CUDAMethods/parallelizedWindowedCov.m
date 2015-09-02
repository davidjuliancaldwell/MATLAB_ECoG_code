function out = parallelizedWindowedCov(a,b,windowSize, prePostLag, samplesToSkip)


    valueIndices = ones(prePostLag*2+1, windowSize+1);
    valueIndices(:,1) = cumsum(valueIndices(:,1));
    valueIndices = cumsum(valueIndices,2)';


    slidingWindowBegin = windowSize/2+1;%+prePostLag;
    slidingWindowEnd = length(b) - windowSize/2-1;%-prePostLag;

    numWindows = length(slidingWindowBegin:samplesToSkip:slidingWindowEnd);

    out = zeros(numWindows,prePostLag*2+1);

    parfor outIdx = 1:numWindows
        values = ones(size(valueIndices,1),size(valueIndices,2)+1); 
        currentSample = slidingWindowBegin + (outIdx-1) * samplesToSkip;

        sourceSampleCenteredWindow = (currentSample-windowSize/2):(currentSample+windowSize/2);

        destSampleCenteredRange = (currentSample - windowSize/2 - prePostLag):(currentSample + windowSize/2 + prePostLag);
        destSampleCenteredRange(destSampleCenteredRange < 1) = 1;
        destSampleCenteredRange(destSampleCenteredRange > length(b)) = length(b);
        ySample = b(destSampleCenteredRange);
        values(:,2:end) = ySample(valueIndices);
        values(:,1) = a(sourceSampleCenteredWindow);
        f = cov(values);

        out(outIdx,:) = f(2:end,1);
    end
    out = out';
end