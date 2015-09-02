function d=dnetsum(z,n)
%DNETSUM Sum net input derivative function.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%
%  Syntax
%
%    dN_dZ = dnetsum(Z,N)
%
%  Description
%
%    DNETSUM is the net input derivative function for NETSUM.
%
%    DNETSUM takes two arguments,
%      Z - SxQ weighted input.
%      N - SxQ net input.
%    and returns the SxQ derivative dN/dZ.
%
%  Examples
%
%    Here we define two weighted inputs for a layer with
%    three neurons.
%
%      Z1 = [0; 1; -1];
%      Z2 = [1; 0.5; 1.2];
%
%    We calculate the layer's net input N with NETSUM and then
%    the derivative of N with respect to each weighted input.
%
%      N = netsum(Z1,Z2)
%      dN_dZ1 = dnetsum(Z1,N)
%      dN_dZ2 = dnetsum(Z2,N)
%
%  Algorithm
%
%    The derivative of a sum with respect to any element of that
%    sum is always a ones matrix that is the same size as the sum.
%
%  See also NETSUM, NETPROD, DNETPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

d = ones(size(z));
