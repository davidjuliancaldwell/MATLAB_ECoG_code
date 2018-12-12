function [peakPhase,peakStd,peakLength,circularTest] = phase_circstats_calc(signal,varargin)

defaultTest = 'omnibus';

p = inputParser;
addOptional(p,'testStatistic',defaultTest);
parse(p,varargin{:});

testStatistic = p.Results.testStatistic;


numChans = size(signal,2);
for i = 1:numChans
    signalInt = signal(:,i);
    
    if sum(~isnan(signal(:,i)))
        signalNoNaN = signalInt(~isnan(signalInt));
        peakPhase(i) = circ_mean(signalNoNaN);
        
        if peakPhase(i) < 0
            peakPhase(i) = 2*pi + peakPhase(i);
        end
        
        peakStd(i) = circ_std(signalNoNaN);
        peakLength(i) = circ_r(signalNoNaN);
        
        switch testStatistic
            case 'rayleigh'
                testTemp = circ_rtest(signalNoNaN);
                
            case 'omnibus'
                testTemp = circ_otest(signalNoNaN);
                
            case 'raoSpacing'
                testTemp = circ_raotest(signalNoNaN);
                
%             case 'V test'
%                 testTemp = circ_vtest(signalNoNaN);
%                 
        end
        circularTest(i) = testTemp;
    end
end
