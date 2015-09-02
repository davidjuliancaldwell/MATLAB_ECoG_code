function params = simulinkParameters(settings)

% Copyright 2012 The MathWorks, Inc.

indices = zeros(1,settings.yrows);
indices(settings.known + settings.shift(settings.known)) = settings.known;
indices(settings.unknown + settings.shift(settings.unknown)) = settings.unknown;

params = ...
  { ...
  'inputSize',mat2str(settings.xrows);
  'indices',mat2str(indices);
  };
