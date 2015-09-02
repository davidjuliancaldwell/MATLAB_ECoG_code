function [v,vv,fail,t] = calc1(calcMode,calcNet,calcData,calcHints,test,runs)

% Copyright 2012 The MathWorks, Inc.

if nargin < 6, runs = 1; end

% Parallel
if isa(calcMode,'Composite')

  spmd
    isParallel = true;
   [calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints,isParallel);
   [v,vv,fail,t] = calc_test(test,calcLib,calcNet,runs);
  end
  v = v{1};
  vv = vv{1};
  fail = fail{1};
  t = t{1};

% Serial
else
  isParallel = false;
  [calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints,isParallel);
  [v,vv,fail,t] = calc_test(test,calcLib,calcNet,runs);
end

function [v,vv,fail,t] = calc_test(test,calcLib,calcNet,runs)

switch test
  case 'getwb', [v,vv,fail,t] = calc_getwb(calcLib,calcNet,runs);
  case 'setwb', [v,vv,fail,t] = calc_setwb(calcLib,calcNet,runs);
  case 'y', [v,vv,fail,t] = calc_y(calcLib,calcNet,runs);
  case 'trainPerf',  [v,vv,fail,t] = trainPerf(calcLib,calcNet,runs);
  case 'trainValTestPerfs', [v,vv,fail,t] = trainValTestPerfs(calcLib,calcNet,runs);
  case 'grad',  [v,vv,fail,t] = grad(calcLib,calcNet,runs);
  case 'perfsGrad', [v,vv,fail,t] = perfsGrad(calcLib,calcNet,runs);
  case 'perfsJEJJ', [v,vv,fail,t] = perfsJEJJ(calcLib,calcNet,runs);
end

function [v,vv,fail,t] = calc_getwb(calcLib,calcNet,runs)
tic
for r=1:runs
  wb2 = calcLib.getwb(calcNet);
end
t = toc;
vv = wb2;
v = wb2;
if any(isnan(wb2))
  fail = 'NaN returned';
else
  fail = '';
end
  
function [v,vv,fail,t] = calc_setwb(calcLib,calcNet,runs)
wb = calcLib.getwb(calcNet);
tic
for r=1:runs
  netf2 = calcLib.setwb(calcNet,-wb);
end
t = toc;
vv = calcLib.getwb(netf2);
v = vv;
if any(isnan(v))
  fail = 'NaN returned';
else
  fail = '';
end

function [v,vv,fail,t] = calc_y(calcLib,calcNet,runs)
tic
for r=1:runs
  [y,af] = calcLib.y(calcNet);
end
t = toc;
v1 = cell2mat(y);
v2 = cell2mat(af);
v = [v1(:); v2(:)];
vv = {y af};
fail = '';

function [v,vv,fail,t] = perfsJEJJ(calcLib,calcNet,runs)
tic
for r=1:runs
  [trainPerf,valPerf,testPerf,JE,JJ,gradient] = calcLib.perfsJEJJ(calcNet);
end
t = toc;
v = [JE(:); JJ(:); trainPerf]; %; JJ(:); trainPerf; valPerf; testPerf; gradient];
vv = {JE JJ trainPerf valPerf testPerf gradient};
if any(any(isnan(JE))) || any(any(isnan(JJ)))
  fail = 'NaN returned';
else
  fail = '';
end

function [v,vv,fail,t] = perfsGrad(calcLib,calcNet,runs)
tic
for r=1:runs
  [trainPerf,valPerf,testPerf,gWB,gradient] = calcLib.perfsGrad(calcNet);
end
t = toc;
v = [gWB(:); trainPerf]; % trainPerf; valPerf; testPerf; gradient];
vv = {gWB trainPerf valPerf testPerf gradient};
if any(any(isnan(gWB)))
  fail = 'NaN returned'
else
  fail = '';
end

function [v,vv,fail,t] = grad(calcLib,calcNet,runs)
tic
for r=1:runs
  [gWB,trainPerf] = calcLib.grad(calcNet);
end
t = toc;
v = [gWB(:); trainPerf];
vv = {trainPerf gWB};
if any(any(isnan(gWB)))
  fail = 'NaN returned';
else
  fail = '';
end

function [v,vv,fail,t] = trainPerf(calcLib,calcNet,runs)
tic
for r=1:runs
  perf = calcLib.trainPerf(calcNet);
end
t = toc;
v = perf;
vv = v;
fail = '';

function [v,vv,fail,t] = trainValTestPerfs(calcLib,calcNet,runs)
tic
for r=1:runs
  [trainPerf,valPerf,testPerf] = calcLib.trainValTestPerfs(calcNet);
end
t = toc;
v = [trainPerf,valPerf,testPerf];
vv = {trainPerf valPerf testPerf};
fail = '';
