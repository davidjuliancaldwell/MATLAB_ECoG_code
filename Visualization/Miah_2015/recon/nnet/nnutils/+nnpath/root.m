function dirs = nn_nnet_path(mpath)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1,
  mpath = matlabroot;
end
nnpath = fullfile(mpath,'toolbox','nnet');

dirs = nn_dirs(nnpath,'all');
for i=length(dirs):-1:1
  di = dirs{i};
  if nnstring.ends(di,[filesep 'private'])
    dirs(i) = [];
  elseif ~isempty(strfind(di,[filesep 'private' filesep]))
    dirs(i) = [];
  elseif nnstring.ends(di,[filesep 'nnresource'])
    dirs(i) = [];
  elseif ~isempty(strfind(di,[filesep 'nnresource' filesep]))
    dirs(i) = [];
  end
end

z = length(mpath) + 2;
for i=1:length(dirs)
  dirs{i} = dirs{i}(z:end);
end
