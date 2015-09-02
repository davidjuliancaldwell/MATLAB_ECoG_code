function y = quant(x,q)
%QUANT Discretize NN data as multiples of a quantity.
%
%  <a href="matlab:doc quant">quant</a>(X,Q) quantizes NN data X so that all values are a replaced
%  by the closest multiple of Q.  If Q is not supplied all values
%  are rounded the nearest integer (i.e. multiple of 1).
%
%  Here data in matrix form is quantized as multiles of 0.1:
%
%    x = [1.333 4.756 -3.897; 4.223 5.239 0.031];
%    y = <a href="matlab:doc quant">quant</a>(x,0.1)
%
%  Here random values in cell array form is are quantized to 0.5:
%
%    x = <a href="matlab:doc nndata">nndata</a>([1;2],3,4)
%    y = <a href="matlab:doc quant">quant</a>(x)

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $  $Date: 2011/02/28 01:27:30 $

% Check
if nargin < 1, error(message('nnet:Args:NotEnough')); end
if nargin < 2, q = 1; end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Data');
nntype.pos_scalar('check',q,'Quantization');

% Calculation
y = nnfast.quant(x,q);

% Format
if wasMatrix, y = y{1}; end

