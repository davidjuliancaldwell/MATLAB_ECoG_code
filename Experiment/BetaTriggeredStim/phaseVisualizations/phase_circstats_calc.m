function [peakPhase,peakStd,peakRayleighTest] = phase_circstats_calc(signal)


numChans = size(signal,2);
for i = 1:numChans
    signalInt = signal(:,i);
    if sum(~isnan(signal(:,i)))
        signalNoNaN = signalInt(~isnan(signalInt));
        peakPhase(i) = circ_median(signalNoNaN);
        if peakPhase(i) < 0
            peakPhase(i) = 2*pi + peakPhase(i);
        end
        peakStd(i) = circ_std(signalNoNaN);
        peakRayleighTest(i) = circ_rtest(signalNoNaN);
    end
end

