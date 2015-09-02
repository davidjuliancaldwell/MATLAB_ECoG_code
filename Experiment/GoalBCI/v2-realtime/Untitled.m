%%
len = Inf;

for rec = 1:size(timeSeries, 2)
    len = min(length(timeSeries{1, rec}), len); 
end

%%
ts = nan(size(timeSeries, 1), size(timeSeries, 2), len);

t = (1:len)/tsfs - 3;
tx = 1:size(ts, 2);

rt = t < -2;

for rec = 1:size(timeSeries, 2)
%     mlen = length(timeSeries{1, rec});
    
    temp = [timeSeries{:, rec}]';
    ts(:, rec, :) = log(temp(:, 1:len).^2);
    mu = mean(ts(:, rec, rt),3);
    
    ts(:, rec, :) = ts(:, rec, :) - repmat(mu, [1, 1, size(ts, 3)]);
end

%%

ups = ismember(targets, UP);

chans = [1:4 9:12 17:20 25:28];

for chan = chans
    sdu = GaussianSmooth2(squeeze(ts(chan,  ups, :)), [5 50], [2 17]); 
%     sdu = squeeze(ts(chan, ups, :));
    
    sdd = GaussianSmooth2(squeeze(ts(chan, ~ups, :)), [5 50], [2 17]); 
%     sdd = squeeze(ts(chan, ~ups, :));
    
    figure;
    
    subplot(211);    
    imagesc(t, tx(ups), sdu);
    xlabel('time (s)');
    ylabel('trial');
    colorbar;
    set_colormap_threshold(gcf, [-.2 .2], [-1 1], [.5 .5 .5]);
    title(num2str(chan));
    
    subplot(212);    
    imagesc(t, tx(ups), sdd);
    xlabel('time (s)');
    ylabel('trial');
    colorbar;
    set_colormap_threshold(gcf, [-.2 .2], [-1 1], [.5 .5 .5]);
end


