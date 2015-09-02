function m = randMask(elements,samples,timesteps)

% Copyright 2012 The MathWorks, Inc.

rows = sum(elements);
cols = samples*timesteps;

m = ones(rows,cols);
m(rand(rows,cols)<0.5) = NaN;

m = mat2cell(m,elements,ones(1,timesteps)*samples);
