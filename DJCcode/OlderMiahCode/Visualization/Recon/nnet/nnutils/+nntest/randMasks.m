function varargout = randMasks(elements,samples,timesteps)

% Copyright 2012 The MathWorks, Inc.

numMasks = nargout;

rows = sum(elements);
cols = samples*timesteps;

ind = ceil(rand(rows,cols)*numMasks);

varargout = cell(1,numMasks);
for i=1:numMasks
  m = ones(rows,cols);
  m(ind ~= i) = NaN;
  varargout{i} = mat2cell(m,elements,ones(1,timesteps)*samples);
end
