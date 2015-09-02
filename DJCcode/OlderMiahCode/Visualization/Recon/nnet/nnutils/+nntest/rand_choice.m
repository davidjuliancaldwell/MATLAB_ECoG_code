function choice = rand_choice(choices)
%RAND_CHOICE

% Copyright 2010 The MathWorks, Inc.

if iscell(choices)
  choice = choices{floor(rand*length(choices))+1};
else
  choice = choices(floor(rand*length(choices))+1);
end
