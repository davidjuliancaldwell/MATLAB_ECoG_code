function str = typename2linkstr(x)

% Copyright 2010 The MathWorks, Inc.

str = ['''' x '''' ...
  ' (' nnlink.str2matlablink('doc',...
  ['disp('' '');disp(''*** OPEN DOC TO FUNCTION TYPE ' x ' ***'')']) ')'];
