load ./data;
features = features(4*64+(1:64),:);

% load fisheriris
% labels = NaN*zeros(size(species))';
% 
% for c = 1:length(labels)
%     switch(species{c})
%         case 'setosa'
%             labels(c) = 0;
%         case 'versicolor'
%             labels(c) = 1;
%         case 'virginica'
%             labels(c) = 2;
%     end
% end; clear c species
% 
% if (any(isnan(labels)))
%     error error
% end
% 
% features = meas'; clear meas;
% 
% drops = labels >= 2;
% features(:, drops) = [];
% labels(drops) = [];
% clear drops;
% 
% is = randperm(length(labels));
% features = features(:, is);
% labels = labels(is);

% showFeatures(features, labels);
% drawnow;

tic
[acc,est,post] = mCrossvalLDA(features, labels, 5);
acc
confusionmat(labels, est==1)
toc

% tic
% % this one has problems because we repartition the data every time we call
% % nFoldSVM, which means that "best" performance, could also just be "most
% % fortunate" partitioning scheme...
% acc = parameterSweepingNFoldSVM(features, labels', 5)
% toc