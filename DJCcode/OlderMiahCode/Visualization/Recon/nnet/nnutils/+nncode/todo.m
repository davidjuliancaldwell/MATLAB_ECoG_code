function out = nn_todo
%NNTODO Find "TODO" in all NNET user and utility function files.

% Copyright 2010 The MathWorks, Inc.

parentdirs = [nn_user_mfiles nn_util_mfiles];
hits = nn_file_find('TODO',parentdirs);

if nargout > 0
  out = hits;
else
  nn_disp(hits)
end
