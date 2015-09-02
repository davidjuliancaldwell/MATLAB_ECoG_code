function info = info(info)
% WARNING
% This is an implementation function
% It may be removed or altered without notice

% Copyright 2012 The MathWorks, Inc.

f = info.mfunction;
info.processInputs = feval([f '.processInputs']);
info.processOutputs = feval([f '.processOutputs']);
info.apply = str2func([f '.apply']);
info.reverse = str2func([f '.reverse']);
info.dy_dx = str2func([f '.dy_dx']);
info.dx_dy = str2func([f '.dx_dy']);
info.backprop = str2func([f '.backprop']);
info.backpropReverse = str2func([f '.backpropReverse']);
info.forwardprop = str2func([f '.forwardprop']);
info.forwardpropReverse = str2func([f '.forwardpropReverse']);
info.parameterInfo = feval([f '.parameterInfo']);
info.defaultParam = nn_modular_fcn.parameter_defaults(f);
info.simulinkParameters = str2func([f '.simulinkParameters']);  
info.simulinkParametersReverse = str2func([f '.simulinkParametersReverse']);  
