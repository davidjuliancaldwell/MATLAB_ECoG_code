%% 7-19-2016 - Function to zscore relative to baseline using findpeaks, and to also characterize gaussian width

function [z_ave,mag_ave,latency_ave,w_ave,p_ave] = zscoreStimSpacing(sigPre,sigPost,t,preMin,...
    preMax,postMin,postMax,plotIt)

t_pre = t(t>preMin & t<preMax);
t_post = t(t>postMin & t<postMax);

meanSig = sigPre; 
meanPre = mean(meanSig);
stdPre = std(meanSig);

if plotIt == true
figure
subplot(2,1,1)
plot(t_pre,meanSig);
end 

%meanPreW = mean(overallSignal(t<-0.005),2);
%stdPreW = std(overallSignal(t<-0.005),[],2);

signalIntAbsMean = abs(sigPost);
%[pks,locs,w,p]  = findpeaks(signalIntAbsMean((t>postMin & t<tMax)),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',15e-6,'Npeaks',3);
[pks,locs,w,p]  = findpeaks(signalIntAbsMean,t_post,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',15,'sortstr','descend','Npeaks',3);

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
    plot(t_post,signalIntAbsMean)
    hold on
    plot(locs,pks,'bo')
    xlabel('time (s)');
    ylabel('Voltage (uV)');
    %title(['CCEP magnitude for ',sid,' : channel ',num2str(chan)]);
end

% % this is for doing INDIVIDUAL
% 
% zI = [];
% magI = [];
% latencyI = [];
% wI = [];
% pI = [];
% signalIntAbs = abs(signalInt);
% 
% 
% for i = 1:size(signalInt,2)
%     %[pks,locs,w,p]  = findpeaks(signalIntAbs((t>postMin & t<tMax),i),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',15e-6,'Npeaks',3);
%     [pks,locs,w,p]  = findpeaks(signalIntAbs((t>postMin & t<postMax),i),t_post,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','Npeaks',3);
%     if isempty(locs)
%         zI = [zI; nan];
%         magI = [magI; nan];
%         latencyI = [latencyI nan];
%         wI = [wI; nan];
%         pI = [pI; nan];
%     else
%         z_score = (pks(1)-meanPre)./stdPre;
%         zI = [zI; z_score];
%         magI = [magI; pks(1)];
%         latencyI = [latencyI locs(1)];
%         wI = [wI; w(1)];
%         pI = [pI; p(1)];
%     end
%     
    
%end

end