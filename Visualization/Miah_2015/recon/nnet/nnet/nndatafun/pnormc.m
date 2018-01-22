function y = pnormc(x,r)
%PNORMC Pseudo-normalize columns of a matrix.
%
%  <a href="matlab:doc pnormc">pnormc</a>(X,R) takes single or cell array of matrices, where all matrix
%  columns have lengths of R or less, and returns X augmented with an
%  additional row so that all matrix columns now have lengths of R.
%  
%  Here the columns of a random matrix are normalized to a length of two.
%
%    x = <a href="matlab:doc rands">rands</a>(4,10);
%    y = <a href="matlab:doc pnormc">pnormc</a>(x,2)
%  
%  See also NORMC, NORMR.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $  $Date: 2011/02/28 01:27:27 $

if nargin < 1,error(message('nnet:Args:NotEnough')); end
if nargin < 2, r = 1; end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Data');
nntype.pos_scalar('check',r,'Radius');

rr = r*r;
y = cell(size(x));
for i=1:numel(x)
  xi = x{i};
  y{i} = [xi; sqrt(rr-sum(xi.*xi,1))];
end

if wasMatrix, y = y{1}; end
