function info = info(info)
% WARNING
% This is an implementation function
% It may be removed or altered without notice

% Copyright 2012 The MathWorks, Inc.

f = info.mfunction;
info.inputDerivType = feval([f '.inputDerivType']);
info.weightDerivType = feval([f '.weightDerivType']);
info.size = str2func([f '.size']);
info.apply = str2func([f '.apply']);
info.dz_dp = str2func([f '.dz_dp']);
info.dz_dw = str2func([f '.dz_dw']);
info.backprop = str2func([f '.backprop']);
info.forwardprop = str2func([f '.forwardprop']);
info.backstop = str2func([f '.backstop']);
info.backstopParallel = str2func([f '.backstopParallel']);
info.forwardstart = str2func([f '.forwardstart']);
info.parameterInfo = feval([f '.parameterInfo']);
info.defaultParam = nn_modular_fcn.parameter_defaults(f);
info.simulinkParameters = str2func([f '.simulinkParameters']);  

% NNET 7.0 Compatibility
info.is_dotprod = strcmp(f,'dotprod');
info.w_deriv = info.weightDerivType;
info.p_deriv = info.inputDerivType;
