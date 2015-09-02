function fcn = file2fcn(file)

% Copyright 2010-2012 The MathWorks, Inc.

% Multiple
if iscell(file)
  numFiles = length(file);
  fcn = cell(numFiles,1);
  for i=length(file):-1:1
    fcni = nnpath.file2fcn(file{i});
    if isempty(fcni)
      fcn(i) = [];
    else
      fcn{i} = fcni;
    end
  end
  return
end

% Single

% File name
i = find(file == filesep,1,'last');
name = file((i+1):end);

% Function
if ~nnstring.ends(name,'.m')
  fcn = '';
  return;
end
fcn = name(1:(end-2));
if strcmp(name,'Contents')
  fcn = '';
  return
end

% Package or Object
file = file(1:(i-1));
i = find(file == filesep,1,'last');
if isempty(i), i = 0; end
folder = file((i+1):end);
if folder(1) == '+'
  fcn = [folder(2:end) '.' fcn];
elseif folder(1) == '@'
  fcn = [folder(2:end) filesep fcn];
end
