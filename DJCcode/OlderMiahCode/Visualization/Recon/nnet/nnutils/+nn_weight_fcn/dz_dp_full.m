function d = dz_dp_full(info,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% Returns 1xQ cell of RxS double

if ischar(info)
  info = nnModuleInfo(info);
end

switch info.inputDerivType
  case 0
    Q = size(p,2);
    d = cell(1,Q);
    d(:) = {info.dz_dp(w,p,z,param)};
  case 1
    d = info.dz_dp(w,p,z,param);
end
