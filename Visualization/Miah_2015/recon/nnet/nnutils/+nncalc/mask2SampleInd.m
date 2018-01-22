function ind = mask2SampleInd(mask)

% Copyright 2012 The MathWorks, Inc.

% combine timesteps
mask1 = isfinite(mask{1});
for i=2:numel(mask)
  mask1 = mask1 | isfinite(mask{i});
end

% combine elmements
mask1 = any(mask1,1);

% find samples
ind = find(mask1);
