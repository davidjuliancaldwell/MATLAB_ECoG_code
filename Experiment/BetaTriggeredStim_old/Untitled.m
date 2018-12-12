Z_Constants;

% load(fullfile(META_DIR, 'allwins-c91479'), 't', 'allwins');

% determine the polarity of the artifact
muwins = squeeze(mean(allwins, 2));

chanmin = min(muwins);
chanmax = max(muwins);

polarity = zeros(size(allwins, 3), 1);

for chan=1:size(allwins, 3)
    if (find(muwins(:,chan)==chanmin(chan)) < find(muwins(:,chan)==chanmax(chan)))
        polarity(chan) = -1;
        
        allwins(:,:,chan) = -1*allwins(:,:,chan);
    else
        polarity(chan) = 1;
    end        
end

polarity(55:56) = 0;

rewins = reshape(allwins, [size(allwins,1), size(allwins,2)*size(allwins,3)]);
mu = mean(rewins, 2);

cwins = 0*allwins;
for chan = 1:size(allwins, 3)
    cwins(:,:,chan) = scaledExtract(mean(allwins(:,:,chan), 2), mu);
end


for d = 0:3
    figure
    for c = 1:16
        subplot(4,4,c);
        
        chan = d*16+c;
        
        plot(t, mean(cwins(:,:,chan),2));
        title(num2str(chan));
        xlim([min(t) max(t)]);
        ylim(1e-6*[-100 100]);
    end    
end

%%
dwins = [];
for chan = 1:size(allwins, 3)
    dwins(:,:,chan) = scaledExtract(mean(allwins(:,:,chan), 2), mu);
end


for d = 0:3
    figure
    for c = 1:16
        subplot(2,8,c);
        
        chan = d*16+c;
        
        plot(t, dwins(:,:,chan));
        title(num2str(chan));
        xlim([min(t) max(t)]);
        ylim(1e-6*[-100 100]);
    end    
end

