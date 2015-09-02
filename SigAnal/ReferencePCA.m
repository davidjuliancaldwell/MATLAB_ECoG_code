function referencedData = ReferencePCA(montage, bad_channels, data)
% data must be of format TxN where N is the number of channels
% mode can be either 'absolute' or 'threshold'

% using absolute mode, one explicitly states the number of components to be
% included in referenced data (via the parameter argument)

% using threshold mode, one chooses a threshold is a value between 0 and 1 
% that determines the number of components to be included in the 
% referencedData.  Closer to 0 means fewer components.

    isBad = false(size(data, 2), 1);
    isBad(bad_channels) = true;
    
    referencedData = zeros(size(data));
    
    last = 0;
    
    for montageElement = montage
        montageIndices = (last+1) : (last+montageElement);
        
        referencedData(:, montageIndices) = subReferencePCA(isBad(montageIndices), data(:, montageIndices));
        
        last = last + montageElement;
    end    
end

function referencedData = subReferencePCA(isBad, data)
    referencedData = data; % this leaves the bad channels alone
    
    covs = cov(data(:, ~isBad));
    
    if (~isempty(covs))

        [vecs, vals] = eig(covs);
        vals = diag(vals) / sum(diag(vals));
        
        count = 1; % number of PCs to drop
        sum(vals(1:(end-count)))

        projs = data(:, ~isBad) * vecs;

        for c = (size(vecs,2) - count + 1):size(vecs,2)
            vecs(:,c) = 0;     
        end; clear c;

        referencedData(:, ~isBad) = projs * pinv(vecs);
    end
    
%     referencedData = zeros(size(data));
%     
%     for n = 1:size(data,1)
%         for c = 1:size(vecs,2)-parameter
%             referencedData(n,:) = referencedData(n,:) + projs(n,c) * vecs(:,c)'; 
%         end; clear c;
%     end; clear n;
    
end