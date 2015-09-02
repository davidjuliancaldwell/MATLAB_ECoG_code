function hitloc = find(findStr,searchStr,options)

% Copyright 2010-2012 The MathWorks, Inc.

% Options
if nargin < 3
  options = nnstring.search_options;
elseif ischar(options)
  options = nnstring.search_options({options});
elseif iscell(options)
  options = nnstring.search_options(options);
end

% Search
searchStr2 = searchStr;
if options.nostring
  searchStr2 = nnstring.clear_string(searchStr2);
end
if options.nocomment
  searchStr2 = nnstring.clear_comment(searchStr2);
end
if options.ignorecase
  searchStr2 = lower(searchStr2);
  findStr = lower(findStr);
end

hitloc = strfind(searchStr2,findStr);
for j=length(hitloc):-1:1
  drop = false;
  if options.wholeword
    hitstart = hitloc(j);
    hitend = hitstart + length(findStr) - 1;
    if (hitstart>1) && wordchar(searchStr(hitstart)) && wordchar(searchStr(hitstart-1))
      drop = true;
    elseif (hitend<length(searchStr)) && wordchar(searchStr(hitend)) && wordchar(searchStr(hitend+1));
      drop = true;
    end
  end
  if drop, hitloc(j) = []; end
end

function flag = wordchar(c)

flag = any(c == ...
  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_');
