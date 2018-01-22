function d = da_dn_full(info,n,a,param)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = nnModuleInfo(info);
end

d = info.da_dn(n,a,param);
if ~iscell(d)
  Q = size(n,2);
  dfull = cell(1,Q);
  for q=1:Q, dfull{q} = diag(d(:,q)); end
  d = dfull;
end
