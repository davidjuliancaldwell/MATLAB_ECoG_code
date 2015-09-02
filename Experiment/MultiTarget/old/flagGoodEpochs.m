function [goodFlags, flaggingChannels] = flagGoodEpochs(sig, starts, ends, allowableRange)
% sig is a CxT matrix
% starts is a 1-D vector
%   starts(1) >= 1
% ends is a 1-D vector, same size as starts, starts(i) < ends(i),
%   ends(end) <= T
% allowableRange is a 2x1 (or 1x2) vector
    goodFlags = zeros(length(starts), 1);
    
    if (exist('flaggingChannels', 'var'))
        warning('flagging channel hunt not implemented');
        flaggingChannels = cell(length(starts, 1));
    end
    
    for idx = 1:length(starts)
        m = sig(:,starts(idx):ends(idx)); 
        below = sum(sum(m < allowableRange(1)));
        above = sum(sum(m > allowableRange(2)));
        hasnan = sum(sum(isnan(m)));
        goodFlags(idx) = ~below && ~above && ~hasnan;
        if (~goodFlags(idx) && exist('flaggingChannels', 'var'))
            % todo
        end 
    end
end