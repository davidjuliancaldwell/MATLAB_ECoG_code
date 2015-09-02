function info = info(info)
% WARNING
% This is an implementation function
% It may be removed or altered without notice

% Copyright 2012 The MathWorks, Inc.

f = info.mfunction;
info.apply = str2func([f '.apply']);
info.dn_dzj = str2func([f '.dn_dzj']);
info.backprop = str2func([f '.backprop']);
info.forwardprop = str2func([f '.forwardprop']);
info.parameterInfo = feval([f '.parameterInfo']);
info.defaultParam = nn_modular_fcn.parameter_defaults(f);
info.simulinkParameters = str2func([f '.simulinkParameters']);

% NNET 7.0 Compatibility
info.is_netsum = strcmp(f,'netsum');
