% plot some basic things like subject coverage
tcs;
Constants;

res = {};

for c = 1:length(SIDS)    
    fprintf('subjectIdx: %d\n', c);

    subjid = SIDS{c};
    subcode = SUBCODES{c};
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)));

    droppers = targets == 9;
    targets(droppers) = [];
    results(droppers) = [];
    
    % build the feature set(s)
    for featureIdx = 1:4
        fprintf(' featureIdx: %d\n', featureIdx);
        switch(featureIdx)
            case 1
                features = reshape(shiftdim(tgtMeans,2), [size(tgtMeans,1)*size(tgtMeans,3) size(tgtMeans,2)]);
%                 features = tgtMeans(:,:,5);
            case 2
                features = reshape(shiftdim(holdMeans,2), [size(holdMeans,1)*size(holdMeans,3) size(holdMeans,2)]);                
%                 features = holdMeans(:,:,5);
            case 3
                features = reshape(shiftdim(preFbMeans,2), [size(preFbMeans,1)*size(preFbMeans,3) size(preFbMeans,2)]);                
%                 features = preFbMeans(:,:,5);
            case 4
                features = reshape(shiftdim(fbMeans,2), [size(fbMeans,1)*size(fbMeans,3) size(fbMeans,2)]);                
%                 features = fbMeans(:,:,5);
        end
        
        features(:, droppers) = [];

        for characteristicIdx = 1:3
            fprintf('  characteristicIdx: %d\n', characteristicIdx);
            switch (characteristicIdx)
                case 1
                    labels = ismember(targets, UP); mtitle = 'up v down';
                case 2
                    labels = ismember(targets, NEAR); mtitle = 'near v far';
                case 3
                    labels = ismember(targets, BIG); mtitle = 'big v small';
            end            
            [hits, counts] = nFoldSVM_mRMR(features, labels, 5, 'libsvm');            
            acc{c}(featureIdx, characteristicIdx) = mean(hits./counts);

%             [ acc{c}(featureIdx, characteristicIdx), ...
%               cCoeffs{c}(featureIdx, characteristicIdx), ...
%               gammas{c}(featureIdx, characteristicIdx)] = parameterSweepingNFoldSVM(features, labels, 5);
        end            
    end    
end

%%
for c = 1:length(SIDS)    
    figure, plot(acc{c});
    title(num2str(c));
    xlabel('phase');
    ylabel('acc');
    legend({'up v down','near v far','big v small'});
    ylim([.3 1]);
end
% 
% save(fullfile(META_DIR, 'offline-class.mat'), 'acc', 'cCoeffs', 'gammas');
% 
% %% could potentially do something here where we interpret the coefficients of the SVM for the best models...
% % might say something meaningful about relative importance of various
% % electrodes
