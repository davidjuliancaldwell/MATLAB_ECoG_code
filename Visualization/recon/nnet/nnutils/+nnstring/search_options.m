function options = search_options(in1)

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 1
  options.wholeword = false;
  options.nostring = false;
  options.nocomment = false;
  options.onlycomment = false;
  options.isfunction = false;
  options.ignorecase = false;
elseif iscell(in1)
  options.wholeword = ~isempty(nnstring.first_match('wholeword',in1));
  options.nostring = ~isempty(nnstring.first_match('nostring',in1));
  options.nocomment = ~isempty(nnstring.first_match('nocomment',in1));
  options.onlycomment = ~isempty(nnstring.first_match('onlycomment',in1));
  options.isfunction = ~isempty(nnstring.first_match('isfunction',in1));
  options.ignorecase = ~isempty(nnstring.first_match('ignorecase',in1));
else
  options = in1;
end
