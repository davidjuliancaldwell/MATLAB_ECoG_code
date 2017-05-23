function [p_circWW, p_POS, p_zPOS] = PhaseOpposition(data1, data2, nperm, circww_ITCthreshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright Rufin VanRullen, 2016%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This and associated functions are provided without explicit or implied
%guarantee, and without any form of technical support.
%The function is free to use for any personal, scientific or commercial
%application. When using this function in any published study, please
%cite: "VanRullen, R. (2016). How to evaluate phase differences between
%trial groups in ongoing electrophysiological signals. (submitted)"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Usage: [p_circWW, p_POS, p_zPOS] = PhaseOpposition(data1, data2, [nperm], [circww_ITCthreshold])
%Computes p-values of phase opposition for a dataset using 2 methods, the
%circular Watson-Williams test and the phase opposition sum. For the
%latter, two statistical procedures are employed, a standard permutation
%test and a hybrid test using the mean and standard deviation of the null
%distribution obtained from the permutations to derive a z-score and,
%finally, a more precise p-value.
%The function operates on N-dimensional matrices of complex numbers.
%If data1/2 contain non-unit norm complex numbers, they will be normalized
%If data1/2 contain only real numbers, we assume that they represent phase
%angle (in radians).
%The function operates on the last (Nth) dimension, representing trials.
%Trials in data1 are associated with one task outcome, and in data2 with
%another task outcome. The first N-1 dimensions may represent
%anything, most likely time, frequency (obtained from any time-frequency
%transform) and electrodes/channels.
%
%For datasets with multiple subjects (and likely different trial numbers, 
%run this function for each subject and combine the resulting maps of 
%p-values using the function combine_pvalues (included in this folder).
%
%Inputs:
%   -data1: N-dimensional matrix of complex phase values or real angles (in
%   radians) for trial group 1
%   -data2: N-dimensional matrix of complex phase values or real angles (in
%   radians) for trial group 2
%   -[nperm]: number of permutations for non-parametric (POS) test
%   [default 1000]
%   -[circww_ITCthreshold]: minimum ITC criterion used by the circular WW
%   test to reject inappropriate data. Try changing this value when getting
%   illogical results [default 3]
%
%Outputs:
%   -p_circWW: N-1-dimensional matrix of p-values obtained from the
%   circular Watson-Williams test
%   -p_POS: N-1-dimensional matrix of p-values obtained from the POS
%   measure and a comparison with a surrogate distribution of permutations
%   -p_zPOS: N-1-dimensional matrix of p-values obtained from the POS
%   measure and a zscore against the surrogate distribution of permutations


if nargin < 3
    nperm = 1000;
end;
if nargin < 4
    circww_ITCthreshold = 3; %used as a criterion in circWW test
end;

N = length(size(data1));
if length(size(data2))~=N
    fprintf('Exiting - data1 and data2 should have the same number of dimensions\n');
    return;
end;
alldata = cat(N,data1,data2);

%reformat data if necessary
if isreal(alldata(:)) %not complex numbers
    fprintf('Not complex numbers, reformatting angles to complex values\n');
    alldata = exp(sqrt(-1).*alldata);
    data1 = exp(sqrt(-1).*data1);
    data2 = exp(sqrt(-1).*data2);
end;
if max(abs(abs(alldata(:))-1))>0.00001 %non-unit norm
    fprintf('Complex numbers with non-unit norm, normalizing\n');
    alldata = alldata ./ abs(alldata);
    data1 = data1 ./ abs(data1);
    data2 = data2 ./ abs(data2);
end;

%compute circular Watson-Williams test
fprintf('Computing circular Watson-Williams test...');
[p_circWW, Fmatrix] = matrix_circ_wwtest(data1,data2,circww_ITCthreshold);
fprintf(' done.\n');

%check p_circWW. If suspicious, output warning message about circww_ITCthreshold
significantpoints = sum(p_circWW(:)<0.001) / length(p_circWW(:));
if significantpoints<0.001 || significantpoints>0.33
    fprintf('   WARNING: there seem to be too many or too few significant points in the p_circWW matrix.\n');
    fprintf('   Check consistency with p_POS and p_zPOS. If results are unsatisfactory, it is most likely\n');
    fprintf('   due to the minimum ITC criterion of the circWW test. Too strict a criterion can hide\n');
    fprintf('   meaningful effects, too liberal and all points become ''significant''\n');
    fprintf('   The current value for this criterion is %3.4f\n',circww_ITCthreshold);
    fprintf('   We recommend adapting this criterion as needed.\n');
end;

%compute POS values (only sum, no baseline correction to facilitate
%surrogate comparisons)
fprintf('Computing POS and surrogates.');
POS = squeeze(abs(mean(data1,N)) + abs(mean(data2,N)));

%compute POS surrogates. To save memory, the distribution is not saved, but
%its mean and standard deviation, as well as the p_value count, are
%calculated iteratively.
mPOS = zeros(size(POS)); %to store running mean
sPOS = zeros(size(POS)); %to store running std
nPOS = zeros(size(POS));  %to store running count
for s=1:nperm
    if ~rem(s-1,ceil(nperm/10)), fprintf('.'), end;
    order = randperm(size(alldata,N));
    perm1 = order(1:size(data1,N));
    perm2 = order(size(data1,N)+1:end);
    %need to construct the index strings to pass to eval
    indexstring1 = 'alldata('; for i=1:N-1, indexstring1=[indexstring1 ':,']; end; indexstring1 = [indexstring1 'perm1)'];
    indexstring2 = 'alldata('; for i=1:N-1, indexstring2=[indexstring2 ':,']; end; indexstring2 = [indexstring2 'perm2)'];
    surrogatePOS = squeeze(abs(mean(eval(indexstring1),N)) + abs(mean(eval(indexstring2),N)));
    mPOS = mPOS+surrogatePOS;
    sPOS = sPOS+surrogatePOS.^2;
    nPOS = nPOS + double(surrogatePOS>POS);
end;
mPOS = mPOS / nperm;
sPOS = sqrt((sPOS/nperm)-mPOS.^2);
nPOS(nPOS==0) = 0.5;
%compute probabilities from permutations
p_POS = nPOS/nperm;
p_zPOS = min(1-10^-20,max(10^-20,1-normcdf((POS-mPOS)./sPOS)));
fprintf( 'done.\n')