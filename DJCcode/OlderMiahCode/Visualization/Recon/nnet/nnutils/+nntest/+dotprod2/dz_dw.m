function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

S = size(z,1);

z1 = w*p;
d = cell(1,S);
for i=1:S
  d{i} = bsxfun(@times,2*z1(i,:),p);
end
