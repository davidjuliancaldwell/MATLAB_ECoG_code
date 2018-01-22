function path = nnet_root
%NNET_ROOT Current NNET development root
%
% NNET_ROOT will generally be the same as MATLAB_ROOT, unless the NNET
% root has been altered with NNPATH.UPDATE.

% Copyright 2010 The MathWorks, Inc.

tansig_path = which('maxlinlr');
if isempty(tansig_path)
  path = matlabroot;
else
  transfer_folder = fileparts(tansig_path);
  user_folder = fileparts(transfer_folder);
  nnet_folder = fileparts(user_folder);
  toolbox_folder = fileparts(nnet_folder);
  path = fileparts(toolbox_folder);
end
