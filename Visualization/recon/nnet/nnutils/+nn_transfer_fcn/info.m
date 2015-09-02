function info = info(info)
% WARNING
% This is an implementation function
% It may be removed or altered without notice

% Copyright 2012 The MathWorks, Inc.

f = info.mfunction;
info.outputRange = feval([f '.outputRange']);
info.activeInputRange = feval([f '.activeInputRange']);
info.isScalar = feval([f '.isScalar']);
info.apply = str2func([f '.apply']);
info.da_dn = str2func([f '.da_dn']);
info.backprop = str2func([f '.backprop']);
info.forwardprop = str2func([f '.forwardprop']);
info.parameterInfo = feval([f '.parameterInfo']);
info.defaultParam = nn_modular_fcn.parameter_defaults(f);
info.simulinkParameters = str2func([f '.simulinkParameters']);  

