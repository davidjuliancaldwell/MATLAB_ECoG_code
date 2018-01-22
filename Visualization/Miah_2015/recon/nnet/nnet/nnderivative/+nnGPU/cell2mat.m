function y = cell2mat(x,precision)

% Copyright 2012 The MathWorks, Inc.

AlignTo = 32;

[N,Q,TS,M] = nnsize(x);

QQ = ceil(Q/AlignTo)*AlignTo;

offsets = cumsum([0; N(1:(end-1))]);
rows = 1:Q;

if strcmp(precision,'single') || strcmp(precision,'double')
  y = nan(QQ,sum(N)*TS,precision);
else
  y = zeros(QQ,sum(N)*TS,precision);
end

if isempty(y), return, end

for i=1:M
  for ts=1:TS
    Ni = N(i);
    cols = offsets(i)*TS + Ni*(ts-1) + (1:Ni);
    y(rows,cols) = x{i,ts}';
  end
end
