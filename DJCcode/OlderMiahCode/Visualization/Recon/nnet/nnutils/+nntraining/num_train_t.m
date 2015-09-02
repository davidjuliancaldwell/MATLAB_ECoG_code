function n = num_train_t(data)

% Copyright 2010 The MathWorks, Inc.

trainT = nntraining.train_t(data);
n = 0;
for i=1:numel(trainT)
  n = n + sum(sum(isfinite(trainT{i})));
end
