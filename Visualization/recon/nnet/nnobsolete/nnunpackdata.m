function d = nnunpackdata(d,mode)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if mode == 0
  d = d{1,1};
elseif mode == 1
  % do nothing
else
  d = [];
end
