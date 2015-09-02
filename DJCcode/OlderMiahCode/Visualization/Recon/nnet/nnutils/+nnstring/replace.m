function [searchStr,change] = string_replace(findStr,replaceStr,searchStr,options)

% Copyright 2010 The MathWorks, Inc.

% Options
if nargin < 4
  options = nnstring.search_options;
elseif ischar(options)
  options = nnstring.search_options({options});
elseif iscell(options)
  options = nnstring.search_options(options);
end

% Search
change = false;
searchStr2 = searchStr;
if options.nostring, searchStr2 = nnstring.clear_string(searchStr2); end
if options.nocomment, searchStr2 = nnstring.clear_comment(searchStr2); end
hitloc = strfind(searchStr2,findStr);
for j=length(hitloc):-1:1
  drop = false;
  hitstart = hitloc(j);
  hitend = hitstart + length(findStr) - 1;
  if options.wholeword
    if (hitstart>1) && wordchar(searchStr(hitstart)) && wordchar(searchStr(hitstart-1))
      drop = true;
    elseif (hitend<length(searchStr)) && wordchar(searchStr(hitend)) && wordchar(searchStr(hitend+1));
      drop = true;
    end
  end
  if ~drop
    change = true;
    searchStr = [searchStr(1:(hitstart-1)) replaceStr searchStr((hitend+1):end)];
  end
end

function flag = wordchar(c)

flag = any(c == ...
  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_');
