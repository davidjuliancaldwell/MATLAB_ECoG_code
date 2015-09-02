function y = defaultc(x,defaults)

% Copyright 2007-2010 The MathWorks, Inc.

y = [x defaults((length(x)+1):end)];
