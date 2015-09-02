function [out1,out2,out3,out4,out5,out6] = srchhyb(varargin)
%SRCHHYB One-dimensional minimization using a hybrid bisection-cubic search.
%
%  <a href="matlab:doc srchhyb">srchhyb</a> is a linear search routine.  It searches in a given direction
%  to locate the minimum of the performance function in that direction.
%  It uses a technique which is a combination of a bisection and a
%  cubic interpolation.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchhyb">srchhyb</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
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
%  Parameters used for the hybrid bisection-cubic algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    beta      - Scale factor which determines sufficiently large step size.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                size delta. Usually set to 20.
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
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchhyb">srchhyb</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBAC, SRCHBRE, SRCHCHA, SRCHGOL

% Copyright 1992-2012 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.13 $ $Date: 2012/04/20 19:14:01 $

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
  info = nnfcnSearch(mfilename,...
    'Hybrid Bisection-Cubic One-Dimensional Minimization',fcnversion);
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
  initPerfStop = [];
  NaNFlag = [];
  aFlag = [];
  minStop = [];
  wxFlag = [];
  wFlag = [];
  uFlag = [];
  bisecFlag = [];
  
  if isMainWorker
      if (nargin < 1), error(message('nnet:Args:NotEnough')); end
      if ischar(calcNet)
        switch(calcNet)
          case 'name'
            a = 'One-Dimensional Minimization w-Hybrid Bisection-Cubic';
          otherwise, nnerr.throw(['Unrecognized code: ''' calcNet ''''])
        end
        return
      end

      u = 999.9;
      perfu = 999.99;
      dperfu = 999.99;

      % ALGORITHM PARAMETERS
      X = calcLib.getwb(calcNet);
      scale_tol = param.scale_tol;
      alpha = param.alpha;
      beta = param.beta;
      bmax = param.bmax;
      min_grad = param.min_grad;

      % Parameter Checking
      if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
        (scale_tol <= 0)
        error(message('nnet:ObsErr:ScaleNotPos'))
      end
      if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
        (alpha < 0) | (alpha > 1)
        error(message('nnet:srchhyb:Alpha'))
      end
      if (~isa(beta,'double')) | (~isreal(beta)) | (any(size(beta)) ~= 1) | ...
        (beta < 0) | (beta > 1)
        error(message('nnet:srchhyb:Beta'))
      end
      if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
        (bmax <= 0)
        error(message('nnet:srchhyb:Bmax'))
      end
      if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
        (min_grad < 0)
        error(message('nnet:NNTrain:Min_grad'))
      end

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
      dperfa = dperf;
      perfa_old = perfa;
      dperfa_old = dperfa;
      cnt1 = 0;
      cnt2 = 0;

      % CALCLULATE PERFORMANCE FOR B
      X_temp = X + b*dX;
  end
  calcNet_temp = calcLib.setwb(calcNet,X_temp);
  perfb = calcLib.trainPerf(calcNet_temp);
  gX_temp = -calcLib.grad(calcNet_temp);
  if isMainWorker
      dperfb = gX_temp'*dX;
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
        perfa_old = perfa;
        dperfa_old = dperfa;
        perfa = perfb;
        dperfa = dperfb;
        a=b;
        b=scale*b;
        X_temp = X + b*dX;
    end
    calcNet_temp = calcLib.setwb(calcNet,X_temp);
    perfb = calcLib.trainPerf(calcNet_temp);
    gX_temp = -calcLib.grad(calcNet_temp);
    if isMainWorker
        dperfb = gX_temp'*dX;
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
      % TAKE INITIAL BISECTION STEP IF NO MIDPOINT EXISTS
      if isMainWorker
          x = (a + b)/2;
          X_step = x*dX;
          X_temp = X + X_step;
      end
      calcNet_temp = calcLib.setwb(calcNet,X_temp);
      perfx = calcLib.trainPerf(calcNet_temp);
      gX_temp = -calcLib.grad(calcNet_temp);
      if isMainWorker
          dperfx = gX_temp'*dX;
          cnt1 = cnt1 + 1;
      end
    else
      % USE ALREADY COMPUTED VALUE AS INITIAL BISECTION STEP
      if isMainWorker
          x = a;
          perfx = perfa;
          dperfx = dperfa;
          a=a_old;
          perfa=perfa_old;
          dperfa = dperfa_old;
      end
    end

    % DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
    if isMainWorker
        if perfa>perfb
          w = b;
          perfw = perfb;
          dperfw = dperfb;
        else
          w = a;
          perfw = perfa;
          dperfw = dperfa;
        end

        % DETERMINE THE OVERALL MINIMUM POINT
        minperf = min([perfa perfb perfx]);
        amin = a; dperfmin = dperfa;
        if perfb<= minperf
          amin = b; dperfmin = dperfb;
        elseif perfx <= minperf
          amin = x; dperfmin = dperfx;
        end
    end

    % LOCATE THE MINIMUM POINT BY THE HYBRID BISECTION-CUBIC SEARCH
    while true
      if isMainWorker, minStop = ~(((b-a)>tol) && ((minperf > perf + alpha*amin*dperf) || abs(dperfmin)>abs(beta*dperf) )); end
      if isParallel, minStop = labBroadcast(mainWorkerInd,minStop); end
      if minStop, break; end

      if isMainWorker, wxFlag = (abs(w-x)<.02*(b-a)); end
      if isParallel, wxFlag = labBroadcast(mainWorkerInd,wFlag); end
      if wxFlag
        if isMainWorker
            bisection = 1;
        end
      else
        % CUBIC INTERPOLATION
        if isMainWorker
            if (w > x)
              aa = x; fa = perfx; ga = dperfx;
              bb = w; fb = perfw; gb = dperfw;
            else
              bb = x; fb = perfx; gb = dperfx;
              aa = w; fa = perfw; ga = dperfw;
            end
            ww = 3*(fa - fb)/(bb-aa) + ga + gb;
            w_gagb = ww^2 - ga*gb;
        end
        if isMainWorker, wFlag = (w_gagb >= 0); end
        if isParallel, wFlag = labBroadcast(mainWorkerInd,wFlag); end
        if wFlag
          if isMainWorker
              v = sqrt(w_gagb);
              den_star = (gb - ga +2*v);
              if den_star ==0,
                u_star = aa;
              else
                u_star = aa + (bb-aa)*(1 - (gb + v - ww)/den_star);
              end
          end
          if isMainWorker, uFlag = ((u_star > a) && (u_star < b)); end
          if isParallel, uFlag = labBroadcast(mainWorkerInd,uFlag); end
          if uFlag
            if isMainWorker
                X_temp = X + u_star*dX;
            end
            calcNet_temp = calcLib.setwb(calcNet,X_temp);
            perfu = calcLib.trainPerf(calcNet_temp);
            gX_temp = -calcLib.grad(calcNet_temp);
            if isMainWorker
                dperfu = gX_temp'*dX;
                u = u_star;
                cnt2 = cnt2 + 1;
                bisection = 0;
            end
          else
            if isMainWorker
                bisection = 1;
            end
          end
        else
          if isMainWorker
            bisection = 1;
          end
        end
      end
      
      if isMainWorker, bisecFlag = (bisection == 1); end
      if isParallel, bisecFlag = labBroadcast(mainWorkerInd,bisecFlag); end
      if bisecFlag
        % BISECTION
        if isMainWorker
            if ((dperfa<0) && ((dperfx>0) || (perfx>perfa))) || ((dperfa>0) && (dperfx>0) && (perfx<perfa))
              u = (a + x)/2;
            else
              u = (x + b)/2;
            end
            X_temp = X + u*dX;
        end
        calcNet_temp = calcLib.setwb(calcNet,X_temp);
        perfu = calcLib.trainPerf(calcNet_temp);
        gX_temp = -calcLib.grad(calcNet_temp);
        if isMainWorker
            dperfu = gX_temp'*dX;
            cnt2 = cnt2 + 1;
        end
      end

      % We must also check that the new points is smaller than extremes
      if isMainWorker
          if ( dperfu < min_grad ) && (perfu <= perfa) && (perfu <= perfb)
            a = u; perfa = perfu; dperfa = dperfu;
            b = u; perfb = perfu; dperfb = dperfu;
          elseif (u>x)
            a = x; perfa = perfx; dperfa = dperfx;
          elseif (u<x)
            b = x; perfb = perfx; dperfb = dperfx;
          else
            a = x; perfa = perfx; dperfa = dperfx;
            b = x; perfb = perfx; dperfb = dperfx;
          end

          % DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
          if perfa>perfb
            w = b;
            perfw = perfb;
            dperfw = dperfb;
          else
            w = a;
            perfw = perfa;
            dperfw = dperfa;
          end

          x = u; perfx = perfu; dperfx = dperfu; 

          minperf = min([perfa perfb perfx]);
          amin = a; dperfmin = dperfa;
          if perfb<= minperf
            amin = b; dperfmin = dperfb;
          elseif perfx <= minperf
            amin = x; dperfmin = dperfx;
          end
      end

    end
  else
    if isMainWorker
        minperf=perfa;
        amin=a;
    end
  end	% END of ~isnan(perfb)

  if isMainWorker
      a = amin;

      % COMPUTE FINAL GRADIENT
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

      tol=delta/scale_tol;
      retcode = [cnt1 cnt2 0];
  end
end
