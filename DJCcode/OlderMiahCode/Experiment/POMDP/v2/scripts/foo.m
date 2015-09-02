eps = squeeze(epochs(6,:,:,t>0&t<=fbDur));
f = getEpFilters(eps(:,:,:), labels);
proj = getEpProjections(eps, f);

for c = 1:2:176
gscatter(proj(:, c), proj(:, c+1), labels);
title(num2str((c+1)/2));
pause
end


tdata = proj(:,[15 16]);

% mudata = mean(tdata, 1);
% sigdata = std(tdata, 1);
% 
% zdata = (tdata-repmat(mudata, [size(tdata, 1), 1]))./repmat(sigdata, [size(tdata, 1), 1]);
 temp2 = tdata * CSP(tdata(~labels,:)', tdata(labels,:)')
z2data = mpca(tdata);

[a,b,c,d,e] = classify(z2data, z2data, labels);
K = e(1,2).const;
L = e(1,2).linear; 
f = @(x,y) K + [x y]*L;

gscatter(z2data(:,1),z2data(:,2), labels)
hold on;
h2 = ezplot(f,[min(z2data(:,1)) max(z2data(:,1)) min(z2data(:,2)) max(z2data(:,2))]);
set(h2,'Color','m','LineWidth',2)
hold off;