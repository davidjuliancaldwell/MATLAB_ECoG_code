function d = dz_dw_num(info,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% For fcn.weightDerivType of 0 or 1, returns 1xS cell array of RxQ double
% For fcn.weightDerivType of 2, returns SxMxQ double

if ischar(info)
  info = nnModuleInfo(info);
end

delta = 1e-9;
switch info.weightDerivType
case {0,1}
  [S,R] = size(w);
  Q = size(p,2);
  d = cell(1,S);
  for i=1:S
    wi = w(i,:);
    di = zeros(R,Q);
    for j=1:R
      z1 = info.apply(addw(wi,j,+2*delta),p,param);
      z2 = info.apply(addw(wi,j,+delta),p,param);
      z3 = info.apply(addw(wi,j,-delta),p,param);
      z4 = info.apply(addw(wi,j,-2*delta),p,param);
      di(j,:) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
    end  
    d{i} = di;
  end
case 2
  M = numel(w);
  [S,Q] = size(z);
  d = zeros(S,M,Q);
  for i=1:M
    z1 = info.apply(addw(w,i,+2*delta),p,param);
    z2 = info.apply(addw(w,i,+delta),p,param);
    z3 = info.apply(addw(w,i,-delta),p,param);
    z4 = info.apply(addw(w,i,-2*delta),p,param);
    d(:,i,:) = reshape((-z1 + 8*z2 - 8*z3 + z4) / (12*delta),S,1,Q);
  end  
end

function n = addw(n,i,v)
n(i) = n(i) + v;
