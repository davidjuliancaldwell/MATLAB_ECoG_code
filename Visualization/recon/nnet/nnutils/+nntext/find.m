function hits = find(str,text,options)
%NNTEXT.FIND

% Copyright 2010 The MathWorks, Inc.

% Options
if nargin < 3
  options = nnstring.search_options;
elseif ischar(options)
  options = nnstring.search_options({options});
elseif iscell(options)
  options = nnstring.search_options(options);
end

% Search
hits = [];
for i=1:length(text)
  hitloc = nnstring.find(str,text{i},options);
  if ~isempty(hitloc)
    hit.type = 'text_hit';
    hit.line = i;
    hit.chars = hitloc;
    hits = [hits hit];
  end
end

