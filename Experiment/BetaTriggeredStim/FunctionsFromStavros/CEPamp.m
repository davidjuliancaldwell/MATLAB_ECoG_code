function [A_pos,A_neg,L_pos,L_neg,c2plot,taxis] = CEPamp (sweep,thr,pre,post,artsup,smoothfw,fs,order,CEPplot,plot_title)

% CEPamp    Returns the amplitude and latency of the first 2 components
% (positive and negative) of a CEP; note it works well with early-onset CEP
% components (typically, <30ms)
%
% [A_pos,A_neg,L_pos,L_neg,smooth_sweep] = CEPamp (sweep,sweepCI,pre,post,artsup,smoothfw,fs,order,CEPplot,CEPplot_title)
%
% A_pos/neg     positive/negative peak amplitude, AD units (or 1st/2nd peak amplitude)
% L_pos/neg     positive/negative peak latency, ms (or 1st/2nd peak latency)
% smooth_sweep  smoothed sweep vector
%
% sweep         original sweep vector
% thr           CEP significance threshold (x baselineSD), set to 0 for no threshold
% pre/post      pre/post-stimulus sweep duration, in s
% artsup        artifact duration (post-stim), in s (to avoid identifying
%               artifact components as peaks)
% smoothfw      smooth function width, in samples
% fs            sampling rate
% order         set to 0 to return pos/neg peak, 1 for 1st/2nd peak
% CEPplot       set to 1 to plot result
% CEPplot_title plot title

% turn a common warning off
w = 'signal:findpeaks:largeMinPeakHeight';
warning('off',w)

if size(sweep,1)>1
    sweep=sweep';
end

taxis = -pre*1000:1000/fs:post*1000;
supsam = [ceil(pre*fs-artsup*fs),ceil(pre*fs+artsup*fs)]; % beginning and end of artifact suppression (samples)
c2plot = sweep;

% DC-correction
c2plot = c2plot - median(c2plot(1:supsam(1)));

% calculate baseline SD and height threshold
bslsd = std(c2plot(1:supsam(1)));
minPH = bslsd*thr;

% attempt to fit exponential decay to post-stim segment
%pp = smooth(c2plot(supsam(2)+1:end),smoothfw);
pp = c2plot(supsam(2)+1:end);
[f,gof] = fit([1:length(pp)]',pp','exp2'); % 2-term exponential
if gof.adjrsquare>0.8
    % subtract exp function if R2>0.8
    ppc = pp' - f([1:length(pp)]');
else
    ppc = pp';
end

% smooth post-stim segment using Savitzky-Golay filtering
smppc = sgolayfilt(ppc,5,81);

npoints = 2; % n. of points around peak for averaging
pw = 1; % minimum peak width, ms
pd = 5; % minimum peak distance, ms
ppr = 3; % minimum peak prominence (uV)

% find first positive peak and its latency
posp = zeros(1,length(smppc));
posp(smppc>0) = smppc(smppc>0);
[MX,IMX] = findpeaks(posp,'MinPeakHeight',minPH,'MinPeakDistance',round(pd*(fs/1000)),'MinPeakWidth',round(pw*(fs/1000)),'MinPeakProminence',ppr);
if isempty(MX) || taxis(max(IMX))>(post*1000)/1.1
    MX=NaN; IMX= NaN;
else
    MX = MX(1); IMX=IMX(1); % always take the first positive deflection
    MX = median(posp(IMX-npoints:IMX+npoints));
    IMX = IMX+supsam(2);
    IMX = taxis(IMX);
end

% find first negative peak and its latency
negp = zeros(1,length(smppc));
negp(smppc<0) = smppc(smppc<0);
[MN,IMN] = findpeaks(-negp,'MinPeakHeight',minPH,'MinPeakDistance',round(pd*(fs/1000)),'MinPeakWidth',round(pw*(fs/1000)),'MinPeakProminence',ppr);
if isempty(MN) || taxis(max(IMN))>(post*1000)/1.1
    MN=NaN; IMN= NaN;
else
    MN = MN(1); IMN=IMN(1);
    MN = mean(negp(IMN-npoints:IMN+npoints));
    IMN = IMN + supsam(2);
    IMN = taxis(IMN);
end

% compare identified peaks to baseline
if abs(MX)>bslsd*thr
    A_pos = MX;
    L_pos = IMX;
else
    A_pos = 0;
    L_pos = 0;
end

if abs(MN)>bslsd*thr
    A_neg = MN;
    L_neg = IMN;
else
    A_neg = 0;
    L_neg = 0;
end

if order==1
    if L_pos>L_neg
        A

if CEPplot==1
    if A_pos==0
        lstl_pos = ':';
    else
        lstl_pos = '-';
    end
    
    if A_neg==0
        lstl_neg = ':';
    else
        lstl_neg = '-';
    end
    
    c2plot = [c2plot(1:supsam(2)), ppc(1:end)'];
    figure
    set(gcf,'Position',[220 170 1000 800]) % figure-size window
    c2plot(supsam(1):supsam(2)) = nan;
    sweep2plot = sweep;
    sweep2plot(supsam(1):supsam(2)) = nan;
    plot(taxis,sweep2plot,'Color',[0 0 0.3])
    set(gca,'FontSize',14)
    hold on
    plot(taxis,c2plot,'Color',[0.2 0.2 0.8])
    line([IMX IMX],[0 MX],'LineWidth',2,'LineStyle',lstl_pos,'Color',[35/255 140/255 35/255]) % forest green
    line([IMN IMN],[0 MN],'LineWidth',2,'LineStyle',lstl_neg,'Color',[1 165/255 0]) % orange
    line(get(gca,'XLim'),[0 0],'LineStyle',':','Color','k')
    line([0 0],[get(gca,'YLim')],'Color','r')
    ylabel('voltage, AD units')
    xlabel('time, ms')
    if exist('plot_title')
        title(plot_title)
    end
    waitforbuttonpress
    close
end

end