function projections = getEpProjections(data, coeffs, constants)
    % data is OBS x CHANS x T
    % filters is CHANS x T
    % constants is CHANS
    % pojections is OBS x CHANS
    
    OBS = size(data, 1);
    rcoeffs = repmat(shiftdim(coeffs, -1), [OBS 1 1]);    
    projections = dot(data, rcoeffs, 3) + repmat(constants', [OBS 1]);
end

% function projections = getEpProjections(data, filters)
%     % data is OBS x CHANS x T
%     % filters is NFILT x CHANS x T
%     
%     % pojections is OBS x (NFILT * CHANS)
%     
%     OBS = size(data, 1);
%     CHANS = size(data, 2);
%     T = size(data, 3);
%     
%     NFILT = size(filters, 1);
%     
%     ridx = repmat(1:CHANS, NFILT, 1);
%     rdata = data(:,ridx(:),:);
%     
%     rfilters = reshape(filters, [1 size(filters,1)*size(filters,2) size(filters, 3)]);
%     rfilters = repmat(rfilters, [OBS 1 1]);
%     
%     projections = dot(rdata, rfilters, 3);
% end