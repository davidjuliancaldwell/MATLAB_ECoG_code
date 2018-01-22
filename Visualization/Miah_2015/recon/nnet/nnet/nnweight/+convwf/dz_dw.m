function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[R,Q] = size(p);
N = length(w);
S = R-N+1;
d=zeros(S,N,Q);
for i=1:S,
  d(i,:,:)=p(i+(0:(N-1)),:);
end
