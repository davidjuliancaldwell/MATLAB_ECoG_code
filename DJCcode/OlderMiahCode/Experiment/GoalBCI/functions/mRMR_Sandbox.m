res = [];
nres = [];

for c = 1:100
    [hits, counts] = nFoldSVM(features, labels, 5, 'libsvm');            
    res(c) = mean(hits./counts);
end
mean(res)

dfeatures = discretizeFeatures(features);
rfeatures = mrmr_miq_d(dfeatures', double(labels), 15);
nfeatures = features(rfeatures,:);

for c = 1:100
    [hits, counts] = nFoldSVM(nfeatures, labels, 5, 'libsvm');            
    nres(c) = mean(hits./counts);
end
mean(nres)
[~,p]=ttest2(res,nres)