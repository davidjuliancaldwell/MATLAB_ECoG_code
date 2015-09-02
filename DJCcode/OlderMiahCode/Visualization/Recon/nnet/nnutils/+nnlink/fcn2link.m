function str = fcn2link(fcn)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2matlablink(fcn,['doc ' fcn]);
