% [signal states params] = load_bcidat('C:\Research\Data\bci\octb09_mot\D2\octb09_ud_mot_tS001R01.dat');
% 
% signal = double(signal(:,1:64));
% for field = fields(states)';
%     states.(field{:}) = single(states.(field{:}));
% end
% params = CleanBCI2000ParamStruct(params);
% 
% signal = NotchFilter(signal, [60 120 180], params.SamplingRate);
% 
% bp = BandPassFilter(signal,[75 200], params.SamplingRate);
% 
% sigAmp = abs(hilbert(bp));
% 
% windowSize = 300;

% test = xcov(sigAmp(:,24),sigAmp(:,25),'same');
% 
% x = (sigAmp(:,23));
% y = (sigAmp(:,24));
% 
% samplesToTest = windowSize+1:length(x)-windowSize*2;
% 
out = zeros(size(samplesToTest,2),windowSize+1);

for sampleToTest = samplesToTest
    xRange = sampleToTest:sampleToTest+windowSize;
    yRange = sampleToTest-windowSize:sampleToTest+windowSize*2;
    xSamp = [zeros(windowSize,1);x(xRange);zeros(windowSize,1)];
    ySamp = y(yRange);
    covariance = xcov(xSamp,ySamp);
    out(sampleToTest,:) = covariance(windowSize*2.5:windowSize*3.5);
    if mod(sampleToTest,1000) == 0
        fprintf('%2.2f ', sampleToTest*100/length(samplesToTest));
    end
end

for sampleToTest = samplesToTest
    xRange = sampleToTest:sampleToTest+windowSize;
    idx = 1;
    indices = ones(301,601);
    indices(:,1) = sampleToTest+[-300:0];
    indices = cumsum(indices,2);
    values = y(indices');
    f = cov([x(xRange) values']);
    out(sampleToTest,:) = f(2:end,1);
%     f = corr(x(xRange),values');
%     out(sampleToTest,:) = f;
    
%     for yStart = sampleToTest-windowSize:sampleToTest+windowSize-1
%         yRange = yStart:yStart+windowSize;
%         plot(yRange); hold on;
%         idx = idx + 1;
%         covariance = cov(x(xRange),y(yRange));
%         out(sampleToTest,idx) = covariance(2,1);
%     end
    if mod(sampleToTest,100) == 0
        fprintf('%2.2f ', sampleToTest*100/length(samplesToTest));
    end
end

% for sampleToTest = samplesToTest
%     xRange = sampleToTest:sampleToTest+windowSize;
%     idx = 1;
% %     a = [];
%     for offset = -300:300
%         yRange = sampleToTest+offset:sampleToTest+offset+windowSize;
%         f = cov(x(xRange),y(yRange));
%         out(sampleToTest,idx) = f(2,1);
% %         plot(yRange); hold on;
%         idx = idx + 1;
% %         a = [a; yRange];
%     end
% 
%     if mod(sampleToTest,100) == 0
%         fprintf('%2.2f ', sampleToTest*100/length(samplesToTest));
%     end
% end

feedbackStart = find(diff(states.Feedback) > 0);

periodBefore = -600;
periodAfter = 3600;

zeros(periodBefore + periodAfter, windowSize*2+1);