function replace(fromStr,toStr,files,options)
%NNFILE.REPLACE

% Copyright 2010-2012 The MathWorks, Inc.

% Default Files
if (nargin < 3) || (~iscell(files) && isempty(files))
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
if nargin < 4
  options = nnstring.search_options;
elseif ischar(options)
  options = nnstring.search_options({options});
elseif iscell(options)
  options = nnstring.search_options(options);
end

% Search
for i=1:length(files)
  file = files{i};
  searchText = nntext.load(file);
  [searchText,change] = nntext.replace(fromStr,toStr,searchText,options);
  if change
    nntext.save(file,searchText);
    disp(['Updated: ' file])
  end
end
