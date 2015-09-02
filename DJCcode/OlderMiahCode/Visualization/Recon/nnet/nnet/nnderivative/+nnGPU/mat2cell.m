function x = mat2cell(y,N,Q,TSnum,TStotal)

if nargin < 5
  TSstart = 1;
  TStotal = TSnum;
else
  TSstart = TStotal-TSnum+1;
end

M = numel(N);
offsets = cumsum([0; N(1:(end-1))]);
rows = 1:Q;

x = cell(M,TSnum);
for i=1:M
  for ts=TSstart:TStotal
    Ni = N(i);
    cols = offsets(i)*TStotal + Ni*(ts-1) + (1:Ni);
    if isempty(cols) || isempty(rows)
      x{i,ts-TSstart+1} = zeros(Ni,Q);
    else
      x{i,ts-TSstart+1} = gather(y(rows,cols))';
    end
  end
end
