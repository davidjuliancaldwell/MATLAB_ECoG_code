function d=dtansig(n,a)
%DTANSIG Hyperbolic tangent sigmoid transfer derivative function.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%
%  Syntax
%
%    dA_dN = dtansig(N,A)
%
%  Description
%
%    DTANSIG is the derivative function for TANSIG.
%
%    DTANSIG(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 TANSIG
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with TANSIG and then
%    the derivative of A with respect to N.
%
%      A = tansig(N)
%      dA_dN = dtansig(N,A)
%
%  Algorithm
%
%    The derivative of TANSIG is calculated as follows:
%
%      d = 1-a^2
%
%  See also TANSIG, LOGSIG, DLOGSIG.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

d = 1-(a.*a);
