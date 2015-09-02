function trainT = train_t(data)

% Copyright 2010 The MathWorks, Inc.

if data.train.masked
  trainT = gmultiply(data.T,data.train.mask);
else
  trainT = data.T;
end
