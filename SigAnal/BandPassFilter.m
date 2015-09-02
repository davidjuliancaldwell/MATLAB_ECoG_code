function out = BandPassFilter(signal, BandRange, SamplingFreq,orderNum)

if ~exist('orderNum','var')
    orderNum = 9;
end

if length(BandRange) ~= 2
    fprintf('Usage: BandPass(signal [MxN], BandRange [2x1], SamplingRate [1x1]\n');
    return
end

if size(BandRange,1) < size(BandRange,2)
    BandRange = BandRange';
end

% FDesc = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', BandRange(1)-1, BandRange(1), BandRange(2), BandRange(2)+1, 5, 1, 5, SamplingFreq);
% NewFilter = design(FDesc, 'butter');
% 
% out = filter(NewFilter, signal);

[b a] = butter(orderNum, BandRange * 2 / SamplingFreq);
out = filtfilt(b,a,signal);