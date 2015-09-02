function dn = backprop(da,n,a,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(da);
dn = zeros(S,Q,N);
for q=1:Q
  nq = n(:,q); % Sx1
  aq = a(:,q); % Sx1
  anq = aq.*nq; % Sx1
  dq = 2*(bsxfun(@times,anq',aq) - diag(anq)); % SxS
  
  daq = da(:,q,:);
  dn(:,q,:) = reshape(sum(bsxfun(@times,dq,daq),1),S,1,N);
end
