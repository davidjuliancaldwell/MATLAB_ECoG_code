Z_Constants;

addpath ./scripts;

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, [sid '_epochs.mat']), 'epochs', 't', '*Dur', 'ress', 'tgts', 'bad_channels', 'montage', 'hemi');

    % epochs is 
    %   frequency x trials x channels x time
    
    ups = tgts==1;
    [sups, idx] = sort(ups);
    
    return
    
    for freq = 5:size(epochs, 1)
        for chan = 1:size(epochs, 3)
            data = squeeze(epochs(freq, :, chan, :));

            %%
            subplot(3,1,1);
            prettyline(t, data', ups, 'br');
            vline([-preDur 0], 'k');
            title(sprintf('s=%s, f=%d, chan=%d', sid, freq, chan));
            
            subplot(3,1,2);            
            imagesc(t, 1:length(ups), data(idx, :))                        
            hline(find(diff(sups)), 'w');
            vline([-preDur 0], 'k');
            
            subplot(3,1,3);            
            [h, p] = ttest2(data(ups,:),data(~ups,:));
            plot(t, p, 'color', [1 0.5 0.5], 'linew', 2); ylim([0 1]);
            hold on;
            legendOff(plot(t(h>0), p(h>0), 'r.', 'linew', 2));
            [h, p] = ttest2(rdata(ups,:),rdata(~ups,:));
            plot(t, p, 'color', [0.5 0.5 1], 'linew', 2); ylim([0 1]);
            legendOff(plot(t(h>0), p(h>0), 'b.', 'linew', 2));
            
            legendOff(hline(0.05, 'k'));
            legendOff(vline([-preDur 0], 'k'));            
            
            legend('raw', 'normalized');
            hold off;
            %%
            x=5;
        end
    end
end

%% lasso playground
data = squeeze(epochs(5,:,30,:));

data = lowpass(data', 4, 100, 4)';
% - or - 
% data = data;

data = zscoreAgainstInterest(data', t<=-preDur, 1)';
% - or -
% data = data;

[stgts, sidx] = sort(tgts);

% temp for interest
% imagesc(data(sidx,:))
data = data(:,t>0&t>-preDur);

[B, Info] = lasso(data,double(tgts)-1.5, 'CV', 10);
figure
lassoPlot(B, Info, 'PlotType', 'CV');

figure
imagesc(B');
axis xy;
hline(Info.IndexMinMSE-1,'k');
hline(Info.IndexMinMSE+1,'k');

figure
scatter(data * B(:,Info.IndexMinMSE), jitter(double(tgts),.1))

%% regression playground

dsfac = 10;
repochs = zeros(size(epochs, 1), size(epochs, 2), size(epochs, 3), ceil(size(epochs, 4)/dsfac));

for bandi = 1:size(epochs, 1)
    for chani = 1:size(epochs, 3)
        data = squeeze(epochs(bandi, :, chani, :));
        % if normalize
        data = zscoreAgainstInterest(data', t<=-preDur, 1)';
        repochs(bandi, :, chani, :) = resample(data', 1, dsfac)';
    end
end

%%
% ok, now, marching through time, we're going to look at the predictive
% power of each channel / freq / time
up = double(tgts==1);
N = 50;
vals = zeros(N, size(repochs, 3), size(repochs, 4));

sr2 = zeros(size(repochs, 1), size(repochs, 3), size(repochs, 4));
conf = zeros(size(repochs, 1));

for bandi = 1:size(repochs, 1)
    fprintf('bandi: %d\n', bandi);
    for chani = 1:size(repochs, 3)
        fprintf('  chani: %d\n', chani);
        data = squeeze(repochs(bandi, :, chani, :));
        
        temp = corr(data, up);
        sr2(bandi, chani, :) = sign(temp) .* temp.^2;
        
        for n = 1:N
            vals(n, chani, :) = corr(data, shuffle(up));            
        end        
    end
    
    conf(bandi) = prctile(max(max(vals.^2, [], 3), [], 2), 95);        

end

%% now viz
rt = downsample(t, dsfac);
load recon_colormap

for bandi = 1:size(repochs, 1)
    subplot(3,2,bandi);
    temp = squeeze(sr2(bandi, :,:));
    temp(abs(temp) < conf(bandi)) = 0;
    
    imagesc(rt, 1:size(repochs, 3), temp);
    vline([-preDur 0 fbDur], 'k');
    colormap(cm);
    set(gca, 'clim', [-1 1]);
    colorbar;
    title(BAND_NAMES{bandi});
end

%%

% 
% data = squeeze(epochs(5,:,30,t>.5&t<2));

% % data = GaussianSmooth(squeeze(epochs(5,:,30,t>-.5&t<.5)),25)';
% % data = GaussianSmooth(squeeze(epochs(5,:,30,t>0&t<.5)),25)';
% % data = GaussianSmooth(squeeze(epochs(5,:,30,t>(-fbDur+.3)&t<0)),25)';
% 
% Dp = pdist(data);
% Dd = dtw_multi_multichan(data, 25);
% 
% xp = mdscale(Dp, 2);
% xd = mdscale(Dd, 5);
% 
% figure
% gscatter(xp(:,1), xp(:,2), ups);
% figure
% gscatter(xd(:,1), xd(:,2), ups);
% 
% for d1 = 1:4
%     gscatter(xd(:,d1), xd(:,d1+1), ups);
%     pause
% end
% 
% % D = pdist(squeeze(epochs(5,:,30,t>.5&t<2)));
% % x = mdscale(D, 2);
% % % proj = mdscale(D, 1);
% % y = [mean(epochs(5,:,30,t>.5&t<2),4); mean(epochs(5,:,30,t>-1&t<0),4)]'
% % gscatter(x(:,1), x(:,2), ups);
% % figure
% % gscatter(y(:,1), y(:,2), ups);
% 

%%
% data = squeeze(epochs(5,:,30,t>.5&t<=2));

t_0 = -preDur;
t_step  = .1;
t_win   = .5;

t_ends = (t_0+t_win):t_step:max(t);

r2 = zeros(size(epochs, 3), length(t_ends));

mepochs = squeeze(epochs(5,:,:,:));
for obs = 1:size(mepochs,1)
    mepochs(obs,:,:) = GaussianSmooth(squeeze(mepochs(obs, :, :)), 10)';
end

for chan_idx = 1:size(epochs, 3)
    if (~ismember(chan_idx, bad_channels))
        for t_idx = 1:length(t_ends)
            tkeep = t>=(t_ends(t_idx)-t_win) & t <= t_ends(t_idx);
            data = squeeze(mepochs(:,chan_idx, tkeep));
%             data = squeeze(epochs(5,:,chan_idx, tkeep));
            clusters = kmeans(data, 2);
            r2(chan_idx, t_idx) = corr(clusters, ups).^2;
        end
    end
end

plot(t_ends, r2')

figure
% w = max(r2(:, t_ends < .5)');
w = max(r2(:, :)');
PlotDots(sid, montage.MontageTokenized, w, hemi, [0 max(w)], 10, 'recon_colormap');
load('recon_colormap');
colormap(cm);
colorbar;

%%

t_0 = -preDur;
t_step  = .1;
t_win   = .5;

r2s = [];
valss = [];

for f = 2:6
    mepochs = squeeze(epochs(f,:,:,:));

    % if smooth
    for obs = 1:size(mepochs,1)
        mepochs(obs,:,:) = GaussianSmooth(squeeze(mepochs(obs, :, :)), 10)';
    end

    % do permutation test    
    reps = 200; % should take about an hour
    vals = zeros(reps, 1);
    for rep = 1:reps    
        fprintf('rep: %d of %d\n', rep, reps);
        r2 = corrWindows(mepochs, shuffle(ups), t, t_0, t_step, t_win, bad_channels);
        vals(rep) = max(max(r2));
    end    

    % gimme the real result
    [r2, t_ends] = corrWindows(mepochs, ups, t, t_0, t_step, t_win, bad_channels);

    % show it
    figure
    imagesc(t_ends, 1:size(r2,1), r2)
    colorbar;
    set_colormap_threshold(gcf, [0 prctile(vals, 95)], [0 1], [1 1 1]);
    title(num2str(f));
    
    % save it for later
    r2s(f, :, :) = r2;
    valss(f, :) = vals;    
end


%%
r2b = [];

for t_idx = 1:length(t_ends)
    tkeep = t>=(t_ends(t_idx)-t_win) & t <= t_ends(t_idx);
    data = squeeze(epochs(5,:,:, tkeep));
    data = reshape(data, [size(data, 1), size(data, 2)*size(data,3)]);
    clusters = kmeans(data, 2);
    r2b(t_idx) = corr(clusters, ups).^2;
end

figure
plot(t_ends, r2b');


%%
data = squeeze(epochs(5,:,30,t>-preDur&t<0));
data = GaussianSmooth(data, 25)';
ups = tgts==1;

ds = zeros(length(ups), 2);

tr = false(size(ups));
tr(1:40) = true;

upt = mean(data(ups(tr), :),1);
dnt = mean(data(~ups(tr), :),1);
w = 10;

for obs = 1:length(ups);
%     % using euclidean distance
%     ds(obs, 1) = pdist([data(obs,:);upt]);
%     ds(obs, 2) = pdist([data(obs,:);dnt]);
    
    % using dtw
    ds(obs, 1) = dtw_c(data(obs,:)',upt', w);    
    ds(obs, 2) = dtw_c(data(obs,:)', dnt', w);
end

figure
gscatter(ds(~tr,1), ds(~tr,2), ups(~tr))
% gscatter(ds(1:30,1), ds(1:30,2), ups(1:30))


%% try the function version
d2s = distanceProject(squeeze(epochs(5,:,30,t>-preDur&t<0)), ups, tr);
figure
gscatter(ds(~tr,1), ds(~tr,2), ups(~tr));

%% do the same across all pairs
ups = tgts==1;

for f = 1:size(epochs, 1)
    for c = 1:size(epochs, 3)
%         data = squeeze(epochs(f,:,c,t>.5&t<3));
        data = squeeze(epochs(f,:,c,t>-preDur&t<0));
        data = GaussianSmooth(data, 25)';

        ds = zeros(length(ups), 2);
        tr = false(size(ups));
        tr(1:40) = true;

        upt = mean(data(ups(tr), :),1);
        dnt = mean(data(~ups(tr), :),1);
        w = 10;
        
        for obs = 1:length(ups);
%             % using euclidean distance
%             ds(obs, 1) = pdist([data(obs,:);upt]);
%             ds(obs, 2) = pdist([data(obs,:);dnt]);

            % using dtw
            ds(obs, 1) = dtw_c(data(obs,:)',upt', w);    
            ds(obs, 2) = dtw_c(data(obs,:)', dnt', w);
        end

        
%         gscatter(ds(~tr,1), ds(~tr,2), ups(~tr))
%         pause
        foo = cat(2, ones(size(ds, 1), 1), ds);
        [r,bint,r,rint,stats]=regress(ups(~tr), foo(~tr, :));

        ps(f,c) = stats(3);
    end
end

imagesc(ps < 0.05)