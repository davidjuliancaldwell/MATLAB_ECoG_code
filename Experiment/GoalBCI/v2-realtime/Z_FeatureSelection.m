% constants
addpath ./functions
addpath ./xval

Constants;



%%

acc = [];

for c = 1:4%1:length(SIDS)    
    fprintf('********** subject %d **********\n', c);
    sid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, Montage, ctl] = goalDataFiles(sid);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)));
        
    drops = targets==9;
    targets(drops) = [];
        
    isUp = ismember(targets, UP);
    
    if (c == 3)
        preFbMeans = preFbMeans(1:62, :, :);
    end
    
    mfeatures = preFbMeans(:,~drops,:);
    features = zeros(size(mfeatures,1)*size(mfeatures,3), size(mfeatures,2));

    for d = 1:size(mfeatures, 3)
        idxs = (1:size(mfeatures,1)) + (d-1)*size(mfeatures,1);
        features(idxs,:) = mfeatures(:,:,d);
    end
%     showFeatures(features, isUp);
    acc(c) = mCrossval(features, isUp, 5);        
end

disp (acc);
