function flag = ends(string,suffix)
%STRENDS Checks if string ends with another string.
%
%  STRENDS('STRING','SUFFIX') returns true if STRING ends with SUFFIX.
%
%  See also STRSTARTS.

% Copyright 2010 The MathWorks, Inc.

len1 = length(string);
len2 = length(suffix);
if len1 < len2
  flag = false;
else
  flag = all(string((len1-len2+1):len1) == suffix);
end
