function x = quant(x,q)
%QUANT_FAST (NNSTRICTDATA,NN_REAL_SCALAR) => (NNSTRICTDATA)
%
%  Syntax
%
%    quant(x,q)
%
%  Description
%
%    QUANT(X,Q) takes these inputs,
%      X - Matrix, vector or scalar.
%      Q - Minimum value.
%    and returns values in X rounded to nearest multiple of Q
%  
%  Examples
%
%    x = [1.333 4.756 -3.897];
%    y = quant(x,0.1)

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2010/03/22 04:12:33 $

[S,TS] = size(x);
for i=1:numel(x)
  x{i} = round(x{i}/q)*q;
end
