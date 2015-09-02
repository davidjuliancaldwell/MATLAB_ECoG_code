function d = dz_dw_full(info,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% For fcn.weightDerivType of 0 or 1, returns 1xS cell array of RxQ double
% For fcn.weightDerivType of 2, returns SxMxQ double

if ischar(info)
  info = nnModuleInfo(info);
end

switch info.weightDerivType
case 0
  S = size(w,1);
  d = cell(1,S);
  d(:) = {info.dz_dw(w,p,z,param)};
case 1
  d = info.dz_dw(w,p,z,param);
case 2
  d = info.dz_dw(w,p,z,param);
end
