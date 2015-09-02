function d = dperf_dy_num(info,t,y,e,param)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = feval(info);
end

delta = 1e-7;

norme = e./(t-y);

y2 = y + 2*delta;
perf1 = info.apply(t,y2,(t-y2).*norme,param);

y2 = y + delta;
perf2 = info.apply(t,y2,(t-y2).*norme,param);

y2 = y - delta;
perf3 = info.apply(t,y2,(t-y2).*norme,param);

y2 = y - 2*delta;
perf4 = info.apply(t,y2,(t-y2).*norme,param);

d = (-perf1 + 8*perf2 - 8*perf3 + perf4) ./ (12*delta);

