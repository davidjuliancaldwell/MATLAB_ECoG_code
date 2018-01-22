function e = adjust_error(net,e,ew,param)

% Copyright 2012 The MathWorks, Inc.

e = nn_performance_fcn.normalize_error(net,e,param);
ew = feval([net.performFcn '.perfw_to_ew'],ew);
e = gmultiply(e,ew);
