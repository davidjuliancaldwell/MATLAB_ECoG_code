function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

recreate = zeros(1,settings.xrows);
recreate(settings.keep) = 1:length(settings.keep);
recreate(settings.remove) = ...
  (1:length(settings.remove)) + length(settings.keep);

params = ...
  { ...
  'inputSize',mat2str(settings.xrows);
  'constants',mat2str(settings.constants);
  'rearrange',mat2str(recreate);
  };
