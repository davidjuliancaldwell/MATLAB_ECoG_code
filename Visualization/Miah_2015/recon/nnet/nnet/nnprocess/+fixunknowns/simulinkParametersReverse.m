function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

params = ...
  { ...
  'inputSize',mat2str(settings.xrows);
  'indices',mat2str(settings.known);
  };
