function b2=concur(b,q)
%CONCUR Create concurrent bias vectors.
%
%  <a href="matlab:doc concur">concur</a>(B,Q) takes a bias vector B and returns Q copies of it.
%  This can be helpful when combining bias values with weight input
%  values with a net input function.
%
%  For instance, if a layer has 4 neurons, its bias will be a 4x1 value.
%  If the layer is being simulated for 3 sample vectors, its weighted
%  input will be 4x3. This function resizes the bias to allow a net
%  input function, such as <a href="matlab:doc netsum">netsum</a> to combine them.
%
%    b = <a href="matlab:doc rands">rands</a>(4,1); % bias values
%    z = <a href="matlab:doc rands">rands</a>(4,3); % weight inputs
%    n = <a href="matlab:doc netsum">netsum</a>(z,<a href="matlab:doc concur">concur</a>(b,3)) % net input
%    
%  See also NETSUM, NETPROD, SIM, SEQ2CON, CON2SEQ.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $

if nargin < 2, error(message('nnet:Args:NotEnough')), end

if isa(b,'double')
  b2 = b(:,ones(1,q));
  return
end

b2 = cell(size(b));
ones1xQ = ones(1,q);
for i=1:size(b,1)
   bi = b{i};
  if length(bi)
    b2{i} = bi(:,ones1xQ);
  end
end
