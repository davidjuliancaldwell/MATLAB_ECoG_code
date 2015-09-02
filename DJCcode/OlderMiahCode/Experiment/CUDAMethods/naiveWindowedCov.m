function out = naiveWindowedCov(a,b,windowSize, prePostLag, samplesToSkip)


    slidingWindowBegin = windowSize/2+1;%+prePostLag;
    slidingWindowEnd = length(a) - windowSize/2-1;%-prePostLag;

    numWindows = length(slidingWindowBegin:samplesToSkip:slidingWindowEnd);

    out = zeros(prePostLag*2+1,numWindows);


    for outIdx = 1:numWindows
        currentSample = slidingWindowBegin + (outIdx-1) * samplesToSkip;

        sourceSampleCenteredWindow = (currentSample-windowSize/2):(currentSample+windowSize/2);
        sourceSampleCenteredWindow(sourceSampleCenteredWindow < 1) = 1;
        sourceSampleCenteredWindow(sourceSampleCenteredWindow > length(b)) = length(b);
        for lag = -prePostLag:prePostLag
            movingSampleCenteredWindow = sourceSampleCenteredWindow + lag;

            movingSampleCenteredWindow(movingSampleCenteredWindow < 1) = 1;
            movingSampleCenteredWindow(movingSampleCenteredWindow > length(b)) = length(b);

            f = cov(a(sourceSampleCenteredWindow),b(movingSampleCenteredWindow));
            out(lag+prePostLag+1,outIdx) = f(2,1);
        end
    end
end
