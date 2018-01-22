function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

recreate = zeros(1,settings.xrows);
recreate(settings.keep_ind) = (1:settings.yrows);
params = { ...
  'inputSize',mat2str(settings.xrows);
  'rearrange',mat2str(recreate);
  };
