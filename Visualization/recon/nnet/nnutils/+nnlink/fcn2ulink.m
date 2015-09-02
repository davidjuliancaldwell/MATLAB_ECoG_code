function str = fcn2ulink(fcn)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2matlablink(upper(fcn),['doc ' fcn]);
