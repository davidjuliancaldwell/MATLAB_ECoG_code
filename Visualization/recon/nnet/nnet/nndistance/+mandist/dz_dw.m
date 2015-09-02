function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ
% z = SxQ

S = size(w,1);

d = cell(1,S);
for i=1:S
  z1 = bsxfun(@minus,w(i,:)',p);
  d{i} = sign(z1);
end
