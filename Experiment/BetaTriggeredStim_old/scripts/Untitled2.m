addpath (genpath('c:\TDT\OpenEx'));
% data = TDT2mat('C:\TDT\OpenEx\MyProjects\BetaTriggeredStim\DataTanks\d5cd55_BetaTriggeredStim', 'Block-49', 1, 20);
[ecog states] = loadTDTRecording('d5cd55', 'BetaTriggeredStim', 49, 49:64);

%%
stim = states.data(:,1);
mode = states.data(:,2);

ecog_fs = ecog.fs;
ecog = ecog.data;

%% re reference
mu = mean(ecog,1);
ecog = ecog - repmat(mu, size(ecog, 1), 1);

%% find the stims
x = 1:length(stim);

stims = find(stim .* ~(mode==1) & x' < 33e6);

t = -300:4800;

res = zeros(length(t), size(ecog, 2), length(stims));

for idx = 1:length(stims)
    foo = ecog(t+round(stims(idx)/2), :);
%     res(:, :, idx) = foo;
    res(:, :, idx) = foo - repmat(median(foo, 1), length(t), 1);
end

%%
% figure
chans = 49:64;

% for c = 1:16
%     subplot(4,4,c);
%     plot(t/ecog_fs, squeeze(mean(res(:,c,:),3)));
%     ylim([-10e-5 10e-5]);
%     title(num2str(chans(c)));
% end

%% sort the stims

% find mode changes
modestarts = find(diff(mode));
pres = [];
prestimidxs = [];

for idx = 1:length(modestarts)
    dists = stims - modestarts(idx);
    dists(dists > 0) = -Inf;
    [~,k] = max(dists);
    prestimidxs(idx) = k;
    pres(idx) = stims(k);
end

modeends = find(diff(1-mode));
posts = [];
poststimidxs = [];

for idx = 1:length(modeends)
    dists = stims - modeends(idx);
    dists(dists < 0) = Inf;
    [~,k] = min(dists);
    poststimidxs(idx) = k;
    posts(idx) = stims(k);
end

prestimidxs = unique(prestimidxs);
poststimidxs = unique(poststimidxs);
% 
pres = unique(pres);
posts = unique(posts);

% % %%
% figure, plot(mode);
% hold all;
% plot(stim .* ~(mode==1));
% temp = stim .* ~(mode==1);
% plot(pres, temp(pres), 'ro');
% plot(posts, temp(posts), 'b*');


%%

figure
% subplot(2,1,1);

commons = intersect(prestimidxs, poststimidxs);
prestimidxs(ismember(prestimidxs, commons)) = [];
poststimidxs(ismember(poststimidxs, commons)) = [];

    
for c = 1:16

	subplot(2,8,c);
    plot(t/ecog_fs, squeeze(median(res(:, c, poststimidxs),3)),'b', 'linew', 2);    
    hold on;
    plot(t/ecog_fs, squeeze(median(res(:, c, prestimidxs),3)),'r', 'linew', 2);    
    axis tight
    ylim([-5e-5 5e-5]);
    title(num2str(c));
end



% figure
% for c = 8%1:16
% %     subplot(4,4,c);
%     
%     plot(t/ecog_fs, squeeze(res(c,:,1:20:end)),'color',[.5 .5 .5]);
%     hold on;
%     plot(t/ecog_fs, squeeze(median(res(c, :, :),3)),'r', 'linew', 2);    
%     axis tight
%     ylim([-5e-5 5e-5]);
%     title(num2str(c));
% end
% 
% %%
% ecog = [];
% ecog( 1:16,:) = data.streams.ECO1.data;
% ecog(17:32,:) = data.streams.ECO2.data;
% ecog(33:48,:) = data.streams.ECO3.data;
% ecog(49:64,:) = data.streams.ECO4.data;
% 
% emg = data.streams.EMGS.data;
% trig = data.epocs.Valu.onset;
% ecog_fs = data.streams.ECO1.fs;
% ecog_ts = data.streams.ECO1.ts;
% %%
% tdat = double(data.streams.TDAT.data);
% smon = double(data.streams.SMon.data);
% mon_ts = data.streams.TDAT.ts;
% sta_fs = data.streams.TDAT.fs;
% 
% ishit = tdat(1,1:end) > tdat(2,1:end);
% 
% figure; hold on;
% plot(mon_ts,smon(4,:))
% plot(mon_ts,tdat(4,:),'r')
% plot(ecog_ts,zscore(ecog(1,:)')*10,'g')
% % plot(ecog_ts,(emg(1,:)-emg(2,:))*10000,'c');
% plot(mon_ts, ishit, 'c');
% return
% %%
% ecg = ecog(1,:);%-ecog(2,:);
% % ecg(3.602e5:3.603e5) = mean(ecg);
% 
% % ecg = emg(1,:);
% % stims = find(tdat(4,:)==1);
% % % stims = find(ecog(63,:)==1);
% % 
% % stims = find(downsample(conv(tdat(4,:), [1 1],'same'), 2));
% % 
% stims = trig;
% stims(stims < 400/ecog_fs) = [];
% stims(stims > ecog_ts(end)-6000/ecog_fs) = [];
% res = zeros(length(stims), length(-400:6000));
% 
% for stimIdx = 1:length(stims)
%     [~,idx] = min(abs(ecog_ts-stims(stimIdx)));
%     idxs = idx + (-400:6000);
%    res (stimIdx, :) = ecg(idxs) - mean(ecg(idxs));
% end
% 
% t = (-400:6000) / 12;
% figure, plot(t, mean(res, 1));
% figure, imagesc(t, 1:size(res,1), res);