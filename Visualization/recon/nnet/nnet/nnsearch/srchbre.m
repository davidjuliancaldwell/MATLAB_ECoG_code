function [out1,out2,out3,out4,out5,out6] = srchbre(varargin)
%SRCHBRE One-dimensional interval location using Brent's method.
%
%  <a href="matlab:doc srchbre">srchbre</a> is a linear search routine.  It searches in a given direction
%  to locate the minimum of the performance function in that direction.
%  It uses a technique called Brent's method.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchbre">srchbre</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
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
%               the number of function evaluations in the two stages of the search
%              The third element is a return code. These will have different meanings
%               for different search algorithms. Some may not be used in this function.
%                 0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                 3 - beta condition not met.
%    DELTA   - New initial step size. Based on the current step size.
%    TOL     - New tolerance on search.
%
%  Parameters used for the brent algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    beta      - Scale factor which determines sufficiently large step size.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                   size delta. Usually set to 20.
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
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchbre">srchbre</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBAC, SRCHCHA, SRCHGOL, SRCHHYB

% Copyright 1992-2012 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.13 $ $Date: 2012/04/20 19:13:58 $

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
  info = nnfcnSearch(mfilename,'One-Dimensional Interval Location',fcnversion);
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
initPerfStop = [];
NaNFlag = [];
aFlag = [];
perfStop = [];
redStop = [];
perfFlag = [];
uFlag = [];
perfaFlag = [];

if isMainWorker
    if (nargin < 1), error(message('nnet:Args:NotEnough')); end
    if ischar(calcNet)
      switch(calcNet)
        case 'name'
          a = 'One-Dimensional Interval Location w-Brent''s Method';
        otherwise, nnerr.throw(['Unrecognized code: ''' calcNet ''''])
      end
      return
    end

    % ALGORITHM PARAMETERS
    X = calcLib.getwb(calcNet);
    scale_tol = param.scale_tol;
    alpha = param.alpha;
    beta = param.beta;
    bmax = param.bmax;

    % Parameter Checking
    if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
      (scale_tol <= 0)
      error(message('nnet:ObsErr:ScaleNotPos'))
    end
    if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
      (alpha < 0) | (alpha > 1)
      error(message('nnet:srchbre:Alpha'))
    end
    if (~isa(beta,'double')) | (~isreal(beta)) | (any(size(beta)) ~= 1) | ...
      (beta < 0) | (beta > 1)
      error(message('nnet:srchbre:Beta'))
    end
    if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
      (bmax <= 0)
      error(message('nnet:srchbre:Bmax'))
    end

    %INITIALIZE
    u = 1e19;
    cnt1 = 0;
    cnt2 = 0;

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
while true
  if isMainWorker, initPerfStop = ~((perfa>perfb) && (b<bmax)); end
  if isParallel, initPerfStop = labBroadcast(mainWorkerInd,initPerfStop); end
  if initPerfStop, break; end
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

% If perfb is NaN we return
if isMainWorker, NaNFlag = ~isnan(perfb); end
if isParallel, NaNFlag = labBroadcast(mainWorkerInd,NaNFlag); end
if NaNFlag
  if isMainWorker, aFlag = (a == a_old); end
  if isParallel, aFlag = labBroadcast(mainWorkerInd,aFlag); end
  if aFlag
    % GET INTERMEDIATE POINT IF NO MIDPOINT EXISTS
    % We check until perfv smaller than perfb
    if isMainWorker
        perfv=perfb;
        v=b;
    end
    while true % mth 6/5/05 add check for b-a
      if isMainWorker, perfStop = ~((perfv>=perfb) && (v==b) && ((b-a)>tol)); end
      if isParallel, perfStop = labBroadcast(mainWorkerInd,perfStop); end
      if perfStop, break; end
      if isMainWorker
          v = a + tau1*(b - a);
          w = v;
          x = v;
          X_temp = X + v*dX;
      end
      calcNet_temp = calcLib.setwb(calcNet,X_temp);
      perfv = calcLib.trainPerf(calcNet_temp);
      if isMainWorker
          perfw = perfv;
          perfx = perfv;
          cnt1 = cnt1 + 1;
          % If greater we change b to v, 
          % except when there is a descent direction from a to v
          if (perfv>=perfb) && (perfa<=perfv)
             b=v;
             perfb=perfv;
          end
      end
    end
  else
    % USE ALREADY COMPUTED VALUE AS INITIAL INTERMEDIATE POINT
    if isMainWorker
        v = a;
        w = v;
        x = v;
        perfv = perfa;
        perfw = perfv;
        perfx = perfv;
        a=a_old;
        perfa=perfa_old;
    end
  end
  
  if isMainWorker
      max_int = w;
      min_int = w;
  end

  % REDUCE THE INTERVAL
  while true
    if isMainWorker, redStop = ~(((b-a)>tol) && (perfx >= perf + alpha*x*dperf)); end
    if isParallel, redStop = labBroadcast(mainWorkerInd,redStop); end
    if redStop, break; end

    % QUADRATIC INTERPOLATION
    if isMainWorker
        if (w~=x) && (w~=v) && (x~=v) && ( (max_int - min_int) > 0.02*(b-a) )
          [zz,i] = sort([v w x]);
          pp = [perfv perfw perfx];
          pp = pp(i);
          num = (zz(3)^2 - zz(2)^2)*pp(1) + (zz(2)^2 - zz(1)^2)*pp(3) + (zz(1)^2 - zz(3)^2)*pp(2);
          den = (zz(3) - zz(2))*pp(1) + (zz(2) - zz(1))*pp(3) + (zz(1) - zz(3))*pp(2); 
          % Change to avoid division by zero
          if den==0
            break; %We finish program.
          else
            x_star = 0.5*num/den;
            if (x_star < b) && (a < x_star)
              u = x_star;
              gold_sec = 0;
            else
              gold_sec = 1;
            end
          end
        else
          gold_sec = 1;
        end

        % GOLDEN SECTION 
        if (gold_sec == 1)
          if (x >= (a + b)/2);
            u = x - tau1*(x - a);
          else
            u = x + tau1*(b - x);
          end
        end

        X_temp = X + u*dX;
    end
    calcNet_temp = calcLib.setwb(calcNet,X_temp);
    perfu = calcLib.trainPerf(calcNet_temp);
    if isMainWorker
        cnt2 = cnt2 + 1;
    end

    % UPDATE POINTS
    if isMainWorker, perfFlag = (perfu <= perfx); end
    if isParallel, perfFlag = labBroadcast(mainWorkerInd,perfFlag); end
    if perfFlag
      if isMainWorker, uFlag = (u<x); end
      if isParallel, uFlag = labBroadcast(mainWorkerInd,uFlag); end
      if uFlag
        if isMainWorker
            b = x;
            perfb = perfx;
        end
      else
        % If perfx smaller than perfa we are OK
        if isMainWorker, perfaFlag = (perfa >= perfu); end
        if isParallel, perfaFlag = labBroadcast(mainWorkerInd,perfaFlag); end
        if perfaFlag
          if isMainWorker
              a = x;
              perfa = perfx;
          end
        else   % Otherwise we must move b to x.
          if isMainWorker
              b = x;
              perfb = perfx;
              % We must GET INTERMEDIATE POINT IF NO MIDPOINT EXISTS
              v = a + tau1*(b - a);
              w = v;
              x = v;
              X_temp = X + v*dX;
          end
          calcNet_temp = calcLib.setwb(calcNet,X_temp);
          perfv = calcLib.trainPerf(calcNet_temp);
          if isMainWorker
              perfw = perfv;
              perfx = perfv;
              cnt1 = cnt1 + 1;
          end
        end      
      end
      
      if isMainWorker
          v = w; perfv = perfw;
          w = x; perfw = perfx;
          x = u; perfx = perfu;
      end
    else
      if isMainWorker, uFlag = (u<x); end
      if isParallel, uFlag = labBroadcast(mainWorkerInd,uFlag); end
      if uFlag
        % If perfu smaller than perfa we are OK
        if isMainWorker, perfaFlag = (perfa >= perfu); end
        if isParallel, perfaFlag = labBroadcast(mainWorkerInd,perfaFlag); end
        if perfaFlag
          if isMainWorker
              a = u;
              perfa = perfu;
          end
        else   % Otherwise we must move b to u.
          if isMainWorker
              b = u;
              perfb = perfu;
              % We must GET INTERMEDIATE POINT IF NO MIDPOINT EXISTS
              v = a + tau1*(b - a);
              w = v;
              x = v;
              X_temp = X + v*dX;
          end
          calcNet_temp = calcLib.setwb(calcNet,X_temp);
          perfv = calcLib.trainPerf(calcNet_temp);
          if isMainWorker
              perfw = perfv;
              perfx = perfv;
              cnt1 = cnt1 + 1;
          end
        end
      else
        if isMainWorker
            b = u;
            perfb = perfu;
        end
      end
    
      if isMainWorker
          if (perfu <= perfw) || (w == x)
            v = w; perfv = perfw;
            w = u; perfw = perfu;
          elseif (perfu <= perfv) || (v == x) || (v == w)
            v = u; perfv = perfu;
          end
      end

    end
    
    if isMainWorker
        temp = [w x v];
        min_int = min(temp);
        max_int = max(temp);
    end
  end
else
   v=a;w=a;x=a;
   perfv=perfa;perfw=perfa;perfx=perfa;
end

% COMPUTE THE FINAL STEP, FUNCTION VALUE AND GRADIENT
if isMainWorker
    xtot = [a b v w x];
    perftot = [perfa perfb perfv perfw perfx];
    [~,i] = sort(perftot);
    xtot = xtot(i);
    a = xtot(1);
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
