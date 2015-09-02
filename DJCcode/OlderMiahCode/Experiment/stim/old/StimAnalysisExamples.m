[sig, sta, par] = load_bcidat('d74850_recurrent_stimS001R30.dat');

chan = 3;

% per stimulus image
locs = find(diff(double(sta.SendingStim))>.5);
locs(locs <= 40) = [];
msig = highpass(double(sig(:,chan)), 3, 1200, 4);

nSamplesInBlock = par.SampleBlockSize.NumericValue;
locs = find([0; diff(double(sta.SendingStim))]>.5);
locs((locs-2*nSamplesInBlock) <=0) = [];
data = getEpochSignal(msig, locs-2*nSamplesInBlock-1, locs+300);

t = (-2*nSamplesInBlock:300)/1.2;
figure
imagesc(t, 1:length(locs), squeeze(data)');
vline(0);
vline(-nSamplesInBlock/1.2, 'k:');
xlabel('time (ms)');
ylabel('stimuli');
title(['individual stimuli, aligned on stim-command, channel ' num2str(chan)]);

%% average

figure
plot(t, mean(squeeze(data),2));
vline(0);
vline(-nSamplesInBlock/1.2, 'k:');
xlabel('time (ms)');
ylabel('AU');
title(['stim-command triggered average, channel ' num2str(chan)]);

%% sta locs
alocs = zeros(size(locs));

for idx = 1:length(locs)
     timeseries = squeeze(data(:,:,idx));
     [peak, loc] = max(timeseries);
%      
%      plot(timeseries);
%      hold on
%      plot(loc, peak, 'ro');
%      pause
%      hold off;
     
     alocs(idx) = locs(idx)+loc-2*nSamplesInBlock;
end

adata = getEpochSignal(msig, alocs-2*nSamplesInBlock-1, alocs+300);

% figure
% imagesc(t, 1:length(locs), squeeze(data)');


figure
plot(t, mean(squeeze(adata),2));
xlabel('time (ms)');
ylabel('AU');
title(['stimulus triggered average, channel ' num2str(chan)]);