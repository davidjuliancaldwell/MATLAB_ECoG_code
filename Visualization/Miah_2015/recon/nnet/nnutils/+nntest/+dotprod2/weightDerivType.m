function t = weightDerivType

% Copyright 2012 The MathWorks, Inc.

%  Returns 0, if dz_dw derivative is RxQ double matrix
%  Returns 1, if dz_dw derivative is 1xS cell of RxQ matrices
%  Returns 2, if dz_dw derivative is Sxnumel(W)xQ

t = 1;
