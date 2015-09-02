function out1 = gen_nnet_phl(mpath)
%GEN_NNET_PHL Generate NNET.PHL file.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1,
  mpath = nnpath.nnet_root;
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

dirs = [{nnpath} dirs];
z = length(mpath) + 2;
for i=1:length(dirs)
  dirs{i} = dirs{i}(z:end);
end

for i=1:length(dirs)
  disp(dirs{i})
end

if nargout > 0, out1 = dirs; end
