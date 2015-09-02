function flag = distCompAvailable()
%AVAILABLE True if Parallel Computing Toolbox is installed and licensed

% Copyright 2010-2012 The MathWorks, Inc.

flag = ~isempty(ver('distcomp')); % && license('test','???');
