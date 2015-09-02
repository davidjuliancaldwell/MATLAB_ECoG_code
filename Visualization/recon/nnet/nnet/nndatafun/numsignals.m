function s = numsignals(x)
%NUMSIGNALS Number of signals in neural network data.
%
%  <a href="matlab:doc numsignals">numsignals</a>(X) return the number of singles in X, which must be NN data
%  in either matrix or cell array form.
%
%  If X is a matrix the result is 1.
%
%  If X is a cell array the result is the number of its rows.
%
%  This code calculates the number of signals represented by matrix data:
%
%    x = [1 2 3; 4 7 4]
%    n = <a href="matlab:doc numsignals">numsignals</a>(x)
%
%  This code calculates the number of signals represented by cell data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    n = <a href="matlab:doc numsignals">numsignals</a>(x)
%
%  See also GETSIGNALS, SETSIGNALS, CATSIGNALS, NNDATA, NNSIZE.

% Copyright 2010 The MathWorks, Inc.


if nargin < 1,error(message('nnet:Args:NotEnough')); end
x = nntype.data('format',x,'Data');

if iscell(x)
  s = nnfast.numsignals(x);
else
  s = 1;
end
