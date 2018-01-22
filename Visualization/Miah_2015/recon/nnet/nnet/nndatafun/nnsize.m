function [n,q,ts,m] = nnsize(x)
%NNSIZE Number of neural data elements, samples, time steps and signals.
%
%  [N,Q,TS,M] = <a href="matlab:doc nnsize">nnsize</a>(X) take X, which must be NN data in matrix or
%  cell array form, and returns the number of elements in each signal N,
%  the number of samples S, the number of timesteps TS, and the number of
%  signals M.
%
%  If X is a matrix, N is the number of rows of X, Q is the number of
%  columns, and both TS and M are 1.
%
%  If X is a cell array, N is an Sx1 vector, where M is the number of rows
%  in X, and N(i) is the number of rows in X{i,1}. Q is the number of
%  columns in the matrices in X.
%
%  This code gets the dimensions of matrix data
%
%    x = [1 2 3; 4 7 4]
%    [n,q,ts,s] = <a href="matlab:doc nnsize">nnsize</a>(x)
%
%  This code gets the dimensions of cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    [n,q,ts,s] = <a href="matlab:doc nnsize">nnsize</a>(x)
%
%  See also ISNNDATA, NUMELEMENTS, NUMSAMPLES, NUMTIMESTEPS, NUMSIGNALS

% Copyright 2010 The MathWorks, Inc.

% Checks
if nargin < 1, error(message('nnet:Args:NotEnough')); end
x = nntype.data('format',x,'Data');

% Calculation
[n,q,ts,m] = nnfast.nnsize(x);
