function [vals, h] = signedSquaredXCorrValue (a, b, dim, alpha)
    if (ndims(a) > 2 || ndims(b) > 2)
        error('inputs must be matrices or vectors');
    end
    
    if ~exist('dim','var')
        dim = 1;
    end
    
    if ~exist('alpha', 'var')
        alpha = 0.05;
    end
    
    if dim == 1
        if size(a,2) ~= size(b,2)
            error('the sliced dimensions of a and b must be the same length');
        end
        len = size(a,2);
        szA = size(a,1);
        szB = size(b,1);  
    elseif dim == 2
        if size(a,1) ~= size(b,1)
            error('the sliced dimensions of a and b must be the same length');
        end
        len = size(a,1);
        szA = size(a,2);
        szB = size(b,2);  
    else
        error('inappropriate value given for dim');
    end

    vals = zeros(len,1);
    
    if (nargout > 1)
        cVal = getCriticalValue(szA, szB, alpha);
    end
    
    for c = 1:len
        switch(dim)
            case 1
                vals(c) = signedSquaredXCorrValueV(a(:,c), b(:,c));
            case 2
                vals(c) = signedSquaredXCorrValueV(a(c,:), b(c,:));
        end
    end    
    
    if (nargout > 1)
        h = abs(vals) > cVal;
    end
    
end
  
function cVal = getCriticalValue(n1, n2, alpha)
    cVal = lookUpCriticalValue(n1, n2, alpha);
    
    if (isnan(cVal))
        cVal = computeCriticalValue(n1, n2, alpha);
        storeCriticalValue(n1, n2, alpha, cVal);
    end
end

function cVal = lookUpCriticalValue(n1, n2, alpha)
    alphaIdx = round(alpha*10000);

    if(alphaIdx - (alpha*10000) ~= 0)
%         warning('alpha value was rounded in signedSquaredXCorrValue->lookUpCriticalValue\n');
    end
    
    if(alphaIdx == 0)
        warning('alpha value too low for storage');
        cVal = NaN;
        return;
    end   
    
    cacheFile = [myGetenv('matlab_devel_dir') '\SigAnal\signedSquaredXCorrValue.cache.mat'];
    load(cacheFile);
    if (size(criticalValues,1) >= n1 && size(criticalValues,2) >= n2 && size(criticalValues,3) >= alphaIdx)
        if (criticalValues(n1, n2, alphaIdx) ~= 0)
            cVal = criticalValues(n1, n2, alphaIdx);
        else
            cVal = NaN;
        end
    else
        cVal = NaN;
    end
end

function storeCriticalValue(n1, n2, alpha, cVal)
    alphaIdx = round(alpha*10000);

    if(alphaIdx - (alpha*10000) ~= 0)
        warning('alpha value was rounded in signedSquaredXCorrValue->lookUpCriticalValue\n');
    end
    
    if(alphaIdx == 0)
        warning('alpha value too low for storage');
        return;
    end

    cacheFile = [myGetenv('matlab_devel_dir') '\SigAnal\signedSquaredXCorrValue.cache.mat'];
    load(cacheFile);
    criticalValues(n1, n2, alphaIdx) = cVal;
    save(cacheFile, 'criticalValues');
end

function cVal = computeCriticalValue(n1, n2, alpha)
    rsas = zeros(size(1:10000));
    ps   = zeros(size(1:10000));

    for c = 1:10000
        s1 = random('unif', 0.1, 10);
        s2 = random('unif', 0.1, 10);

        m1 = random('unif', 0.1, 10);
        m2 = random('unif', 0.1, 10);

        a = random('norm',m1, s1^2 ,[n1,1]);
        b = random('norm',m2, s2^2 ,[n2,1]); 

        rsas(c) = signedSquaredXCorrValueV(b,a);
        [~, ps(c)] = ttest2(a, b);
    end

    diff = ps-alpha;
    diff(diff > 0) = -Inf;

    [~, index] = max(diff);

    cVal = abs(rsas(index));

%         figure;
%         plot(ps, rsas, '.');
%         hold on;
%         plot(ps(index), cVal, 'r.');

end

function val = signedSquaredXCorrValueV (a, b)
    if (sum(size(a) > 1) > 1) || (sum(size(b) > 1) > 1)
        error('inputs must be vectors');
    end
    
    if (size(a,1) == 1) 
        a = squeeze(a)';
    end
    if (size(b,1) == 1)
        b = squeeze(b)';
    end
    
    val = ((mean(a)-mean(b)).^3) * length(a) * length (b) ./ ...
        ((abs(mean(a) - mean(b)) * var([a;b])) * (length(a) + length(b))^2);
end