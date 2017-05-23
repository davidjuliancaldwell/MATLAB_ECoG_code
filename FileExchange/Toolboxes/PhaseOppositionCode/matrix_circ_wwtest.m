function [pmatrix, Fmatrix] = matrix_circ_wwtest(alpha1,alpha2,ITCthreshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright Rufin VanRullen, 2016% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%usage: [pmatrix, Fmatrix] = matrix_circ_wwtest(alpha1,alpha2,[ITCthreshold])
%Matrix version of the circ_wwtest function from the circstats toolbox,
%adapted for our purposes. alpha1 and alpha 2 are matrices of identical
%dimensions, except for the last one, representing the trial number in each
%of 2 experimental conditions. Matrix entries are complex numbers, whose
%phase distributions are compared across the 2 conditions. Two result
%matrices are returned, one with the p-value, the other with the
%corresponding F statistic. These matrices have one less dimension than the
%input matrices.
%The circular Watson-Williams test is only defined for phase distributions
%of non-zero concentration. To prevent unreliable results, a criterion
%ITCthreshold is applied to the mean resultant vector length across the two
%conditions, rw > ITCthreshold * ITCbaseline,
%where ITCbaseline is the expected ITC from a uniform distribution. This
%criterion is arbitrary, and can mask significant phase differences when
%too conservative, or generate spurious results when too liberal. The
%default value is ITCthreshold=2. Try changing this value when the function 
%returns illogical results. 

if nargin < 3
    ITCthreshold = 2;
end;
%r is the resultant vector length over all data
%rw is the mean of the resultant vector length for the 2 conditions
dim = length(size(alpha1));
fullmatrix = cat(dim,alpha1,alpha2);
n1=size(alpha1,dim);
n2=size(alpha2,dim);
n = n1+n2;

r = squeeze(abs(mean(fullmatrix ./ abs(fullmatrix),dim)));
rw = (n1*squeeze(abs(mean(alpha1 ./ abs(alpha1),dim))) + n2*squeeze(abs(mean(alpha2 ./ abs(alpha2),dim))))/n;

%we need the kappa value, but circ_kappa also doesn't work with matrices.
%kk = circ_kappa(rw);
%working from rw the mean resultant length vector (scalar)
kappa = zeros(size(rw));
id1 = rw < 0.53;
id2 = rw>=0.53 & rw<0.85;
id3 = rw>=0.85;

kappa(id1) = 2*rw(id1) + rw(id1).^3 + 5*rw(id1).^5/6;
kappa(id2) = -.4 + 1.39*rw(id2) + 0.43./(1-rw(id2));
kappa(id3) = 1./(rw(id3).^3 - 4*rw(id3).^2 + 3*rw(id3));

beta = 1+3./(8*kappa);    % correction factor
A = n * (rw-r);
B = n * (1 - rw);

Fmatrix = beta .* (n-2) .* A ./ 1 ./ B;
pmatrix = 1 - fcdf(Fmatrix,1,n-2);

%correction: points that don't have enough phase-locking are reset to F=0,p=1;
%WARNING: This correction involves an arbitrary criterion!!!
idbad = rw <= ITCthreshold*ITCbaseline(n);
pmatrix(idbad) = 1;
Fmatrix(idbad) = 0;

%avoid p=0 and p=1
pmatrix = min(1-1/10^16,max(1/10^16,pmatrix));