fs = 120;

ts = zeros(3*fs, size(timeSeries, 2), size(timeSeries, 1));

for epoch = 1:size(timeSeries,2)
    for chan = 1:size(timeSeries,1)
        ts(:, epoch, chan) = timeSeries{chan, epoch}(fs:(fs*4-1));
    end
end

%%
isup = ismember(targets, 1:4);
isdown = ismember(targets, 5:8);
%%

PlotTrajectory(permute(ts(:,isup,[4 12 13]),[1 3 2]), [1 0 0]);
PlotTrajectory(permute(ts(:,isdown,[4 12 13]),[1 3 2]), [0 0 1], false);

%%

figure, plot(squeeze(tsr(:,12,isup)),'r');
hold on;
plot(squeeze(tsr(:,12,isdown)),'b');
plot(mean(tsr(:,12,isup),3),'r', 'linewidth',3);
plot(mean(tsr(:,12,isdown),3),'b','linewidth',3);

%%
ts(1:100)
tsr = reshape(ts, 360*129, 64);
[proj, filt, varfrac] = mpca(tsr);

Yr = proj(:,1:3);
Y = reshape(Yr, 360, 129, 3);

X = zeros(size(Y, 1), size(Y, 3), size(Y, 2));
for c = 1:size(Y, 3)
    X(:, c, :) = Y(:, :, c);
end
    
PlotTrajectory(X(:,:,isup), [1 0 0]);
PlotTrajectory(X(:,:,isdown), [0 0 1], false);


