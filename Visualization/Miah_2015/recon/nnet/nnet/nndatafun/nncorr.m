function c = nncorr(a,b,varargin)
%NNCORR Cross-correlation between neural time series.
%
% C = <a href="matlab:doc nncorr">nncorr</a>(A,B,MAXLAG,'FLAG') returns an NxM cell array of correlations
% between neural data time-series A and B, were N is SUM(NUMELEMENTS(A)),
% M is SUM(NUMELEMENTS(B)).
%
% Each Cnmq = C{n,m} is a 2*MAXLAG+1 length row vector formed from the
% correlations of Anq = <a href="matlab:doc getelements">getelements</a>(A,n) and Bmq = <a href="matlab:doc getelements">getelements</a>(B,m).
%
% If A and B are in matrix form, then columns are interpreted as different
% timesteps instead of different samples.
%
% If A and B are row vectors then the result is returned in matrix form.
% 
% The unnormalized correlation expression is:
%
%   Cnmq(i) = [Anq(...)] & [Bmq(...)]'
%   
% The optional FLAG determines how NNCORR normalizes correlations.
%   'biased'   - scales the raw cross-correlation by 1/N.
%   'unbiased' - scales the raw correlation by 1/(N-abs(k)), where k 
%                is the index into the result.
%   'coeff'    - normalizes the sequence so that the correlations at 
%                zero lag are identically 1.0.
%   'none'     - no scaling (this is the default).
%		
% For example:
% 
%   a = <a href="matlab:doc nndata">nndata</a>(1,1,20) % Random 1 element, 1 sample, 20 timesteps
%   aa = <a href="matlab:doc nncorr">nncorr</a>(a,a,10) % Auto-correlation of A, maximum lag of 10
% 
%   b = <a href="matlab:doc nndata">nndata</a>(2,1,20) % Random 2 elements, 1 sample, 20 timesteps
%   ab = <a href="matlab:doc nncorr">nncorr</a>(a,b,8) % Correlation of A and B, maximum lag of 8

% Copyright 2010-2011 The MathWorks, Inc.

% Format & Check
if nargin < 1, error(message('nnet:Args:NotEnough')); end
aMatrix = ~iscell(a);
bMatrix = ~iscell(b);
a = nntype.data('format',a,'A');
b = nntype.data('format',b,'B');
if aMatrix, a = con2seq(a{1}); end
if bMatrix, b = con2seq(b{1}); end
[maxlag,flag] = nnmisc.defaults(varargin,{nnfast.numtimesteps(a)-1},'unbiased');
maxlag = nntype.pos_int_scalar('format',maxlag,'MAXLAG');
if ~ischar(flag) || isempty(nnstring.first_match(flag,{'unbiased','biased','coeff','none'}))
    error(message('nnet:nncorr:UnrecFlag'));
end

[N1,Q1,TS1,M1] = nnfast.nnsize(a);
[N2,Q2,TS2,M2] = nnfast.nnsize(b);
N1 = sum(N1);
N2 = sum(N2);
if TS1 ~= TS2
	error(message('nnet:NNData:ABTimestepMismatch'));
end
if Q1 ~= Q2
	error(message('nnet:NNData:ABSampleMismatch'));
end
if (M1 ~= 1)
  error(message('nnet:NNData:ANotSingleSignal'));
end
if (M2 ~= 1)
  error(message('nnet:NNData:BNotSingleSignal'));
end
if maxlag >= TS1
  error(message('nnet:nncorr:MAXLAGNotLessABTS'));
end

c = cell(N1,N2);
for i=1:N1
  ai = nnfast.getelements(a,i);
  for j=1:N2
    bi = nnfast.getelements(b,i);
    for q=1:Q1
      aiq = nnfast.getsamples(ai,q);
      biq = nnfast.getsamples(bi,q);
      cijq = nncorr1([aiq{:}],[biq{:}],maxlag);
      if q == 1
        cij = cijq;
      else
        cij = cij + cijq;
      end
    end
    c{i,j} = cij ./ Q1;
    % TODO - take into account NaN values, via 'nn' returned below??
  end
end

% Bias and create symmetry
for i=1:N1
  for j=1:N2
    cij = c{i,j};
    switch(flag)
    case 'unbiased'
      cij = cij ./ (TS1-(0:maxlag));
    case 'biased'
      cij = cij ./ TS1;
    case 'coeff'
      cij = cij ./ c(1);
  % case 'none'
  %   do nothing
    end
    c{i,j} = [fliplr(cij(:,2:end)) cij];
  end
end

% Format
if (N1==1) && (N2==1) && (Q1==1) && aMatrix && bMatrix
  c = c{1,1,1};
end

function [c,nn] = nncorr1(a,b,maxlag)
n = length(a);
c = zeros(1,maxlag+1);
nn = zeros(1,maxlag+1);
for i=0:maxlag
  aa = a(1:(n-i));
  bb = b(1+i:n);
  keep = find(~isnan(aa+bb));
  nn(i+1) = length(keep);
  if nn < n
    aa = aa(keep);
    bb = bb(keep);
  end
  c(i+1) = aa*bb';
end

