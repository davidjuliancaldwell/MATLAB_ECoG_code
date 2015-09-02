function difference = interpDifference(a, aIdxs, b, bIdxs)
    assert(length(aIdxs) == length(bIdxs), 'Length of Index Chains Different');
    assert(length(a) == sum(aIdxs), 'a vector length doesn''t match number of ones in aIdxs');
    assert(length(b) == sum(bIdxs), 'b vector length doesn''t match number of ones in bIdxs');
    
   aRes = zeros(size(aIdxs));
   aRes(aRes == 0) = NaN;
   aRes(aIdxs) = a;
   
   bRes = zeros(size(bIdxs));
   bRes(bRes == 0) = NaN;
   bRes(bIdxs) = b;
   
   difference = interpNans(aRes) - interpNans(bRes);

end

function interpolated = interpNans(raw)
    assert(sum(~isnan(raw)) ~= 0, 'No non-nan values to use as foundation');
    
    reals = ~isnan(raw);
    
    startIdx = find(reals, 1, 'first');
    bookmark = startIdx;
    
    for c = startIdx:-1:1
        if(isnan(raw(c))) % needs interpolation
            [value, idx] = findNeighbor(raw, c, -1);
            if (idx ~= -1)
                raw(c) = value + (raw(bookmark) - value) / (bookmark - idx);
            else
                raw(c) = raw(bookmark);
            end
        end
        bookmark = c;        
    end

    for c = startIdx:length(raw)
        if(isnan(raw(c))) % needs interpolation
            [value, idx] = findNeighbor(raw, c, 1);
            if (idx ~= -1)
                raw(c) = raw(bookmark) + (value - raw(bookmark)) / (idx - bookmark);
            else
                raw(c) = raw(bookmark);
            end
        end
        bookmark = c;        
    end
    
    interpolated = raw;
end

function [value, idx] = findNeighbor(data, current, step)
    ctr = current + step;
    while(ctr >= 1 && ctr <= length(data))
        if(~isnan(data(ctr)))
            value = data(ctr);
            idx = ctr;
            return;
        end
        ctr = ctr + step;
    end
    
    value = 0;
    idx = -1;
end