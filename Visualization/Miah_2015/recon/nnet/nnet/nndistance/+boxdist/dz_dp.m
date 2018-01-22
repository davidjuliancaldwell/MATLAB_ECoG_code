function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ
% z = SxQ

S = size(w,1);
[R,Q] = size(p);

d = cell(1,Q);
if (R==0)
  d(:) = {zeros(S,0)};
  return
end

for q=1:Q
  %dq = zeros(S,R);
  z1 = bsxfun(@minus,p(:,q)',w); % SxR
  z2 = abs(z1); % SxR
  
  z3 = max(abs(z2),[],2); % Sx1
  dq = bsxfun(@eq,z2,z3) .* sign(z1); % SxR

  %[~,ind1] = max(z2,[],2);
  %ind2 = (1:S)' + (ind1-1)*S;
  %dq(ind2) = sign(z1(ind2));
  
  d{q} = dq;
end
