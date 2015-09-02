function n = numfinite(x)
%NUMFINITE Number of finite values in neural network data.
%
%  <a href="matlab:doc numfinite">numfinite</a>(X) accepts a 2D numeric matrix or a cell array
%  of such matrices, and returns the number of finite values.
%
%  Examples:
%
%    x = [1 2; 3 NaN]
%    n = <a href="matlab:doc numfinite">numfinite</a>(x)
%
%    x = {[1 2; 3 NaN] [5 NaN; NaN 8]}
%    n = <a href="matlab:doc numfinite">numfinite</a>(x)
%
%  See also NUMNAN, NNDATA, NNSIZE.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1,error(message('nnet:Args:NotEnough')); end
x = nntype.data('format',x,'Data');

n = nnfast.numfinite(x);
