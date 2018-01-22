function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

inverse_transform = pinv(settings.transform);
params = {'inverse_transform',mat2str(inverse_transform);};
