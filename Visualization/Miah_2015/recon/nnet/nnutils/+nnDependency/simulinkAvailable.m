function flag = available()
%AVAILABLE True if Simulink is installed and licensed

% Copyright 2010-2012 The MathWorks, Inc.

flag = ~isempty(ver('simulink')) && license('test','simulink');
