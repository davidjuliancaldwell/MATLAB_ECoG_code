function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ
% z = SxQ

S = size(w,1);
[R,Q] = size(p);

d = cell(1,S);
if (R==0)
  d(:) = {zeros(0,Q)};
  return
end

for i=1:S
  %di = zeros(R,Q);
  z1 = bsxfun(@minus,w(i,:)',p); % RxQ
  z2 = abs(z1); % RxQ
  
  z3 = max(abs(z2),[],1); % 1xQ
  di = bsxfun(@eq,z2,z3) .* sign(z1); % RxQ
  
  %[~,ind1] = max(z2,[],1);
  %ind2 = (0:(Q-1))*R+ind1;
  %di(ind2) = sign(z1(ind2));
  d{i} = di;
end
