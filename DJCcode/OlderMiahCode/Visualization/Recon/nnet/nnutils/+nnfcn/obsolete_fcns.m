function mfcns = obsolete_fcns

% Copyright 2010-2011 The MathWorks, Inc.

mfiles = nn_obs_mfiles;
mfcns = nn_path2mfcn(mfiles);
i = nnstring.first_match('Contents',mfcns);
if ~isempty(i)
  mfcns(i) = [];
end
