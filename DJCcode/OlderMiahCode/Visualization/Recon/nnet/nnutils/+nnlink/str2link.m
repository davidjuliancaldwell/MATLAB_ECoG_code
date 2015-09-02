function s = str2link(str,link)

% Copyright 2010-2012 The MathWorks, Inc.

if feature('hotlinks')
  s = ['<a href="' link '">' str '</a>'];
else
  s = str;
end
