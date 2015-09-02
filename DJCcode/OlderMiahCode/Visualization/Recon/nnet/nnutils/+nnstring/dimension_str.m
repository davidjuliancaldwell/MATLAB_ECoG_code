function s = nn_dimension_str(dims)

% Copyright 2010 The MathWorks, Inc.


s = num2str(dims(1));
for i=2:length(dims)
  s = [s 'x' num2str(dims(i))];
end
