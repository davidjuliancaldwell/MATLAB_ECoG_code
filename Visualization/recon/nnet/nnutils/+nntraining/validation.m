function [best,tr,val_fail] = validation(best,tr,val_fail,net,perf,vperf,epoch)

% Copyright 2010-2012 The MathWorks, Inc.
if ~isempty(tr.valInd)
  if (vperf < best.vperf)
    best.net = net;
    best.vperf = vperf;
    tr.best_epoch = epoch+1;
    val_fail = 0;
  elseif (vperf > best.vperf)
    val_fail = val_fail + 1;
  end
  if (perf < best.perf)
    best.perf = perf;
  end
elseif (perf < best.perf)
  best.net = net;
  best.perf = perf;
  tr.best_epoch = epoch+1;
end
