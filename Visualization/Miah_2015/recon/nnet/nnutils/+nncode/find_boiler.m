function [start,stop] = find_boiler(text)
%FIND_BOILER Find section of function text defining boilerplate.

% Copyright 2010 The MathWorks, Inc.

start = 0;
stop = 0;

for i=1:length(text)
  ti = text{i};
  ti(ti==' ') = [];
  ti(ti=='%') = [];
  if strcmp(ti,'BOILERPLATE_START')
    start = i;
    break;
  end
end
if start == 0, return, end
for i=start+1:length(text)
  ti = text{i};
  ti(ti==' ') = [];
  ti(ti=='%') = [];
  if strcmp(ti,'BOILERPLATE_END')
    stop = i;
    break;
  end
end
