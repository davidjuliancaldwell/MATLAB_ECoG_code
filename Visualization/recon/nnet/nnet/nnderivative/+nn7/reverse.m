function x = reverse(fcns,x)
%PROCESSREVERSE Applies processing functions and settings to a matrix.
%
% Syntax
%   
%   m2 = nnproc.reverse(processFcns,processSettings,m1)
%
% Description
%
%   PROCESSREVERSE(processFcns,processSettings,d1) takes:
%     processFcns - row cell array of N processing function names
%     processSettings - row cell array of N associated configurations
%     d1 - matrix or cell array of matrices to be reverse processed
%   and returns the processed matrix (or matrices) m2.

% Copyright 2007-2012 The MathWorks, Inc.


fcns = nnproc.active_fcns(fcns);
[rows,cols] = size(x);
functionOrder = length(fcns):-1:1;
for i=1:rows
  for j=1:cols
    xij = x{i,j};
    for k = functionOrder
      fcn = fcns(k);
      xij = fcn.reverse(xij,fcn.settings);
    end
    x{i,j} = xij;
  end
end
