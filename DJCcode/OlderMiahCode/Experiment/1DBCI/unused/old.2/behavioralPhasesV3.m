% behavioral Analysis


% dsFile = 'ds/26cb98_ud_im_t_ds.mat'; load(dsFile); controlChannel = 36;
% dsFile = 'ds/38e116_ud_mot_h_ds.mat'; load(dsFile); controlChannel = 33; 
% dsFile = 'ds/4568f4_ud_mot_t_ds.mat'; load(dsFile); controlChannel = 56;
% dsFile = 'ds/30052b_ud_im_t_ds.mat'; load(dsFile); controlChannel = 29; 
dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; load(dsFile); controlChannel = 24; 
% dsFile = 'ds/mg_ud_im_t_ds.mat'; load(dsFile); controlChannel = 12; 
% dsFile = 'ds/04b3d5_ud_im_t_ds.mat'; load(dsFile); controlChannel = 45;


% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *


allsigs = [];
alltargets = [];

for recnum = 1:length(ds.recs)
    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);
    
    parameters = CleanBCI2000ParamStruct(parameters);
%     parameters.SamplingRate
    
    % total hack, sorry!
    if (parameters.SamplingRate == 2400)
        signals = downsample(double(signals), 2);
        states.Feedback = downsample(states.Feedback, 2);
        states.TargetCode = downsample(states.TargetCode, 2);
        states.ResultCode = downsample(states.ResultCode, 2);
    end
    
    signals = double(signals);

    if (size(signals,2) == 64)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end
    
%     signals = zscoreAgainstInterest(signals, states.TargetCode, 0);
    cSig = signals(:, controlChannel);
    cSig = hilbAmp(cSig, [77.5 102.5], parameters.SamplingRate);
    cSig = log(cSig.^2);
    cSig = zscoreAgainstInterest(cSig, states.TargetCode, 0);
%     cSig = GaussianSmooth(cSig, parameters.SamplingRate / 2);
    cSig = lowpass(cSig, 3, parameters.SamplingRate, 4);
    
    fb = double(states.Feedback);

    fbEvents = [0; diff(fb)];
    fbOnset = find(fbEvents == 1);
    fbOffset = find(fbEvents == -1);
    
    if length(fbOnset) > length(fbOffset)
        fbOnset = fbOnset(1:length(fbOffset));
    end

    sigs = zeros(fbOffset(1)-fbOnset(1), length(fbOnset));
    
    for c = 1:length(fbOnset)
        sigs(:,c) = cSig(fbOnset(c):(fbOffset(c)-1));
    end
  
    targets = states.TargetCode(fbOnset);
    results = states.ResultCode(fbOffset);

    if(~isempty(allsigs))
        tsigs = sigs(1:size(allsigs,1), :);
    else
        tsigs = sigs;
    end
    
    allsigs = [allsigs tsigs];
    alltargets = [alltargets; targets];

    t = (0:size(allsigs,1)-1)'/parameters.SamplingRate;
    
%     figure;
%     
%     for c = 1:length(fbOnset)
%         colorspec = [(0.1 + 0.9 * c / length(fbOnset)) 0.5 0.5];
%         
%         plot(t, sigs(:, c), 'Color', colorspec); hold on;
%         
%         pause(.1);
%         
%     end

end

%%
clear c cSig colorspec fb fbEvents fbOffset fbOnset recnum results signals sigs targets

%%

swindow = 0.5 * parameters.SamplingRate;

up = 1;
down = 2;

upsigs = allsigs(:, alltargets == up);
downsigs = allsigs(:, alltargets == down);

upcenter = mean(upsigs, 2);
downcenter = mean(downsigs, 2);

upcentermat = repmat(upcenter, [1, size(upsigs,2)]);
downcentermat = repmat(downcenter, [1, size(downsigs, 2)]);

updistances = sum(((upsigs - upcentermat) .^2), 1) .^ .5;
downdistances = sum(((downsigs - downcentermat) .^2), 1) .^ .5;

figure;
subplot(221);
plot(t, exp(upcenter)); hold on;
plot(t, exp(downcenter), 'r');
% plot(t, exp(GaussianSmooth(upcenter, swindow))); hold on;
% plot(t, exp(GaussianSmooth(downcenter, swindow)), 'r');
title('average response');
legend('up', 'down');

subplot(222);
plot(find(alltargets == up), updistances, 'b*');
hold on;
plot(find(alltargets == down), downdistances, 'r*');
plot(find(alltargets == up), smooth(updistances, 10), 'b');
plot(find(alltargets == down), smooth(downdistances, 10), 'r');
title('RMSE by trial');
legend('up', 'down');

subplot(223);
legendEntries = cell(size(upsigs,2), 1);

for c = 1:size(upsigs,2)
    cvar = (0.1 + 0.9 * c / size(upsigs, 2));
    colorspec = [cvar 0.5 cvar];    
%     plot(t, upsigs(:, c), 'Color', colorspec); hold on;     
    plot(t, exp(upsigs(:, c)), 'Color', colorspec); hold on;
%     plot(t, exp(GaussianSmooth(upsigs(:, c), swindow)), 'Color', colorspec); hold on;     
    legendEntries{c} = ['Trial ' num2str(c)];
end

title('smoothed up target responses');
legend(legendEntries);

subplot(224);
legendEntries = cell(size(downsigs,2), 1);

for c = 1:size(downsigs,2)
    cvar = (0.1 + 0.9 * c / size(downsigs, 2));
    colorspec = [cvar 0.5 cvar];    
%     plot(t, downsigs(:, c), 'Color', colorspec); hold on;     
    plot(t, exp(downsigs(:, c)), 'Color', colorspec); hold on;
%     plot(t, exp(GaussianSmooth(downsigs(:, c), swindow)), 'Color', colorspec); hold on;     
    legendEntries{c} = ['Trial ' num2str(c)];
end

title('smoothed down target responses');
legend(legendEntries);

% idx = strfind(dsFile, '/') + 1;
% idx2 = strfind(dsFile, '.mat') - 1;
% 
% path = [myGetenv('output_dir') '\remoteAreas\Clustering\'];
% file = dsFile(idx:idx2);

%%

up = 1;
down = 2;

upsigs = allsigs(:, alltargets == up);
downsigs = allsigs(:, alltargets == down);

ups = upsigs';
downs = downsigs';
upmean = mean(ups,1);
downmean = mean(downs,1);

% upCov = cov(ups - repmat(upmean, size(ups,1), 1));
% downCov = cov(downs - repmat(downmean, size(downs,1), 1));

upCov = cov(ups);
downCov = cov(downs);

pcCount = 3;

[upVecs, upVals] = eigs(upCov, pcCount);
upVals = diag(upVals);

[downVecs, downVals] = eigs(downCov, pcCount);
downVals = diag(downVals);

plotHeight = pcCount + 1;

figure;

subplot(plotHeight, 2, 1);
% plot(t, upVecs(:,1:pcCount));
plot(t, exp(upVecs(:,1:pcCount)));

subplot(plotHeight, 2, 2);
% plot(t, downVecs(:,1:pcCount));
plot(t, exp(downVecs(:,1:pcCount)));

% subplot(plotHeight*2, 1, 1);
% plot(t,GaussianSmooth(upmean, parameters.SamplingRate/2),t,GaussianSmooth(downmean, parameters.SamplingRate/2));
% title('mean responses');
% xlabel('time');
% ylabel('exp(z(log HG hilbert power))');
% legend('up', 'down');

for c = 1:pcCount
    fprintf('%d %d %d\n', plotHeight, 2, c*2+1);
    subplot(plotHeight, 2, c*2+1);
    upproj = ups * upVecs(:,c);
    plot(upproj, 'b*');
    title(sprintf('up projection - PC_%d', c));
    xlabel('trial');
    ylabel('projection magnitude');
    
    % add the PC
    limits = ylim;
    

    fprintf('%d %d %d\n', plotHeight, 2, c*2+2);
    subplot(plotHeight, 2, c*2+2);
    downproj = downs * downVecs(:,c);
    plot(downproj, 'g*');
    title(sprintf('down projection - PC_%d', c));
    xlabel('trial');
    ylabel('projection magnitude');
end

% figure;
% subplot(211);
% plot(t, upVecs(:,1:3));
% hold on;
% plot(t, upcenter, 'k', 'LineWidth', 2);
% 
% subplot(212);
% plot(t, downVecs(:,1:3));
% hold on;
% plot(t, downcenter, 'k', 'LineWidth', 2);
% 
% projs = [ups * upVecs(:,1) ...
%          ups * upVecs(:,2) ... 
%          ups * upVecs(:,3)];

%%
% 
% figure;
% 
% plot(t, upmean, 'r', 'LineWidth', 2); hold on;
% 
% for c = 1:size(ups, 1)
%     resp = zeros(1, length(ups));
%     
%     for d = 1:10
%         resp = resp + ups(c,:) * upVecs(:,d) * upVecs(:,d)';
%     end
%     
%     plot(t, resp);
% %     hold on;
%     pause(.1);
% end
% 
% %%
% 
% figure;
% 
% preMeans = mean(ups(:,1:500), 2);
% postMeans = mean(ups(:,501:1000), 2);
% 
% 
