function e = normalize_error(net,e,param)

% Copyright 2012 The MathWorks, Inc.

switch param.normalization
  case 'none', % no change required
  case 'standard', e = nnperf.norm_err(net,e);
  case 'percent', e = nnperf.perc_err(net,e);
end

