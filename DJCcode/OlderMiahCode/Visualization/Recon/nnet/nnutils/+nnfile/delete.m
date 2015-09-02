function nn_delete(file)

% Copyright 2010 The MathWorks, Inc.

if exist(file,'file')
  delete(file);
end
