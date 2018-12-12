%% 6-15-2016 - Function to zscore relative to baseline using findpeaks, and to also characterize gaussian width
% - copied over to BetaTriggeredStim 8-26-2016 

function [z_ave,mag_ave,latency_ave,w_ave,p_ave,zI,magI,latencyI,wI,pI] = zscoreWithFindPeaks(overallSignal,signalInt,t,tMin,tMax,plotIt)


t_new = t(t>tMin & t<tMax);

preSig = overallSignal(t<-0.005,:);
meanSig = mean(preSig,2);
meanPre = mean(meanSig);
stdPre = std(meanSig);

if plotIt == true
figure
subplot(2,1,1)
plot(t(t<-0.005),meanSig);
end 

%meanPreW = mean(overallSignal(t<-0.005),2);
%stdPreW = std(overallSignal(t<-0.005),[],2);

signalIntAbsMean = abs(mean(signalInt,2));
%[pks,locs,w,p]  = findpeaks(signalIntAbsMean((t>tMin & t<tMax)),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',15e-6,'Npeaks',3);
[pks,locs,w,p]  = findpeaks(signalIntAbsMean((t>tMin & t<tMax)),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','Npeaks',3);

if isempty(locs)
    latency_ave = nan;
    mag_ave = nan;
    w_ave = nan;
    p_ave = nan;
    z_ave = nan;
else
    latency_ave = locs(1);
    mag_ave = pks(1);
    w_ave = w(1);
    p_ave = p(1);
    z_ave = (pks(1)-meanPre)/stdPre;
end

if plotIt == true
   % figure
   gcf
   subplot(2,1,2)
    plot(t_new,signalIntAbsMean((t>tMin & t<tMax)))
    hold on
    plot(locs,pks,'bo')
    xlabel('time (s)');
    ylabel('Voltage (uV)');
    %title(['CCEP magnitude for ',sid,' : channel ',num2str(chan)]);
end

% this is for doing INDIVIDUAL

zI = [];
magI = [];
latencyI = [];
wI = [];
pI = [];
signalIntAbs = abs(signalInt);


for i = 1:size(signalInt,2)
    %[pks,locs,w,p]  = findpeaks(signalIntAbs((t>tMin & t<tMax),i),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',15e-6,'Npeaks',3);
    [pks,locs,w,p]  = findpeaks(signalIntAbs((t>tMin & t<tMax),i),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','Npeaks',3);
    if isempty(locs)
        zI = [zI; nan];
        magI = [magI; nan];
        latencyI = [latencyI nan];
        wI = [wI; nan];
        pI = [pI; nan];
    else
        z_score = (pks(1)-meanPre)./stdPre;
        zI = [zI; z_score];
        magI = [magI; pks(1)];
        latencyI = [latencyI locs(1)];
        wI = [wI; w(1)];
        pI = [pI; p(1)];
    end
    
    
    
end

end