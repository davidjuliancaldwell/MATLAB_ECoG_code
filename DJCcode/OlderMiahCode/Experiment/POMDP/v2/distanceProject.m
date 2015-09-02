function [D, D_test] = distanceProject(data, labels, isTrain)
    % data should be obs x time
    % labels is obs x 1
    % isTrain is obs x 1
    
    data = GaussianSmooth(data, 25)';

    D = zeros(length(labels), 2);

    upt = mean(data(labels(isTrain), :),1);
    dnt = mean(data(~labels(isTrain), :),1);
    
    w = 10;

    for obs = 1:length(labels)
%         % using euclidean distance
%         ds(obs, 1) = pdist([data(obs,:);upt]);
%         ds(obs, 2) = pdist([data(obs,:);dnt]);

        % using dtw
        D(obs, 1) = dtw_c(data(obs,:)',upt', w);    
        D(obs, 2) = dtw_c(data(obs,:)', dnt', w);
    end
    
    if (nargout > 2)
        D_test = D(~isTrain, :);
    end    
end