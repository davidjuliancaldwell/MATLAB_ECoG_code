function [out1,out2,out3,out4,out5,out6] = srchgol(varargin)
%SRCHGOL One-dimensional minimization using golden section search.
%
%  <a href="matlab:doc srchgol">srchgol</a> is a linear search routine.  It searches in a given direction
%   to locate the minimum of the performance function in that direction.
%   It uses a technique called the golden section search.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchgol">srchgol</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
%    NET     - Neural network.
%    X       - Vector containing current values of weights and biases.
%    P       - Processed inputs.
%    Pd      - Delayed input vectors.
%    Ai      - Initial input delay conditions.
%    Tl      - Layer target vectors.
%    EW      - Error weights.
%    Q       - Batch size.
%    TS      - Time steps.
%    dX      - Search direction vector.
%    gX      - Gradient vector.
%    PERF    - Performance value at current X.
%    DPERF   - Slope of performance value at current X in direction of dX.
%    DELTA   - Initial step size.
%    TOL     - Tolerance on search.
%    CH_PERF - Change in performance on previous step.
%  and returns,
%    A       - Step size which minimizes performance.
%    gX      - Gradient at new minimum point.
%    PERF    - Performance value at new minimum point.
%    RETCODE - Return code which has three elements. The first two elements correspond to
%              the number of function evaluations in the two stages of the search
%              The third element is a return code. These will have different meanings
%              for different search algorithms. Some may not be used in this function.
%                0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                3 - beta condition not met.
%    DELTA   - New initial step size. Based on the current step size.
%    TOL     - New tolerance on search.
%
%  Parameters used for the golden section algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                 size delta. Usually set to 20.
%
%  Dimensions for these variables are:
%    Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%    Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%  Where
%    Ni = net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>
%    LD = net.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Vi = net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%    Dij = Ri * length(net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>)
%
%  Here a feed-forward network is trained with the <a href="matlab:doc traincgf">traincgf</a> training
%  function and this search function.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20,'traincgf');
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchgol">srchgol</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBAC, SRCHBRE, SRCHCHA, SRCHHYB

% Copyright 1992-2012 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.13 $ $Date: 2012/04/20 19:14:00 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Search Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [out1,out2,out3,out4,out5,out6] = do_search(varargin{:});
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnSearch(mfilename,'Golden Section One-Dimensional Minimization',fcnversion);
end

function [a,gX,perf,retcode,delta,tol] = ...
    do_search(calcLib,calcNet,dX,gX,perf,dperf,delta,tol,ch_perf,param,~,~)

% Parallel Workers
isParallel = calcLib.isParallel;
isMainWorker = calcLib.isMainWorker;
mainWorkerInd = calcLib.mainWorkerInd;

% Create broadcast variables
a = [];
retcode = [];
X_temp = [];
X = [];
locationStop = [];
cFlag = [];
perfFlag = [];
srchStop = [];

if isMainWorker   
    if (nargin < 1), error(message('nnet:Args:NotEnough')); end
    if ischar(calcNet)
      switch(calcNet)
        case 'name'
          a = 'One-Dimensional Minimization w-Golden Section Search';
        otherwise, nnerr.throw(['Unrecognized code: ''' calcNet ''''])
      end
      return
    end

    % ALGORITHM PARAMETERS
    X = calcLib.getwb(calcNet);
    scale_tol = param.scale_tol;
    alpha = param.alpha;
    bmax = param.bmax;

    % Parameter Checking
    if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
      (scale_tol <= 0)
      error(message('nnet:ObsErr:ScaleNotPos'))
    end
    if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
      (alpha < 0) | (alpha > 1)
      error(message('nnet:srchgol:Alpha'))
    end
    if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
      (bmax <= 0)
      error(message('nnet:srchgol:Bmax'))
    end

    % INTERVAL FOR GOLDEN SECTION SEARCH
    tau = 0.618;
    tau1 = 1 - tau;

    % STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
    scale = 2;

    % INITIALIZE A AND B
    a = 0;
    a_old = 0;

    % We check influence of this condition on solution. FIND FIRST STEP SIZE
    delta_star = abs(-2*ch_perf/dperf);
    delta = max([delta delta_star]);

    b = delta;
    perfa = perf;
    perfa_old = perfa;
    cnt1 = 0;
    cnt2 = 0;

    % Correction in case bad performance
    X_temp = X - tol*dX;
end

calcNet_temp = calcLib.setwb(calcNet,X_temp);
perfb = calcLib.trainPerf(calcNet_temp);

if isMainWorker    
    if perfb<perfa
       perfa=perfb;
       X=X_temp;
       b=delta*2;
    end
    
    % CALCLULATE PERFORMANCE FOR B
    X_temp = X + b*dX;
end

calcNet_temp = calcLib.setwb(calcNet,X_temp);
perfb = calcLib.trainPerf(calcNet_temp);

if isMainWorker
    cnt1 = cnt1 + 1;
end
  
% INTERVAL LOCATION
% FIND INITIAL INTERVAL WHERE MINIMUM PERF OCCURS
while (true)
  if isMainWorker, locationStop = (perfa<=perfb) || (b>=bmax); end
  if isParallel, locationStop = labBroadcast(mainWorkerInd,locationStop); end
  if locationStop, break; end
  if isMainWorker
      a_old=a;
      perfa_old=perfa;
      perfa=perfb;
      a=b;
      b=scale*b;
      X_temp = X + b*dX;
  end
  calcNet_temp = calcLib.setwb(calcNet,X_temp); 
  perfb = calcLib.trainPerf(calcNet_temp);
  if isMainWorker
      cnt1 = cnt1 + 1;
  end
end
  
% INITIALIZE C AND D (INTERIOR POINTS FOR LINEAR MINIMIZATION)
if isMainWorker, cFlag = (a == a_old); end
if isParallel, cFlag = labBroadcast(mainWorkerInd,cFlag); end
if (cFlag)
    if isMainWorker
      % COMPUTE C POINT IF NO MIDPOINT EXISTS
      c = a + tau1*(b - a);
      X_temp = X + c*dX;
    end
  calcNet_temp = calcLib.setwb(calcNet,X_temp);
  perfc = calcLib.trainPerf(calcNet_temp);
  if isMainWorker
      cnt1 = cnt1 + 1;
  end
else
  % USE ALREADY COMPUTED VALUE AS INITIAL C POINT
  if isMainWorker      
      c = a;
      perfc = perfa;
      a=a_old;
      perfa=perfa_old;
  end
end

% INITIALIZE D POINT
if isMainWorker    
    d=b-tau1*(b-a);
    X_temp = X + d*dX;
end

calcNet_temp = calcLib.setwb(calcNet,X_temp);
perfd = calcLib.trainPerf(calcNet_temp);

if isMainWorker
    cnt1 = cnt1 + 1;

    minperf = min([perfa perfb perfc perfd]);
    if perfb <= minperf
      a_min = b;
    elseif perfc <= minperf
      a_min = c;
    elseif perfd <= minperf
      a_min = d;
    else
      a_min = a;
    end
end

% MINIMIZE ALONG A LINE (GOLDEN SECTION SEARCH)
while (true)
  if isMainWorker, srchStop = (((b-a)>tol) && (minperf >= perf + alpha*a_min*dperf)); end
  if isParallel, srchStop = labBroadcast(mainWorkerInd,srchStop); end
  if ~srchStop, break; end
    
  if isMainWorker, perfFlag = ( (perfc<perfd) && (perfb>=min([perfa perfc perfd])) ) || perfa<min([perfb perfc perfd]); end
  if isParallel, perfFlag = labBroadcast(mainWorkerInd,perfFlag); end
  if perfFlag
      if isMainWorker
        b=d; d=c; perfb=perfd;
        c=a+tau1*(b-a);
        %mth 6/6/05  round-off error may cause c=a
        if c==a,
            b=a; c=a; d=a;
        end
        perfd=perfc;
        X_temp = X + c*dX;
      end
      calcNet_temp = calcLib.setwb(calcNet,X_temp);
      perfc = calcLib.trainPerf(calcNet_temp);
      if isMainWorker   
        cnt2 = cnt2 + 1;
        if (perfc < minperf)
          minperf = perfc;
          a_min = c;
        end
      end
  else
      if isMainWorker
        a=c; c=d; perfa=perfc;
        d=b-tau1*(b-a);
        %  round-off error may cause d=b
        if d==b,
            b=a; c=a; d=a;
        end
        perfc=perfd;
        X_temp = X + d*dX;
      end
      calcNet_temp = calcLib.setwb(calcNet,X_temp);
      perfd = calcLib.trainPerf(calcNet_temp);
      if isMainWorker
        cnt2 = cnt2 + 1;
        if (perfd < minperf)
          minperf = perfd;
          a_min = d;
        end
      end
  end

end

if isMainWorker
    a=a_min;
    X = X + a*dX;
end
calcNet = calcLib.setwb(calcNet,X);
perf = calcLib.trainPerf(calcNet);
gX = -calcLib.grad(calcNet);

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
if isMainWorker
    delta=a;
    if delta < param.delta
      delta = param.delta;
    end

    % We always update the tolerance.
    tol=delta/scale_tol;

    retcode = [cnt1 cnt2 0];
end
end
