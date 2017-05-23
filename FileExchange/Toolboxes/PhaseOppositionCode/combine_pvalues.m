function result = combine_pvalues(pmatrix,dim,method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright Rufin VanRullen, 2016% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%usage: result = combine_pvalues(pmatrix,dim,[method]);
%Combines p-values across different independent observations (e.g. experimental
%subjects). The resulting p-value reflects the null hypothesis that the
%individual null hypothesis for the different observations were ALL true.
%The combination is performed across dimension dim, and the result matrix
%has one less dimension than the input pmatrix.
%The combination can be performed with various methods, which differ in how
%liberal or conservative they are:
%1=Stouffer: each p-value is turned into an equivalent z-score, the z-scores 
%   are combined and turned back into probabilities     [default]
%2=Fisher: combination in the log domain, the null hypothesis follows a 
%   chi-square distribution with 2N dof. 
%3=Edgington: sum p-values across N observations, then compare to the null 
%   hypothesis which is the sum of N uniform random variables, whose null 
%   distribution is derived from the central limit theorem.
%4=Tippett: find lowest p-value, elevate its complement (1-p) to the power
%   of N, then take the complement
%5=Friston: elevate largest p-value to the power of N (conservative)
if nargin < 3
    method = 1;
end;
switch method
    case 1 %Stouffer
       result = squeeze(1-normcdf(sum(norminv(1-pmatrix),dim)./sqrt(size(pmatrix,dim))));
    case 2 %Fisher
        result = chi2cdf(squeeze(-2*sum(log(pmatrix),dim)),2*size(pmatrix,dim),'upper');
    case 3 %Edgington
        result = squeeze(normcdf(sum(pmatrix,dim),0.5*size(pmatrix,dim),sqrt(size(pmatrix,dim)/12))); 
    case 4 %Tippett
        result = squeeze(1-(1-min(pmatrix,[],dim)).^size(pmatrix,dim));
    case 5 %Friston
        result = squeeze((max(pmatrix,[],dim)).^size(pmatrix,dim));
end;

