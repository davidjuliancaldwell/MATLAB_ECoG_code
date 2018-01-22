function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

S = size(z,1);
d = cell(1,S);
w = w';
for i=1:S
  zi = z(i,:);
  di = bsxfun(@rdivide,bsxfun(@minus,w(:,i),p),zi);
  di(:,zi==0) = 0;
  di(isnan(di)) = 0;
  d{i} = di;
end
