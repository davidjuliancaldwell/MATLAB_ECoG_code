function [signalPP,pkLocs,trLocs] =  extract_PP_betaStim(signal,t,tBegin,tEnd,smooth)
% extract_PP_betaStim
% extract peak to peak values in a signal
% this works on single trials
% time x trials

% David.J.Caldwell
% 9.7.2018

numTrials = size(signal,2);
signalPP = zeros(1,numTrials);
pkLocs = zeros(1,numTrials);
trLocs = zeros(1,numTrials);

order = 3;
framelen = 171;

% was 25 before 

plotIt = 0;

tTemp = t(t>tBegin & t<tEnd);
for i = 1:size(signal,2)
    
    tempSignalExtract = squeeze(signal(t>tBegin & t<tEnd,i));
    if smooth
        tempSignalExtract = sgolayfilt_complete(tempSignalExtract,order,framelen);
    end
    
    [amp,pk_loc,tr_loc]=peak_to_peak_beta_stim(tempSignalExtract);
    
    if isempty(amp)
        amp = nan;
        pk_loc = nan;
        tr_loc = nan;
    end
    
    signalPP(i) = amp;
    pkLocs(i) = pk_loc;
    trLocs(i) = tr_loc;
    
    if plotIt && mod(i,10) == 0
        figure
        plot(tTemp,tempSignalExtract)
        vline(tTemp(pk_loc),'r')
        vline(tTemp(tr_loc),'b')
    end
    
end

end