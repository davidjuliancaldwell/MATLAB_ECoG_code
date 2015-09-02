function d = dn_dzj_num(info,j,z,n,param)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = nnModuleInfo(info);
end

[S,Q] = size(n);

delta = 1e-6;
n1 = info.apply(addzj(z,j,+2*delta),S,Q,param);
n2 = info.apply(addzj(z,j,+delta),S,Q,param);
n3 = info.apply(addzj(z,j,-delta),S,Q,param);
n4 = info.apply(addzj(z,j,-2*delta),S,Q,param);
d = (-n1 + 8*n2 - 8*n3 + n4) / (12*delta);

function z = addzj(z,j,v)
z{j} = z{j} + v;

