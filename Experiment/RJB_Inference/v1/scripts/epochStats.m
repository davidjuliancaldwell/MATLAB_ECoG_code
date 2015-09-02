function [h, p, t] = epochStats(x, y, bads, correctionType)
    if (~exist('correctionType', 'var'))
        correctionType = 'fdr';
    end
        
    if (strcmpi(correctionType, 'fdr'))
        [~, p, ~, tempStats] = ttest2(x, y, 'Dim', 2, 'Vartype', 'Unequal');        
        [~,h] = fdr(p, 0.05);
    elseif (strcmpi(correctionType, 'bonf'))
        [h, p, ~, tempStats] = ttest2(x, y, 'Dim', 2, 'Vartype', 'Unequal', 'alpha', 0.05 / (size(x, 1) - length(bads)));        
        h = h==1;
    elseif (strcmpi(correctionType, 'none'))
        [h, p, ~, tempStats] = ttest2(x, y, 'Dim', 2, 'Vartype', 'Unequal', 'alpha', 0.05);        
        h = h==1;
    end
    t = tempStats.tstat;
    
    % correct for the bad channels
    p(bads) = NaN;
    h(bads) = 0;
    t(bads) = NaN;
end