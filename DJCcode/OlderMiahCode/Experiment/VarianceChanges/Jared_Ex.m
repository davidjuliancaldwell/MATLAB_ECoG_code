isint = targets ~= 1 & targets ~= ntargets;

figure
imagesc(GaussianSmooth2(ztime(:,targets==ntargets), [100 10], [30, 3])'); title down
colorbar
set(gca, 'clim', [1.5 3.6])
figure
imagesc(GaussianSmooth2(ztime(:,targets==1), [100 10], [30, 3])'); title up
colorbar
set(gca, 'clim', [1.5 3.6])
figure 
imagesc(GaussianSmooth2(ztime(:,isint), [100 10], [30, 3])'); title int
colorbar
set(gca, 'clim', [1.5 3.6])


prettyline(GaussianSmooth(ztime(:,ntargets==5), 1), targets(ntargets==5))

mu = std(ztime(1000:2500,:), [], 1);


early = false(size(mu));
early(1:450) = true;

showFeatures(mu(ntargets==5 & early'), targets(ntargets==5 & early'));


showFeatures(mu(ntargets==5 & ~early'), targets(ntargets==5 & ~early'));
