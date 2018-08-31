function [signalPP,pkLocs,trLocs] =  extract_PP_betaStim(signal,t,tBegin,tEnd,smooth)
% extract_PP_betaStim
% extract peak to peak values in a signal
% this works on single trials
% time x trials

% David.J.Caldwell
% 6.19.2018

numTrials = size(signal,2);
signalPP = zeros(1,numTrials);
pkLocs = zeros(1,numTrials);
trLocs = zeros(1,numTrials);

% original was above before 7/27/2018

order = 3;
framelen = 25;

plotIt = 0;

for i = 1:size(signal,2)
    
    tempSignalExtract = squeeze(signal(t>tBegin & t<tEnd,i));
    if smooth
        tempSignalExtract = sgolayfilt_complete(tempSignalExtract,order,framelen);
    end
    
    [amp,pk_loc,tr_loc]=peak_to_peak(tempSignalExtract);
    
    if isempty(amp)
        amp = nan;
        pk_loc = nan;
        tr_loc = nan;
    end
    
    signalPP(i) = amp;
    pkLocs(i) = pk_loc;
    trLocs(i) = tr_loc;
    
    if plotIt
        figure
        plot(t,tempSignalExtract)
        vline(pk_loc)
        vline(tr_loc)
    end
    
end

end