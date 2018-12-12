%% 2-23-2016, Stavros Shuffling code

function [CI_lo,CI_hi,sgc] = stavrosShuffle (data1,data2,Nperm,sp)

% Returns the confidence intervals of a comparison (on a sample-by-sample basis)
% of event-related potentials from 2 conditions
%
% [CI_lo CI_hi sgc] = erp_perm_test (data1,data2,Nperm,sp)
%
% data1,2 ERP matrices (nsamples x ntrials)
% Nperm n. of permutations
% sp significance; e.g. 95: difference b/w conditions is beyond
% the top/bottom 95th percentile (pos/nega difff, respectively).
% Or set to 0 to compare to max/min.
% CI_lo/hi confidence intervals (lower/higher)
% sgc significance vector (for a given sample 1 means that
% mean(data1) and mean(data2) are significantly different)
%
% Written by Stavros Zanos, Summer 2013
%
% Method: Greenblatt & Pflieger, "Randomization-based hypothesis testing
% from event-related data", Brain Topography 16(4)

data = cat(2,data1,data2);
dd = nan(size(data1,1),Nperm);
for ip = 1:Nperm
    redata = data(randperm(size(data,1)),:); % shuffle trials
    d1 = redata(:,1:floor(size(data1,2))); % 1st surrogate "condition"
    d2 = redata(:,floor(size(data1,2))+1:end); % 2nd surrogate "condition"
    
    % mean or median? 
    dd(:,ip) = median(d1,2) - median(d2,2); % surrogate difference b/w the 2 "conditions"
end

CI_lo = nan(size(dd,1),1);
CI_hi = nan(size(CI_lo));
for is = 1:size(dd,1)
    p = dd(is,:);
    
    if sp~=0
        pl = prctile(p,100-sp);
        ph = prctile(p,sp);
    else
        pl = min(p);
        ph = max(p);
    end
    
    CI_lo(is) = pl;
    CI_hi(is) = ph;
end

diffm = nanmedian(data1,2)-nanmedian(data2,2);
sgc1 = diffm>CI_hi;
sgc2 = diffm<CI_lo;
sgc = sgc1|sgc2;

end
