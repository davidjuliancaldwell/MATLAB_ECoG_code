function [CI_lo CI_hi sgc] = erp_perm_test (data1,data2,Nperm,sp)
% Returns the top and bottom confidence intervals of a paired comparison of
% ERPs from 2 conditions
%
% [CI_lo CI_up sgc] = erp_perm_test (data1,data2,Nperm,sp)
%
% data1,2   ERP matrices (ntrials x nsamples)
% Nperm     n. of permutations
% sp        significance percentile (e.g. 0.05, or set to 0 for max/min)
% CI_lo/up  confidence intervals (lower/upper)
% sgc       significance curve (for each sample,
%           1: mean data1/2 significantly different)

n1 = size(data1, 1);
n2 = size(data2, 1);

data = cat(1,data1,data2);
dd = nan(Nperm,size(data1,2));
for ip = 1:Nperm
    redata = data(randperm(size(data,1)),:); % shuffle trials
    d1 = redata(1:n1,:); % 1st surrogate "condition"
    d2 = redata((n1+1):end,:); % 2nd surrogate "condition"
        
    dd(ip,:) = mean(d1, 1) - mean(d2, 1); % surrogate difference b/w the 2 "conditions"
end

for is = 1:size(dd,2)
    p = dd(:,is);
    if sp~=0
        pl = prctile(p,100*(sp/2));
        ph = prctile(p,100*(1-sp/2));
    else
        pl = min(p);
        ph = max(p);
    end
    CI_lo(is) = pl;
    CI_hi(is) = ph;
end

diff = mean(data1,1)-mean(data2,1);
sgc1 = diff>CI_hi;
sgc2 = diff<CI_lo;
sgc = sgc1|sgc2;

end
