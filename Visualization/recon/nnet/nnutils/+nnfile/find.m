function out = find(str,files,options)

% Copyright 2010-2012 The MathWorks, Inc.

% Default Files
if (nargin < 2) || (~iscell(files) && isempty(files))
  files = [...
    nnfile.nnet_toolbox_files;
    nnfile.nnet_test_files;
    nnfile.nnet_src_files;
    nnfile.nnet_resource_xmlfiles
    ];  
end

% Remove CVS, non-text, no-name or dot-name files
for i=length(files):-1:1
  [path,name,ext] = fileparts(files{i});
  if ~isempty(strfind(path,'CVS')) || isempty(name) || (name(1) == '.') || ~nnpath.is_text_ext(ext)
    files(i) = [];
  end
end

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
for i=1:length(files)
  file = files{i};
  text = nntext.load(file);
  hitloc = nntext.find(str,text,options);
  if ~isempty(hitloc)
    hit.type = 'file_hit';
    hit.file = file;
    hit.lines = hitloc;
    hits = [hits hit];
  end
end

% Results
if nargout == 0
  nntext.disp(hits)
else
  out = hits;
end
