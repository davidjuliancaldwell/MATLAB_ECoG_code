function params = simulinkParameters(settings)

% Copyright 2012 The MathWorks, Inc.

params = ...
    { ...
    'inputSize',mat2str(settings.xrows);
    'keep',mat2str(settings.keep_ind);
    };
