function d=dposlin(n,a)
%DPOSLIN Derivative of positive linear transfer function.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%
%  Syntax
%
%    dA_dN = dposlin(N,A)
%
%  Description
%
%    DPOSLIN is the derivative function for POSLIN.
%
%    DPOSLIN(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 POSLIN
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with POSLIN and then
%    the derivative of A with respect to N.
%
%      A = poslin(N)
%      dA_dN = dposlin(N,A)
%
%  Algorithm
%
%    The derivative of POSLIN is calculated as follows:
%
%      d = 1, if 0 <= n
%          0, otherwise
%
%  See also POSLIN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

d = (n >= 0);
