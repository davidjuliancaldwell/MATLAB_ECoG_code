function info = info(info)
% WARNING
% This is an implementation function
% It may be removed or altered without notice

% Copyright 2012 The MathWorks, Inc.

f = info.mfunction;
info.name = feval([f '.name']);
info.normalize = feval([f '.normalize']);
info.apply = str2func([f '.apply']);
info.backprop = str2func([f '.backprop']);
info.forwardprop = str2func([f '.forwardprop']);
info.dperf_dwb = str2func([f '.dperf_dwb']);
info.parameterInfo = feval([f '.parameterInfo']);
info.defaultParam = nn_modular_fcn.parameter_defaults(f);
