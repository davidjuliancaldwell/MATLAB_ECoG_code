%%
% ups = GaussianSmooth(upsigs, parameters.SamplingRate/4)';
% downs = GaussianSmooth(downsigs, parameters.SamplingRate/4)';
ups = upsigs';
downs = downsigs';
upmean = mean(ups,1);
downmean = mean(downs,1);

figure(1);
subplot(1, 2, 1)
plot(t, upmean,t, downmean)
xlabel('time')
ylabel('response')
axis tight
subplot(1, 2, 2)
plot(t, var(ups),t, var(downs))
xlabel('time')
ylabel('variance')
axis tight

%%

upCov = cov(ups - repmat(upmean, size(ups,1), 1)); % do I need to remove the mean?
downCov = cov(downs - repmat(downmean, size(downs,1), 1));

[upVecs, upVals] = eigs(upCov, 3);
upVals = diag(upVals);

[downVecs, downVals] = eigs(downCov, 3);
downVals = diag(downVals);

figure;
subplot(211);
plot(upVals,'o');
xlabel('component')
ylabel('variance')
subplot(212);
plot(downVals,'o');
xlabel('component')
ylabel('variance')

%%

figure;
subplot(211);
plot(t, upVecs(:,1:3));
hold on;
plot(t, upcenter, 'k', 'LineWidth', 2);

subplot(212);
plot(t, downVecs(:,1:3));
hold on;
plot(t, downcenter, 'k', 'LineWidth', 2);

%%

projs = [ups * upVecs(:,1) ...
         ups * upVecs(:,2) ... 
         ups * upVecs(:,3)];

for c = 1:size(projs,1)
    delta = c / size(projs,1);
    colorspec = [0.0+delta 0.0 1-delta];
    plot3(projs(c,1), projs(c,2), projs(c,3), '*', 'Color', colorspec);
    hold on;
end

xlabel('PC 1');
ylabel('PC 2');
zlabel('PC 3');