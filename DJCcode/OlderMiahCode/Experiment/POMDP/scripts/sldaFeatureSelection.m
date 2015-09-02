function featureWeights = sldaFeatureSelection(features)
    error incomplete
    % parameters
    CVAL_FOLDS = 5;
    
    % SLDA parameters
    delta = 1e-3; % l2-norm constraint
    stop = -10; % request 30 non-zero variables
    maxiter = 250; % maximum number of iterations
    Q = 1; % request two discriminative directions
    convergenceCriterion = 1e-6;

    cp = cvpartition(size(features, 1), 'kfold', CVAL_FOLDS);
    
    for n = 1:CVAL_FOLDS
        B = slda(
%             % select features
%             B = slda(X_train, double(binLabel(tri, :)), delta, stop, Q, maxiter, convergenceCriterion);
%             
%             dX_train = X_train*B;
%             dX_test = X_test*B;
%                         

    % break the features in to some number of folds
    
    % for each fold
    % find the best features
    %
    % sort by selection occurence, return the m best features from that
    % list
end