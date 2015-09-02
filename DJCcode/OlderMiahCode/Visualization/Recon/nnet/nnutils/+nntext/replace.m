function [searchText,change] = replace(findStr,toStr,searchText,options)

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
for i=1:length(searchText)
  if (i == 1) && (options.isfunction)
    dot = find(findStr == '.',1);
    if ~isempty(dot)
      findStr2 = findStr((dot+1):end);
    else
      findStr2 = findStr;
    end
    dot = find(toStr == '.',1);
    if ~isempty(dot)
      toStr2 = toStr((dot+1):end);
    else
      toStr2 = toStr;
    end
    [searchText{i},changei] = nnstring.replace(findStr2,toStr2,searchText{i},options);
  else
    [searchText{i},changei] = nnstring.replace(findStr,toStr,searchText{i},options);
  end
  if changei, change = true; end
end
