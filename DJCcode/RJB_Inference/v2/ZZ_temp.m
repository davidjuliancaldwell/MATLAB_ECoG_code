% load('D:\research\code\output\POMDP\meta\7662c2_epochs_raw.mat')
fw = 1:200;
tic; [~,~,call,~] = time_frequency_wavelet(squeeze(epochs(:,30,:))', fw, fs, 1, 1, 'CPUtest'); toc;

%%
zt = t-min(t);

ncall = abs(call);
mu = mean(ncall(zt>.2 & zt <=1, :, :), 1);
sig = std(ncall(zt>.2 & zt <=1, :, :), [], 1);

zcall = (ncall-repmat(mu, [size(ncall, 1) 1 1])) ./ repmat(sig, [size(ncall, 1) 1 1]);

%%
for obs = 1:size(zcall, 3)
    imagesc(t, fw, squeeze(zcall(:, :, obs))'); 
    axis xy
    x=5;
    set_colormap_threshold(gcf, [-2 2], [-10 10], [1 1 1]);
end

%%
dsfac = 100;

res = zeros(size(zcall,1)/dsfac, size(zcall, 2), size(zcall, 3));

for obs = 1:size(zcall, 3)
    res(:,:,obs) = resample(zcall(:,:,obs), 1, dsfac);
end

%%

sr2 = zeros(size(res, 1), size(res, 2));

for f = 1:length(fw)
    temp = corr(squeeze(res(:, f, :))', tgts==1);
    sr2(:, f) = sign(temp) .* temp.^2;
end

imagesc( sr2');
axis xy
colorbar

%%

pall = permute(res(30:60,fw>70&fw<120,:), [3 2 1]);
pall = reshape(pall, [size(pall, 1), size(pall,2)*size(pall,3)]);

foo = pdist(pall);
proj = mdscale(foo, 2);

gscatter(proj(:,1), proj(:, 2), tgts)