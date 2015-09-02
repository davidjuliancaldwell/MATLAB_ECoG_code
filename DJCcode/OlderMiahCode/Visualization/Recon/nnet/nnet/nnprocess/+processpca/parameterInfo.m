function param = parameterInfo

% Copyright 2012 The MathWorks, Inc.

param = nnetParamInfo('maxfrac','Maximum Fraction','nntype.pos_scalar',1e-10,...
    'Minimum fraction of total variable for a row to be kept.');
