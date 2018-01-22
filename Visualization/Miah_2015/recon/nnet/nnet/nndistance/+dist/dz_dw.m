function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

S = size(z,1);
d = cell(1,S);
w = w';
z(z==0) = 1;
for i=1:S
  zi = z(i,:);
  di = bsxfun(@rdivide,bsxfun(@minus,w(:,i),p),zi);
  di(isnan(di)) = 0;
  d{i} = di;
end
